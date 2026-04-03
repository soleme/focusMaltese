class RewardResult {
  const RewardResult({
    required this.gainedXp,
    required this.gainedTreats,
    required this.leveledUp,
  });

  final int gainedXp;
  final int gainedTreats;
  final bool leveledUp;
}
