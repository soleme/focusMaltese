import 'timer_status.dart';

class FocusSession {
  const FocusSession({
    required this.targetDuration,
    required this.remainingDuration,
    required this.status,
    required this.startedAt,
    required this.endedAt,
  });

  factory FocusSession.idle({required Duration targetDuration}) {
    return FocusSession(
      targetDuration: targetDuration,
      remainingDuration: targetDuration,
      status: TimerStatus.idle,
      startedAt: null,
      endedAt: null,
    );
  }

  factory FocusSession.start({required int minutes}) {
    final duration = Duration(minutes: minutes);
    return FocusSession(
      targetDuration: duration,
      remainingDuration: duration,
      status: TimerStatus.focusing,
      startedAt: DateTime.now(),
      endedAt: null,
    );
  }

  final Duration targetDuration;
  final Duration remainingDuration;
  final TimerStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;

  FocusSession copyWith({
    Duration? targetDuration,
    Duration? remainingDuration,
    TimerStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    bool clearStartedAt = false,
    bool clearEndedAt = false,
  }) {
    return FocusSession(
      targetDuration: targetDuration ?? this.targetDuration,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      status: status ?? this.status,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'targetDuration': targetDuration.inSeconds,
      'remainingDuration': remainingDuration.inSeconds,
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      targetDuration: Duration(seconds: json['targetDuration'] as int? ?? 1500),
      remainingDuration: Duration(
        seconds: json['remainingDuration'] as int? ?? 1500,
      ),
      status: TimerStatusX.fromName(
        json['status'] as String? ?? TimerStatus.idle.name,
      ),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.tryParse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.tryParse(json['endedAt'] as String),
    );
  }
}
