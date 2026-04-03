import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../pet/models/dog_profile.dart';

class PetStatusHeader extends StatelessWidget {
  const PetStatusHeader({super.key, required this.dog});

  final DogProfile dog;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lv. ${dog.level}', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(dog.name, style: textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(
                dog.breed,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pets_rounded, color: AppColors.success),
                const SizedBox(width: 6),
                Text('${dog.treatCount} 개껌', style: textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
