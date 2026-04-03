import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/timer_status.dart';

class PetIllustrationCard extends StatelessWidget {
  const PetIllustrationCard({
    super.key,
    required this.status,
    required this.message,
  });

  final TimerStatus status;
  final String message;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentForStatus(status.name);
    final overlayText = switch (status) {
      TimerStatus.idle => '쿨쿨',
      TimerStatus.focusing => '집중',
      TimerStatus.paused => '잠깐',
      TimerStatus.success => '반짝',
      TimerStatus.fail => '시무룩',
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.92),
            accent.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 22,
            child: Text(
              overlayText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
                  child: child,
                ),
              );
            },
            child: Center(
              key: ValueKey<TimerStatus>(status),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 210,
                    height: 170,
                    child: _StatusArt(status: status),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (status == TimerStatus.success)
            ...List<Widget>.generate(
              5,
              (int index) => Positioned(
                left: 24.0 + (index * 56),
                top: index.isEven ? 24 : 52,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: index.isEven ? 16 : 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusArt extends StatelessWidget {
  const _StatusArt({required this.status});

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.12),
        child: Image.asset(
          _assetPath,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                return Icon(
                  status == TimerStatus.fail
                      ? Icons.pets_outlined
                      : Icons.pets_rounded,
                  size: status == TimerStatus.success ? 108 : 100,
                  color: Colors.white,
                );
              },
        ),
      ),
    );
  }
}
