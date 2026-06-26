class MoodLog {
  final int id;
  final String date;
  final String mood; // happy | calm | sad | anxious | irritable | energetic
  final int energyLevel; // 1–5
  final String? notes;
  final int createdAt;

  const MoodLog({
    required this.id,
    required this.date,
    required this.mood,
    required this.energyLevel,
    this.notes,
    required this.createdAt,
  });

  DateTime get dateTime => DateTime.parse(date);
}
