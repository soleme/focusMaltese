import '../../pet/models/dog_profile.dart';
import '../../settings/models/app_settings.dart';
import 'focus_session.dart';
import 'focus_record.dart';
import 'session_preset.dart';
import 'timer_status.dart';

class AppSnapshot {
  const AppSnapshot({
    required this.dog,
    required this.session,
    required this.selectedPreset,
    required this.completedSessions,
    required this.totalFocusMinutes,
    required this.lastCompletedAt,
    required this.settings,
    required this.recentRecords,
  });

  factory AppSnapshot.initial() {
    return AppSnapshot(
      dog: DogProfile.initial(),
      session: FocusSession.idle(
        targetDuration: Duration(minutes: SessionPreset.focus25.minutes),
      ),
      selectedPreset: SessionPreset.focus25,
      completedSessions: 0,
      totalFocusMinutes: 0,
      lastCompletedAt: null,
      settings: AppSettings.initial(),
      recentRecords: const <FocusRecord>[],
    );
  }

  final DogProfile dog;
  final FocusSession session;
  final SessionPreset selectedPreset;
  final int completedSessions;
  final int totalFocusMinutes;
  final DateTime? lastCompletedAt;
  final AppSettings settings;
  final List<FocusRecord> recentRecords;

  AppSnapshot copyWith({
    DogProfile? dog,
    FocusSession? session,
    SessionPreset? selectedPreset,
    int? completedSessions,
    int? totalFocusMinutes,
    DateTime? lastCompletedAt,
    AppSettings? settings,
    List<FocusRecord>? recentRecords,
    bool clearLastCompletedAt = false,
  }) {
    return AppSnapshot(
      dog: dog ?? this.dog,
      session: session ?? this.session,
      selectedPreset: selectedPreset ?? this.selectedPreset,
      completedSessions: completedSessions ?? this.completedSessions,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      lastCompletedAt: clearLastCompletedAt
          ? null
          : lastCompletedAt ?? this.lastCompletedAt,
      settings: settings ?? this.settings,
      recentRecords: recentRecords ?? this.recentRecords,
    );
  }

  AppSnapshot normalized() {
    if (session.status == TimerStatus.focusing) {
      return copyWith(
        dog: dog.copyWith(currentStatus: TimerStatus.paused),
        session: session.copyWith(status: TimerStatus.paused),
      );
    }
    return this;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dog': dog.toJson(),
      'session': session.toJson(),
      'selectedPresetMinutes': selectedPreset.minutes,
      'completedSessions': completedSessions,
      'totalFocusMinutes': totalFocusMinutes,
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'settings': settings.toJson(),
      'recentRecords': recentRecords
          .map((FocusRecord e) => e.toJson())
          .toList(),
    };
  }

  factory AppSnapshot.fromJson(Map<String, dynamic> json) {
    return AppSnapshot(
      dog: DogProfile.fromJson(
        json['dog'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      session: FocusSession.fromJson(
        json['session'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      selectedPreset: SessionPreset.fromMinutes(
        json['selectedPresetMinutes'] as int? ?? SessionPreset.focus25.minutes,
      ),
      completedSessions: json['completedSessions'] as int? ?? 0,
      totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
      lastCompletedAt: json['lastCompletedAt'] == null
          ? null
          : DateTime.tryParse(json['lastCompletedAt'] as String),
      settings: AppSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      recentRecords: (json['recentRecords'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(FocusRecord.fromJson)
          .toList(),
    ).normalized();
  }
}
