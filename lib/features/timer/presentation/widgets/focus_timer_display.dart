import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/timer_status.dart';

class FocusTimerDisplay extends StatelessWidget {
  const FocusTimerDisplay({
    super.key,
    required this.formattedTime,
    required this.status,
    required this.statusLabel,
  });

  final String formattedTime;
  final TimerStatus status;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentForStatus(status.name);
    final faded = status == TimerStatus.fail;

    return Column(
      children: [
        Text(
          statusLabel,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: accent),
        ),
        const SizedBox(height: 12),
        Text(
          formattedTime,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: faded
                ? AppColors.textSecondary.withValues(alpha: 0.55)
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(switch (status) {
          TimerStatus.idle => '선택한 루틴 시간',
          TimerStatus.focusing => '남은 집중 시간',
          TimerStatus.paused => '멈춘 시점의 남은 시간',
          TimerStatus.success => '이번 세션 완료',
          TimerStatus.fail => '종료된 시점의 남은 시간',
        }, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
