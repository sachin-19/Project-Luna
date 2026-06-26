class CycleEntry {
  final int id;
  final String startDate;
  final String? endDate;
  final int? cycleLength;
  final int? periodLength;
  final String? notes;
  final bool isSeeded;
  final int createdAt;

  const CycleEntry({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    this.notes,
    this.isSeeded = false,
    required this.createdAt,
  });

  bool get isOngoing => endDate == null;

  DateTime get startDateTime => DateTime.parse(startDate);
}
