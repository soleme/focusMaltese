import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../timer/models/app_snapshot.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.snapshot,
    required this.onSoundChanged,
    required this.onNotificationsChanged,
    required this.onHapticsChanged,
    required this.onResetProgress,
    required this.onOpenSystemSettings,
  });

  final AppSnapshot snapshot;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onHapticsChanged;
  final Future<void> Function() onResetProgress;
  final Future<void> Function() onOpenSystemSettings;

  Future<void> _confirmReset(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('진행 데이터를 초기화할까요?'),
          content: const Text('레벨, XP, 개껌, 누적 집중 기록이 모두 초기 상태로 돌아가요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.fail),
              child: const Text('초기화'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true || !context.mounted) {
      return;
    }

    await onResetProgress();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('진행 데이터가 초기화되었어요.')));
  }

  @override
  Widget build(BuildContext context) {
    final settings = snapshot.settings;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, AppColors.glow],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            Text('설정', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '알림과 사운드, 진동, 진행 데이터 초기화를 여기서 관리할 수 있어요.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _SettingsCard(
              title: '현재 상태',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    label: settings.soundEnabled ? '사운드 켜짐' : '사운드 꺼짐',
                    active: settings.soundEnabled,
                  ),
                  _StatusChip(
                    label: settings.hapticsEnabled ? '진동 켜짐' : '진동 꺼짐',
                    active: settings.hapticsEnabled,
                  ),
                  _StatusChip(
                    label: settings.notificationPermissionGranted
                        ? '알림 권한 허용'
                        : '알림 권한 없음',
                    active: settings.notificationPermissionGranted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SettingsCard(
              title: '집중 경험',
              child: Column(
                children: [
                  _SettingTile(
                    title: '사운드',
                    subtitle: '세션 전환과 보상 순간에 효과음을 사용할지 정해요.',
                    value: settings.soundEnabled,
                    onChanged: onSoundChanged,
                  ),
                  _SettingTile(
                    title: '진동',
                    subtitle: '성공, 실패, 일시정지 순간의 진동 피드백을 설정해요.',
                    value: settings.hapticsEnabled,
                    onChanged: onHapticsChanged,
                  ),
                  _SettingTile(
                    title: '집중 종료 알림',
                    subtitle: settings.notificationPermissionGranted
                        ? '권한 허용됨. 집중이 끝나면 로컬 알림을 예약해요.'
                        : '권한이 아직 없어요. 켜면 iOS 권한 요청이 떠요.',
                    value: settings.notificationsEnabled,
                    onChanged: onNotificationsChanged,
                    trailingLabel: settings.notificationPermissionGranted
                        ? '허용됨'
                        : '권한 필요',
                  ),
                ],
              ),
            ),
            if (!settings.notificationPermissionGranted) ...[
              const SizedBox(height: 18),
              _SettingsCard(
                title: '알림 권한 안내',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '집중 종료 알림을 사용하려면 iPhone 설정에서 앱 알림 권한을 허용해야 해요.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('권장 순서', style: textTheme.bodyLarge),
                          const SizedBox(height: 8),
                          Text(
                            '1. 집중 종료 알림 토글 켜기\n2. 시스템 권한 팝업에서 허용 선택\n3. 이미 거절했다면 iPhone 설정 > 집중해 말티즈 > 알림에서 직접 허용',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton(
                            onPressed: onOpenSystemSettings,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide(
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.18,
                                ),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('iPhone 설정 열기'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            _SettingsCard(
              title: '현재 저장 정보',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: '레벨', value: 'Lv. ${snapshot.dog.level}'),
                  _InfoRow(
                    label: '누적 집중',
                    value: '${snapshot.totalFocusMinutes}분',
                  ),
                  _InfoRow(
                    label: '완료 세션',
                    value: '${snapshot.completedSessions}회',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SettingsCard(
              title: '데이터 관리',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '아래 버튼을 누르면 말티즈의 레벨, XP, 개껌, 누적 기록이 초기 상태로 돌아가요.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _confirmReset(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fail,
                    ),
                    child: const Text('진행 데이터 초기화'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.trailingLabel,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      secondary: trailingLabel == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: value
                    ? AppColors.idle.withValues(alpha: 0.18)
                    : AppColors.glow.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trailingLabel!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.idle,
      value: value,
      onChanged: onChanged,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? AppColors.idle.withValues(alpha: 0.16)
            : AppColors.glow.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
