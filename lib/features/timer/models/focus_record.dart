class FocusRecord {
  const FocusRecord({
    required this.minutes,
    required this.gainedXp,
    required this.gainedTreats,
    required this.completedAt,
  });

  final int minutes;
  final int gainedXp;
  final int gainedTreats;
  final DateTime completedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'minutes': minutes,
      'gainedXp': gainedXp,
      'gainedTreats': gainedTreats,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory FocusRecord.fromJson(Map<String, dynamic> json) {
    return FocusRecord(
      minutes: json['minutes'] as int? ?? 0,
      gainedXp: json['gainedXp'] as int? ?? 0,
      gainedTreats: json['gainedTreats'] as int? ?? 0,
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
