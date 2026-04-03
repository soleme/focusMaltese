import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../pet/models/dog_profile.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/services/feedback_service.dart';
import '../../settings/services/local_notification_service.dart';
import '../models/app_snapshot.dart';
import '../models/focus_session.dart';
import '../models/focus_record.dart';
import '../models/reward_result.dart';
import '../models/session_preset.dart';
import '../models/timer_status.dart';
import '../services/persistence_repository.dart';
import '../services/reward_service.dart';
import '../services/shared_preferences_persistence_repository.dart';
import 'widgets/focus_timer_display.dart';
import 'widgets/pet_illustration_card.dart';
import 'widgets/pet_status_header.dart';
import 'widgets/reward_summary_card.dart';
import 'widgets/session_action_panel.dart';

class FocusHomeScreen extends StatefulWidget {
  FocusHomeScreen({
    super.key,
    PersistenceRepository? repository,
    RewardService? rewardService,
    FeedbackService? feedbackService,
    LocalNotificationService? notificationService,
    this.onSnapshotChanged,
  }) : repository =
           repository ?? const SharedPreferencesPersistenceRepository(),
       rewardService = rewardService ?? const RewardService(),
       feedbackService = feedbackService ?? const FeedbackService(),
       notificationService = notificationService ?? LocalNotificationService();

  final PersistenceRepository repository;
  final RewardService rewardService;
  final FeedbackService feedbackService;
  final LocalNotificationService notificationService;
  final ValueChanged<AppSnapshot>? onSnapshotChanged;

  @override
  State<FocusHomeScreen> createState() => _FocusHomeScreenState();
}

class _FocusHomeScreenState extends State<FocusHomeScreen>
    with WidgetsBindingObserver {
  late DogProfile _dog;
  late AppSettings _settings;
  late FocusSession _session;
  int _completedSessions = 0;
  int _totalFocusMinutes = 0;
  DateTime? _lastCompletedAt;
  List<FocusRecord> _recentRecords = const <FocusRecord>[];
  SessionPreset _selectedPreset = SessionPreset.focus25;
  RewardResult? _reward;
  Timer? _ticker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dog = DogProfile.initial();
    _settings = AppSettings.initial();
    _session = FocusSession.idle(
      targetDuration: Duration(minutes: _selectedPreset.minutes),
    );
    unawaited(_loadSnapshot());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached) &&
        _session.status == TimerStatus.focusing) {
      _pauseSession();
    }
  }

  Future<void> _loadSnapshot() async {
    final snapshot = await widget.repository.loadSnapshot();
    final restored = _normalizeSnapshot(snapshot ?? AppSnapshot.initial());
    if (!mounted) {
      return;
    }

    setState(() {
      _dog = restored.dog;
      _settings = restored.settings;
      _session = restored.session;
      _selectedPreset = restored.selectedPreset;
      _completedSessions = restored.completedSessions;
      _totalFocusMinutes = restored.totalFocusMinutes;
      _lastCompletedAt = restored.lastCompletedAt;
      _recentRecords = restored.recentRecords;
      _isLoading = false;
    });
    widget.onSnapshotChanged?.call(
      AppSnapshot(
        dog: _dog,
        session: _session,
        selectedPreset: _selectedPreset,
        completedSessions: _completedSessions,
        totalFocusMinutes: _totalFocusMinutes,
        lastCompletedAt: _lastCompletedAt,
        settings: _settings,
        recentRecords: _recentRecords,
      ),
    );
  }

  AppSnapshot _normalizeSnapshot(AppSnapshot snapshot) {
    if (snapshot.session.status == TimerStatus.fail ||
        snapshot.session.status == TimerStatus.success) {
      return AppSnapshot(
        dog: snapshot.dog.copyWith(currentStatus: TimerStatus.idle),
        session: FocusSession.idle(
          targetDuration: Duration(minutes: snapshot.selectedPreset.minutes),
        ),
        selectedPreset: snapshot.selectedPreset,
        completedSessions: snapshot.completedSessions,
        totalFocusMinutes: snapshot.totalFocusMinutes,
        lastCompletedAt: snapshot.lastCompletedAt,
        settings: snapshot.settings,
        recentRecords: snapshot.recentRecords,
      );
    }
    return snapshot;
  }

  Future<void> _persist() {
    final snapshot = AppSnapshot(
      dog: _dog,
      session: _session,
      selectedPreset: _selectedPreset,
      completedSessions: _completedSessions,
      totalFocusMinutes: _totalFocusMinutes,
      lastCompletedAt: _lastCompletedAt,
      settings: _settings,
      recentRecords: _recentRecords,
    );
    widget.onSnapshotChanged?.call(snapshot);
    return widget.repository.saveSnapshot(snapshot);
  }

  void _selectPreset(SessionPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _session = FocusSession.idle(
        targetDuration: Duration(minutes: preset.minutes),
      );
    });
    unawaited(widget.feedbackService.onPresetSelected(_settings));
    unawaited(_persist());
  }

  void _startSession() {
    _ticker?.cancel();
    setState(() {
      _reward = null;
      _session = FocusSession.start(minutes: _selectedPreset.minutes);
      _dog = _dog.copyWith(currentStatus: TimerStatus.focusing);
    });
    _startTicker();
    unawaited(widget.feedbackService.onSessionStarted(_settings));
    if (_settings.notificationsEnabled) {
      unawaited(
        widget.notificationService.scheduleFocusReminder(
          id: 1001,
          delay: _session.targetDuration,
        ),
      );
    }
    unawaited(_persist());
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_session.remainingDuration.inSeconds <= 1) {
        timer.cancel();
        _completeSession();
        return;
      }

      setState(() {
        _session = _session.copyWith(
          remainingDuration: Duration(
            seconds: _session.remainingDuration.inSeconds - 1,
          ),
        );
      });
      unawaited(_persist());
    });
  }

  void _pauseSession() {
    _ticker?.cancel();
    if (_session.status != TimerStatus.focusing) {
      return;
    }

    setState(() {
      _session = _session.copyWith(status: TimerStatus.paused);
      _dog = _dog.copyWith(currentStatus: TimerStatus.paused);
    });
    unawaited(widget.feedbackService.onSessionPaused(_settings));
    unawaited(widget.notificationService.cancelFocusReminder(1001));
    unawaited(_persist());
  }

  void _resumeSession() {
    setState(() {
      _session = _session.copyWith(status: TimerStatus.focusing);
      _dog = _dog.copyWith(currentStatus: TimerStatus.focusing);
    });
    _startTicker();
    unawaited(widget.feedbackService.onSessionResumed(_settings));
    if (_settings.notificationsEnabled) {
      unawaited(
        widget.notificationService.scheduleFocusReminder(
          id: 1001,
          delay: _session.remainingDuration,
        ),
      );
    }
    unawaited(_persist());
  }

  void _completeSession() {
    final reward = widget.rewardService.calculate(
      minutes: _session.targetDuration.inMinutes,
      currentDog: _dog,
    );
    final updatedDog = widget.rewardService.applyReward(
      dog: _dog,
      reward: reward,
    );

    setState(() {
      _reward = reward;
      _dog = updatedDog;
      _completedSessions += 1;
      _totalFocusMinutes += _session.targetDuration.inMinutes;
      _lastCompletedAt = DateTime.now();
      _recentRecords = <FocusRecord>[
        FocusRecord(
          minutes: _session.targetDuration.inMinutes,
          gainedXp: reward.gainedXp,
          gainedTreats: reward.gainedTreats,
          completedAt: _lastCompletedAt!,
        ),
        ..._recentRecords,
      ].take(30).toList();
      _session = _session.copyWith(
        remainingDuration: Duration.zero,
        status: TimerStatus.success,
        endedAt: _lastCompletedAt,
      );
    });
    unawaited(widget.feedbackService.onSessionSuccess(_settings));
    unawaited(widget.notificationService.cancelFocusReminder(1001));
    unawaited(_persist());
  }

  void _giveUp() {
    _ticker?.cancel();
    setState(() {
      _reward = null;
      _session = _session.copyWith(
        status: TimerStatus.fail,
        endedAt: DateTime.now(),
      );
      _dog = _dog.copyWith(currentStatus: TimerStatus.fail);
    });
    unawaited(widget.feedbackService.onSessionFailed(_settings));
    unawaited(widget.notificationService.cancelFocusReminder(1001));
    unawaited(_persist());
  }

  void _collectReward() {
    setState(() {
      _reward = null;
      _dog = _dog.copyWith(currentStatus: TimerStatus.idle);
      _session = FocusSession.idle(
        targetDuration: Duration(minutes: _selectedPreset.minutes),
      );
    });
    unawaited(widget.feedbackService.onRewardCollected(_settings));
    unawaited(widget.notificationService.cancelFocusReminder(1001));
    unawaited(_persist());
  }

  void _retry() {
    setState(() {
      _reward = null;
      _dog = _dog.copyWith(currentStatus: TimerStatus.idle);
      _session = FocusSession.idle(
        targetDuration: Duration(minutes: _selectedPreset.minutes),
      );
    });
    unawaited(widget.feedbackService.onRetry(_settings));
    unawaited(widget.notificationService.cancelFocusReminder(1001));
    unawaited(_persist());
  }

  String get _statusMessage {
    switch (_session.status) {
      case TimerStatus.idle:
        return '주인님, 오늘도 집중해봐멍!';
      case TimerStatus.focusing:
        return '지켜보고 있다멍!\n딴짓하면 안 된다멍!';
      case TimerStatus.paused:
        return '좋은 흐름이었멍.\n준비되면 이어서 달려보자멍!';
      case TimerStatus.success:
        return '천재다멍!\n주인님 최고멍!';
      case TimerStatus.fail:
        return '조금 아쉽다멍.\n그래도 다시 시작하면 금방 회복할 수 있멍.';
    }
  }

  String get _statusLabel {
    switch (_session.status) {
      case TimerStatus.idle:
        return '집중 준비';
      case TimerStatus.focusing:
        return '집중 중';
      case TimerStatus.paused:
        return '일시정지됨';
      case TimerStatus.success:
        return _reward?.leveledUp == true ? '레벨업 성공' : '집중 성공';
      case TimerStatus.fail:
        return '세션 종료';
    }
  }

  String get _formattedTime {
    final duration = _session.status == TimerStatus.idle
        ? Duration(minutes: _selectedPreset.minutes)
        : _session.remainingDuration;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _experienceProgress {
    final requiredXp = _dog.level * 100;
    if (requiredXp == 0) {
      return 0;
    }
    return (_dog.experience / requiredXp).clamp(0, 1);
  }

  String get _helperLine {
    switch (_session.status) {
      case TimerStatus.idle:
        return '25분 또는 50분으로 오늘의 집중 루틴을 시작해보멍.';
      case TimerStatus.focusing:
        return '지금 흐름이 좋멍. 끝까지 가면 개껌과 XP를 받을 수 있멍.';
      case TimerStatus.paused:
        return '세션은 그대로 저장되어 있어요. 이어서 집중을 누르면 계속할 수 있어요.';
      case TimerStatus.success:
        return '이번 루틴은 완벽했멍. 보상을 받고 바로 다음 집중으로 이어갈 수 있어요.';
      case TimerStatus.fail:
        return '실패해도 기록은 남아요. 다시 시도해서 흐름을 이어가보세요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.glow],
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 30,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PetStatusHeader(dog: _dog),
                      const SizedBox(height: 20),
                      PetIllustrationCard(
                        status: _session.status,
                        message: _statusMessage,
                      ),
                      if (_reward != null) RewardSummaryCard(reward: _reward!),
                      const SizedBox(height: 24),
                      FocusTimerDisplay(
                        formattedTime: _formattedTime,
                        status: _session.status,
                        statusLabel: _statusLabel,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '현재 XP ${_dog.experience} / ${_dog.level * 100}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: _experienceProgress,
                          backgroundColor: AppColors.glow.withValues(
                            alpha: 0.9,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accentForStatus(_session.status.name),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _helperLine,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      SessionActionPanel(
                        status: _session.status,
                        selectedPreset: _selectedPreset,
                        onPresetSelected: _selectPreset,
                        onStart: _startSession,
                        onGiveUp: _giveUp,
                        onResume: _resumeSession,
                        onCollect: _collectReward,
                        onRetry: _retry,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 72,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
