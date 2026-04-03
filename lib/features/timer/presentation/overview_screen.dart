import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/app_snapshot.dart';
import '../models/focus_record.dart';
import '../models/session_preset.dart';
import '../models/timer_status.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key, required this.snapshot});

  final AppSnapshot snapshot;

  String get _statusDescription {
    switch (snapshot.session.status) {
      case TimerStatus.idle:
        return '지금은 차분하게 다음 세션을 준비하는 상태예요.';
      case TimerStatus.focusing:
        return '말티즈가 사용자의 집중을 지켜보고 있어요.';
      case TimerStatus.paused:
        return '세션이 잠깐 멈춰 있어요. 다시 이어서 집중할 수 있어요.';
      case TimerStatus.success:
        return '방금 세션을 성공적으로 마쳤고 보상을 받았어요.';
      case TimerStatus.fail:
        return '세션이 중간에 종료되었어요. 다음엔 다시 도전할 수 있어요.';
    }
  }

  String get _presetLabel {
    return snapshot.selectedPreset == SessionPreset.focus25
        ? '25분 집중 루틴'
        : '50분 몰입 루틴';
  }

  String get _lastCompletedLabel {
    final date = snapshot.lastCompletedAt;
    if (date == null) {
      return '아직 완료한 세션이 없어요';
    }
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.month}월 ${date.day}일 $hour:$minute';
  }

  int get _todayMinutes {
    final now = DateTime.now();
    return snapshot.recentRecords
        .where(
          (record) =>
              record.completedAt.year == now.year &&
              record.completedAt.month == now.month &&
              record.completedAt.day == now.day,
        )
        .fold<int>(0, (sum, record) => sum + record.minutes);
  }

  int get _weeklyMinutes {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    return snapshot.recentRecords
        .where(
          (record) => !record.completedAt.isBefore(
            DateTime(weekAgo.year, weekAgo.month, weekAgo.day),
          ),
        )
        .fold<int>(0, (sum, record) => sum + record.minutes);
  }

  int get _successStreakDays {
    final uniqueDays =
        snapshot.recentRecords
            .map(
              (record) => DateTime(
                record.completedAt.year,
                record.completedAt.month,
                record.completedAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (uniqueDays.isEmpty) {
      return 0;
    }

    var streak = 0;
    var cursor = DateTime(
      uniqueDays.first.year,
      uniqueDays.first.month,
      uniqueDays.first.day,
    );

    for (final day in uniqueDays) {
      if (day == cursor) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (day.isBefore(cursor)) {
        break;
      }
    }

    return streak;
  }

  List<_DailyFocusPoint> get _weeklySeries {
    final now = DateTime.now();
    final Map<String, int> totals = <String, int>{};

    for (final record in snapshot.recentRecords) {
      final dayKey =
          '${record.completedAt.year}-${record.completedAt.month}-${record.completedAt.day}';
      totals.update(
        dayKey,
        (value) => value + record.minutes,
        ifAbsent: () => record.minutes,
      );
    }

    return List<_DailyFocusPoint>.generate(7, (int index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
      final key = '${day.year}-${day.month}-${day.day}';
      return _DailyFocusPoint(
        label: switch (day.weekday) {
          DateTime.monday => '월',
          DateTime.tuesday => '화',
          DateTime.wednesday => '수',
          DateTime.thursday => '목',
          DateTime.friday => '금',
          DateTime.saturday => '토',
          DateTime.sunday => '일',
          _ => '',
        },
        minutes: totals[key] ?? 0,
      );
    });
  }

  int get _averageSessionMinutes {
    if (snapshot.recentRecords.isEmpty) {
      return 0;
    }
    final total = snapshot.recentRecords.fold<int>(
      0,
      (sum, record) => sum + record.minutes,
    );
    return (total / snapshot.recentRecords.length).round();
  }

  int get _longestSessionMinutes {
    if (snapshot.recentRecords.isEmpty) {
      return 0;
    }
    return snapshot.recentRecords
        .map((record) => record.minutes)
        .reduce((a, b) => a > b ? a : b);
  }

  void _showRecordDetail(BuildContext context, FocusRecord record) {
    final textTheme = Theme.of(context).textTheme;
    final hour = record.completedAt.hour.toString().padLeft(2, '0');
    final minute = record.completedAt.minute.toString().padLeft(2, '0');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('세션 상세', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '${record.completedAt.month}월 ${record.completedAt.day}일 $hour:$minute 완료',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: '집중 시간',
                      value: '${record.minutes}분',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      label: '획득 XP',
                      value: '+${record.gainedXp}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatTile(label: '획득 개껌', value: '+${record.gainedTreats}개'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = AppColors.accentForStatus(snapshot.session.status.name);
    final requiredXp = 120 + ((snapshot.dog.level - 1) * 80);
    final progress = (snapshot.dog.experience / requiredXp).clamp(0, 1);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, AppColors.glow],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('말티즈 상태', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '성장 정보와 현재 루틴 흐름을 한눈에 볼 수 있어요.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _OverviewHeroCard(
                level: snapshot.dog.level,
                treats: snapshot.dog.treatCount,
                breed: snapshot.dog.breed,
                name: snapshot.dog.name,
                accent: accent,
                status: snapshot.session.status,
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: '성장 진행도',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 XP ${snapshot.dog.experience} / $requiredXp',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: progress.toDouble(),
                        backgroundColor: AppColors.glow.withValues(alpha: 0.85),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '다음 레벨까지 ${(requiredXp - snapshot.dog.experience).clamp(0, requiredXp)} XP 남았어요.',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: '집중 기록',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: '완료 세션',
                            value: '${snapshot.completedSessions}회',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            label: '누적 집중',
                            value: '${snapshot.totalFocusMinutes}분',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatTile(label: '마지막 성공', value: _lastCompletedLabel),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: '리듬 통계',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: '오늘 집중',
                            value: '$_todayMinutes분',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            label: '최근 7일',
                            value: '$_weeklyMinutes분',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatTile(
                      label: '연속 성공 흐름',
                      value: _successStreakDays == 0
                          ? '시작 전'
                          : '$_successStreakDays일 연속',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: '평균 세션',
                            value: _averageSessionMinutes == 0
                                ? '-'
                                : '$_averageSessionMinutes분',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            label: '가장 긴 집중',
                            value: _longestSessionMinutes == 0
                                ? '-'
                                : '$_longestSessionMinutes분',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _WeeklyFocusChart(series: _weeklySeries),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: '최근 세션',
                child: snapshot.recentRecords.isEmpty
                    ? Text(
                        '아직 기록된 세션이 없어요. 첫 집중을 시작해보세요.',
                        style: textTheme.bodyMedium,
                      )
                    : Column(
                        children: snapshot.recentRecords.map((record) {
                          final hour = record.completedAt.hour
                              .toString()
                              .padLeft(2, '0');
                          final minute = record.completedAt.minute
                              .toString()
                              .padLeft(2, '0');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _showRecordDetail(context, record),
                              child: Ink(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.glow,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(
                                          alpha: 0.16,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${record.minutes}분 집중 완료',
                                            style: textTheme.bodyLarge,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${record.completedAt.month}월 ${record.completedAt.day}일 $hour:$minute',
                                            style: textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withValues(
                                              alpha: 0.16,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '+${record.gainedXp} XP',
                                            style: textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: AppColors.textPrimary,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '+${record.gainedTreats} 개껌',
                                          style: textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: '현재 세션',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: '상태', value: snapshot.session.status.label),
                    _InfoRow(label: '선택 루틴', value: _presetLabel),
                    _InfoRow(
                      label: '남은 시간',
                      value:
                          '${snapshot.session.remainingDuration.inMinutes.toString().padLeft(2, '0')}:${snapshot.session.remainingDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                    ),
                    const SizedBox(height: 10),
                    Text(_statusDescription, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: '다음 확장 준비',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MVP 이후 예정 기능', style: textTheme.bodyLarge),
                    const SizedBox(height: 10),
                    const _FeatureChipWrap(
                      labels: ['상점', '꾸미기 아이템', '다른 견종', '알림', '집중 기록 통계'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewHeroCard extends StatelessWidget {
  const _OverviewHeroCard({
    required this.level,
    required this.treats,
    required this.breed,
    required this.name,
    required this.accent,
    required this.status,
  });

  final int level;
  final int treats;
  final String breed;
  final String name;
  final Color accent;
  final TimerStatus status;

  String get _assetPath {
    switch (status) {
      case TimerStatus.idle:
        return 'assets/maltese/idle.png';
      case TimerStatus.focusing:
        return 'assets/maltese/focusing.png';
      case TimerStatus.paused:
        return 'assets/maltese/paused.png';
      case TimerStatus.success:
        return 'assets/maltese/success.png';
      case TimerStatus.fail:
        return 'assets/maltese/fail.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.95),
            accent.withValues(alpha: 0.72),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$name\n$breed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Lv. $level',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Center(
            child: Container(
              width: 184,
              height: 152,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(26),
              ),
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  _assetPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.pets_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '$treats 개껌 보유',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _FeatureChipWrap extends StatelessWidget {
  const _FeatureChipWrap({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((String label) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glow, width: 1.5),
          ),
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        );
      }).toList(),
    );
  }
}

class _DailyFocusPoint {
  const _DailyFocusPoint({required this.label, required this.minutes});

  final String label;
  final int minutes;
}

class _WeeklyFocusChart extends StatelessWidget {
  const _WeeklyFocusChart({required this.series});

  final List<_DailyFocusPoint> series;

  @override
  Widget build(BuildContext context) {
    final maxMinutes = series.fold<int>(
      1,
      (current, point) => point.minutes > current ? point.minutes : current,
    );
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('최근 7일 흐름', style: textTheme.bodyLarge),
          const SizedBox(height: 14),
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: series.map((point) {
                final ratio = point.minutes == 0
                    ? 0.08
                    : point.minutes / maxMinutes;
                final isToday = point.label == series.last.label;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          point.minutes == 0 ? '-' : '${point.minutes}',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              height: 88 * ratio.clamp(0.08, 1.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isToday
                                      ? [AppColors.focusing, AppColors.success]
                                      : [
                                          AppColors.idle.withValues(
                                            alpha: 0.82,
                                          ),
                                          AppColors.idle,
                                        ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(point.label, style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
