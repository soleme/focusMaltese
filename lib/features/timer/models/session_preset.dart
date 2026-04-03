enum SessionPreset {
  focus25(label: '25분 집중', minutes: 25),
  flow50(label: '50분 몰입', minutes: 50);

  const SessionPreset({required this.label, required this.minutes});

  final String label;
  final int minutes;

  static SessionPreset fromMinutes(int minutes) {
    return SessionPreset.values.firstWhere(
      (SessionPreset preset) => preset.minutes == minutes,
      orElse: () => SessionPreset.focus25,
    );
  }
}
