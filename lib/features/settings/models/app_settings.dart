class AppSettings {
  const AppSettings({
    required this.soundEnabled,
    required this.notificationsEnabled,
    required this.notificationPermissionGranted,
    required this.hapticsEnabled,
  });

  factory AppSettings.initial() {
    return const AppSettings(
      soundEnabled: true,
      notificationsEnabled: false,
      notificationPermissionGranted: false,
      hapticsEnabled: true,
    );
  }

  final bool soundEnabled;
  final bool notificationsEnabled;
  final bool notificationPermissionGranted;
  final bool hapticsEnabled;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? notificationsEnabled,
    bool? notificationPermissionGranted,
    bool? hapticsEnabled,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationPermissionGranted:
          notificationPermissionGranted ?? this.notificationPermissionGranted,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
      'notificationPermissionGranted': notificationPermissionGranted,
      'hapticsEnabled': hapticsEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      notificationPermissionGranted:
          json['notificationPermissionGranted'] as bool? ?? false,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }
}
