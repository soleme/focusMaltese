enum TimerStatus { idle, focusing, paused, success, fail }

extension TimerStatusX on TimerStatus {
  String get label {
    switch (this) {
      case TimerStatus.idle:
        return '준비 중';
      case TimerStatus.focusing:
        return '집중 중';
      case TimerStatus.paused:
        return '일시정지';
      case TimerStatus.success:
        return '집중 성공';
      case TimerStatus.fail:
        return '집중 실패';
    }
  }

  static TimerStatus fromName(String name) {
    return TimerStatus.values.firstWhere(
      (TimerStatus value) => value.name == name,
      orElse: () => TimerStatus.idle,
    );
  }
}
