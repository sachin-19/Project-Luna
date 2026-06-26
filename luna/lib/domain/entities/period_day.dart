class PeriodDay {
  final int id;
  final int cycleEntryId;
  final String date;
  final String flow; // spotting | light | medium | heavy

  const PeriodDay({
    required this.id,
    required this.cycleEntryId,
    required this.date,
    required this.flow,
  });

  DateTime get dateTime => DateTime.parse(date);
}
