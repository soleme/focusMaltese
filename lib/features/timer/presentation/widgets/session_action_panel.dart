import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/session_preset.dart';
import '../../models/timer_status.dart';

class SessionActionPanel extends StatelessWidget {
  const SessionActionPanel({
    super.key,
    required this.status,
    required this.selectedPreset,
    required this.onPresetSelected,
    required this.onStart,
    required this.onGiveUp,
    required this.onResume,
    required this.onCollect,
    required this.onRetry,
  });

  final TimerStatus status;
  final SessionPreset selectedPreset;
  final ValueChanged<SessionPreset> onPresetSelected;
  final VoidCallback onStart;
  final VoidCallback onGiveUp;
  final VoidCallback onResume;
  final VoidCallback onCollect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: switch (status) {
        TimerStatus.idle => Column(
          key: const ValueKey<String>('idle_actions'),
          children: [
            Row(
              children: SessionPreset.values.map((SessionPreset preset) {
                final selected = preset == selectedPreset;
                final color = selected
                    ? (preset == SessionPreset.focus25
                          ? AppColors.idle
                          : AppColors.focusing)
                    : Colors.white;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () => onPresetSelected(preset),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: color,
                        side: BorderSide(
                          color: selected ? color : AppColors.glow,
                          width: 2,
                        ),
                        foregroundColor: selected
                            ? Colors.white
                            : AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        preset.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.idle),
              child: const Text('집중 시작'),
            ),
          ],
        ),
        TimerStatus.focusing => ElevatedButton(
          key: const ValueKey<String>('focusing_actions'),
          onPressed: onGiveUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neutralButton,
          ),
          child: const Text('포기하기'),
        ),
        TimerStatus.paused => Column(
          key: const ValueKey<String>('paused_actions'),
          children: [
            ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.focusing,
              ),
              child: const Text('이어서 집중'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onGiveUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.paused,
              ),
              child: const Text('이번 세션 종료'),
            ),
          ],
        ),
        TimerStatus.success => ElevatedButton(
          key: const ValueKey<String>('success_actions'),
          onPressed: onCollect,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          child: const Text('보상 받기'),
        ),
        TimerStatus.fail => ElevatedButton(
          key: const ValueKey<String>('fail_actions'),
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.fail),
          child: const Text('다시 시도'),
        ),
      },
    );
  }
}
