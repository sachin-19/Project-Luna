class SymptomLog {
  final int id;
  final String date;
  final String symptom;
  final int severity; // 1–5
  final String? notes;
  final int createdAt;

  const SymptomLog({
    required this.id,
    required this.date,
    required this.symptom,
    required this.severity,
    this.notes,
    required this.createdAt,
  });

  DateTime get dateTime => DateTime.parse(date);
}
