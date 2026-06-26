import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/cycle_entry.dart';
import '../../domain/entities/mood_log.dart';
import '../../domain/entities/symptom_log.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/export_data.dart';
import 'pdf_service.dart';

enum ExportFormat { json, csv }

class ExportService {
  const ExportService();

  /// Builds the export, writes to a temp file, and triggers the Android share sheet.
  Future<void> share({
    required User user,
    required List<CycleEntry> cycles,
    required List<SymptomLog> symptoms,
    required List<MoodLog> moods,
    required ExportFormat format,
  }) async {
    final now = DateTime.now();
    final result = const ExportDataUseCase().execute(
      user: user,
      cycles: cycles,
      symptoms: symptoms,
      moods: moods,
      exportedAt: now,
    );

    final stamp = '${now.year}${_pad(now.month)}${_pad(now.day)}';
    final dir = await getTemporaryDirectory();

    switch (format) {
      case ExportFormat.json:
        final file = File('${dir.path}/luna_data_$stamp.json');
        await file.writeAsString(result.jsonString);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/json')],
          subject: 'Luna Health Data Export — $stamp',
        );

      case ExportFormat.csv:
        final file = File('${dir.path}/luna_cycles_$stamp.csv');
        await file.writeAsString(result.csvString);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Luna Cycle History — $stamp',
        );
    }
  }

  /// Generates a doctor-summary PDF covering the last 3 months and shares it.
  Future<void> sharePdf({
    required User user,
    required List<CycleEntry> cycles,
    required List<SymptomLog> symptoms,
    required List<MoodLog> moods,
  }) async {
    final now = DateTime.now();
    final bytes = await const PdfService().buildDoctorReport(
      user: user,
      cycles: cycles,
      symptoms: symptoms,
      moods: moods,
      generatedAt: now,
    );

    final stamp = '${now.year}${_pad(now.month)}${_pad(now.day)}';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/luna_health_report_$stamp.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Luna Health Report — $stamp',
    );
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
