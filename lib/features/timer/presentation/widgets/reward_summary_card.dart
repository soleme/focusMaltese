import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/reward_result.dart';

class RewardSummaryCard extends StatelessWidget {
  const RewardSummaryCard({super.key, required this.reward});

  final RewardResult reward;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.7),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.success,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            reward.leveledUp ? '레벨업 보상이 도착했멍!' : '보상을 모았멍!',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          Text(
            '+${reward.gainedXp} XP',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _RewardStat(
                    icon: Icons.bolt_rounded,
                    label: '경험치',
                    value: '+${reward.gainedXp}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RewardStat(
                    icon: Icons.pets_rounded,
                    label: '개껌',
                    value: '+${reward.gainedTreats}',
                  ),
                ),
              ],
            ),
          ),
          if (reward.leveledUp) ...[
            const SizedBox(height: 12),
            Text(
              '새로운 레벨에 도착했어요. 다음 세션에서 더 많은 보상을 노려보세요.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardStat extends StatelessWidget {
  const _RewardStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: AppColors.success),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodyMedium),
              Text(value, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
