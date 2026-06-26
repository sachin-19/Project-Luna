import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/cycle_entry.dart';
import '../../domain/entities/mood_log.dart';
import '../../domain/entities/symptom_log.dart';
import '../../domain/entities/user.dart';

class PdfService {
  const PdfService();

  // ── Palette ──────────────────────────────────────────────────────────────────
  static const _rose    = PdfColor(0.898, 0.243, 0.416);
  static const _emerald = PdfColor(0.063, 0.725, 0.506);
  static const _amber   = PdfColor(0.976, 0.451, 0.086);
  static const _ink     = PdfColor(0.10, 0.10, 0.10);
  static const _muted   = PdfColor(0.50, 0.50, 0.50);
  static const _rule    = PdfColor(0.88, 0.88, 0.88);
  static const _surface = PdfColor(0.96, 0.96, 0.97);

  Future<Uint8List> buildDoctorReport({
    required User user,
    required List<CycleEntry> cycles,
    required List<SymptomLog> symptoms,
    required List<MoodLog> moods,
    required DateTime generatedAt,
  }) async {
    // 90-day window
    final cutoff = DateTime(
      generatedAt.year,
      generatedAt.month,
      generatedAt.day,
    ).subtract(const Duration(days: 90));
    final cutoffStr = _isoDate(cutoff);

    final recentCycles = (cycles
        .where((c) => c.startDate.compareTo(cutoffStr) >= 0)
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate)));

    // If the 90-day window has fewer than 2 completed cycles, include up to 3
    // extra older cycles so the history table isn't nearly empty.
    final completed90 = recentCycles.where((c) => c.endDate != null).length;
    final displayCycles = completed90 < 2
        ? (cycles.toList()..sort((a, b) => b.startDate.compareTo(a.startDate)))
            .take(recentCycles.length + (2 - completed90).clamp(0, 3))
            .toList()
        : recentCycles;

    final recentSymptoms = symptoms
        .where((s) => s.date.compareTo(cutoffStr) >= 0)
        .toList();
    final recentMoods = moods
        .where((m) => m.date.compareTo(cutoffStr) >= 0)
        .toList();

    final bold    = pw.Font.helveticaBold();
    final regular = pw.Font.helvetica();
    final italic  = pw.Font.helveticaOblique();

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 44),
        footer: (ctx) => _footer(ctx, regular, italic),
        build: (ctx) => [
          _header(user, generatedAt, cutoff, bold, regular),
          pw.SizedBox(height: 22),
          _cycleSummary(displayCycles, user, bold, regular),
          pw.SizedBox(height: 20),
          if (displayCycles.isNotEmpty) ...[
            _cycleHistoryTable(displayCycles, bold, regular),
            pw.SizedBox(height: 20),
          ],
          if (recentSymptoms.isNotEmpty) ...[
            _symptomsSection(recentSymptoms, bold, regular),
            pw.SizedBox(height: 20),
          ],
          if (recentMoods.isNotEmpty)
            _moodSection(recentMoods, bold, regular),
        ],
      ),
    );

    return doc.save();
  }

  // ── Page header ───────────────────────────────────────────────────────────────

  pw.Widget _header(
    User user,
    DateTime generatedAt,
    DateTime from,
    pw.Font bold,
    pw.Font regular,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(width: 4, height: 36, color: _rose),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LUNA HEALTH REPORT',
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 17,
                      color: _ink,
                      letterSpacing: 0.8,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Menstrual Cycle Summary  ·  ${_fmtDate(from)} to ${_fmtDate(generatedAt)}',
                    style: pw.TextStyle(font: regular, fontSize: 9, color: _muted),
                  ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  user.displayName,
                  style: pw.TextStyle(font: bold, fontSize: 11, color: _ink),
                ),
                pw.Text(
                  'Born: ${user.birthYear}',
                  style: pw.TextStyle(font: regular, fontSize: 9, color: _muted),
                ),
                pw.Text(
                  'Generated: ${_fmtDate(generatedAt)}',
                  style: pw.TextStyle(font: regular, fontSize: 9, color: _muted),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: _rose, thickness: 0.6),
      ],
    );
  }

  // ── Cycle summary stats ───────────────────────────────────────────────────────

  pw.Widget _cycleSummary(
    List<CycleEntry> cycles,
    User user,
    pw.Font bold,
    pw.Font regular,
  ) {
    // Exclude seeded (onboarding-estimated) cycles from stats — they are
    // historical context, not verified tracked cycles.
    final nonSeeded = cycles.where((c) => !c.isSeeded).toList();
    final completed = nonSeeded.where((c) => c.cycleLength != null).toList();

    final avgCycle = completed.isEmpty
        ? user.avgCycleDays
        : (completed.map((c) => c.cycleLength!).reduce((a, b) => a + b) /
                completed.length)
            .round();

    final withPeriod = completed.where((c) => c.periodLength != null).toList();
    final avgPeriod = withPeriod.isEmpty
        ? user.avgPeriodDays
        : (withPeriod.map((c) => c.periodLength!).reduce((a, b) => a + b) /
                withPeriod.length)
            .round();

    final String regularity;
    final PdfColor regularityColor;
    if (completed.length >= 2) {
      final lengths = completed.map((c) => c.cycleLength!).toList();
      final mn = lengths.reduce((a, b) => a < b ? a : b);
      final mx = lengths.reduce((a, b) => a > b ? a : b);
      if (mx - mn <= 5) {
        regularity = 'Regular';
        regularityColor = _emerald;
      } else if (mx - mn <= 10) {
        regularity = 'Mostly regular';
        regularityColor = _amber;
      } else {
        regularity = 'Irregular';
        regularityColor = _rose;
      }
    } else {
      regularity = 'Insufficient data';
      regularityColor = _muted;
    }

    final flags = [
      if (user.hasPcos) 'PCOS',
      if (user.hasEndo) 'Endometriosis',
      if (user.onHormonalContraception) 'Hormonal contraception',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('CYCLE SUMMARY', bold),
        pw.SizedBox(height: 8),
        pw.Container(
          decoration: const pw.BoxDecoration(
            color: _surface,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _stat('Cycles tracked', '${nonSeeded.length}', bold, regular),
              _stat('Avg cycle length', '$avgCycle days', bold, regular),
              _stat('Avg period length', '$avgPeriod days', bold, regular),
              _stat('Regularity', regularity, bold, regular,
                  valueColor: regularityColor),
            ],
          ),
        ),
        if (flags.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Text(
            'Conditions / contraception: ${flags.join(' · ')}',
            style: pw.TextStyle(font: regular, fontSize: 8, color: _muted),
          ),
        ],
      ],
    );
  }

  pw.Widget _stat(
    String label,
    String value,
    pw.Font bold,
    pw.Font regular, {
    PdfColor? valueColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(font: regular, fontSize: 8, color: _muted)),
        pw.SizedBox(height: 3),
        pw.Text(value,
            style: pw.TextStyle(
                font: bold, fontSize: 13, color: valueColor ?? _ink)),
      ],
    );
  }

  // ── Cycle history table ───────────────────────────────────────────────────────

  pw.Widget _cycleHistoryTable(
    List<CycleEntry> cycles,
    pw.Font bold,
    pw.Font regular,
  ) {
    final hStyle =
        pw.TextStyle(font: bold, fontSize: 9, color: _ink);
    final cStyle =
        pw.TextStyle(font: regular, fontSize: 9, color: _ink);
    final mStyle =
        pw.TextStyle(font: regular, fontSize: 9, color: _muted);

    pw.Widget cell(String text, pw.TextStyle style) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Text(text, style: style),
        );

    final headerRow = pw.TableRow(
      decoration: const pw.BoxDecoration(color: _surface),
      children: [
        cell('Start', hStyle),
        cell('End', hStyle),
        cell('Cycle', hStyle),
        cell('Period', hStyle),
        cell('Notes', hStyle),
      ],
    );

    final dataRows = cycles.take(15).map((c) {
      final hasNotes = c.notes?.isNotEmpty == true;
      return pw.TableRow(children: [
        cell(_fmtDateShort(c.startDateTime), cStyle),
        cell(c.endDate != null
            ? _fmtDateShort(DateTime.parse(c.endDate!))
            : (c.isSeeded ? 'Historical' : 'Ongoing'),
            c.endDate != null ? cStyle : mStyle),
        cell(c.cycleLength != null ? '${c.cycleLength} d' : '—',
            c.cycleLength != null ? cStyle : mStyle),
        cell(c.periodLength != null ? '${c.periodLength} d' : '—',
            c.periodLength != null ? cStyle : mStyle),
        cell(hasNotes ? c.notes! : '—', hasNotes ? cStyle : mStyle),
      ]);
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('CYCLE HISTORY', bold),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: _rule, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(2.3),
            1: pw.FlexColumnWidth(2.3),
            2: pw.FlexColumnWidth(1.4),
            3: pw.FlexColumnWidth(1.4),
            4: pw.FlexColumnWidth(3.6),
          },
          children: [headerRow, ...dataRows],
        ),
        if (cycles.length > 15)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              'Showing most recent 15 of ${cycles.length} cycles.',
              style: pw.TextStyle(font: regular, fontSize: 7.5, color: _muted),
            ),
          ),
      ],
    );
  }

  // ── Symptoms ──────────────────────────────────────────────────────────────────

  pw.Widget _symptomsSection(
    List<SymptomLog> symptoms,
    pw.Font bold,
    pw.Font regular,
  ) {
    final map = <String, List<SymptomLog>>{};
    for (final s in symptoms) {
      map.putIfAbsent(s.symptom, () => []).add(s);
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    final maxCount = sorted.first.value.length.toDouble();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('SYMPTOMS', bold),
        pw.SizedBox(height: 2),
        pw.Text(
          '${symptoms.length} logs across ${map.length} symptom type${map.length == 1 ? '' : 's'}  ·  last 90 days',
          style: pw.TextStyle(font: regular, fontSize: 8, color: _muted),
        ),
        pw.SizedBox(height: 10),
        ...sorted.map((entry) {
          final count = entry.value.length;
          final avgSev = entry.value
                  .map((s) => s.severity)
                  .reduce((a, b) => a + b) /
              count;
          final frac = count / maxCount;

          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 108,
                  child: pw.Text(
                    _titleCase(entry.key),
                    style:
                        pw.TextStyle(font: regular, fontSize: 9, color: _ink),
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Container(
                  width: 140 * frac,
                  height: 8,
                  color: _rose,
                ),
                pw.Container(
                  width: 140 * (1 - frac),
                  height: 8,
                  color: _rule,
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  '$count occurrence${count == 1 ? '' : 's'}',
                  style: pw.TextStyle(
                      font: regular, fontSize: 8, color: _muted),
                ),
                pw.Text(
                  '  ·  avg severity ${avgSev.toStringAsFixed(1)}/5',
                  style: pw.TextStyle(
                      font: regular, fontSize: 8, color: _muted),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Mood ──────────────────────────────────────────────────────────────────────

  pw.Widget _moodSection(
    List<MoodLog> moods,
    pw.Font bold,
    pw.Font regular,
  ) {
    final map = <String, int>{};
    for (final m in moods) {
      map[m.mood] = (map[m.mood] ?? 0) + 1;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = moods.length;
    final avgEnergy =
        moods.map((m) => m.energyLevel).reduce((a, b) => a + b) / total;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('MOOD', bold),
        pw.SizedBox(height: 2),
        pw.Text(
          '$total mood logs  ·  average energy level: ${avgEnergy.toStringAsFixed(1)} / 5  ·  last 90 days',
          style: pw.TextStyle(font: regular, fontSize: 8, color: _muted),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: sorted.take(6).map((entry) {
            final pct = (entry.value / total * 100).round();
            return pw.Padding(
              padding: const pw.EdgeInsets.only(right: 16),
              child: pw.Column(
                children: [
                  pw.Container(
                    width: 44,
                    height: 44,
                    decoration: const pw.BoxDecoration(
                      color: _surface,
                      borderRadius:
                          pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '$pct%',
                        style: pw.TextStyle(
                            font: bold, fontSize: 11, color: _ink),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _titleCase(entry.key),
                    style: pw.TextStyle(
                        font: regular, fontSize: 8, color: _muted),
                  ),
                  pw.Text(
                    '${entry.value} day${entry.value == 1 ? '' : 's'}',
                    style: pw.TextStyle(
                        font: regular, fontSize: 7, color: _muted),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────────

  pw.Widget _footer(pw.Context ctx, pw.Font regular, pw.Font italic) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        children: [
          pw.Divider(color: _rule, thickness: 0.5),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Luna is not a medical device. This summary is for informational purposes only.',
                style:
                    pw.TextStyle(font: italic, fontSize: 7, color: _muted),
              ),
              pw.Text(
                'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style:
                    pw.TextStyle(font: regular, fontSize: 7, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────────

  pw.Widget _sectionTitle(String title, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: bold,
            fontSize: 9.5,
            color: _rose,
            letterSpacing: 1.4,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: _rule, thickness: 0.5),
      ],
    );
  }

  static String _fmtDate(DateTime d) {
    const mo = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${mo[d.month]} ${d.year}';
  }

  static String _fmtDateShort(DateTime d) => _fmtDate(d);

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _titleCase(String s) => s
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (m) => '${m[1]} ${m[2]}',
      )
      .split(RegExp(r'[\s_]+'))
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
