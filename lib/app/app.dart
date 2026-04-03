import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/services/feedback_service.dart';
import '../features/settings/services/local_notification_service.dart';
import '../features/timer/models/app_snapshot.dart';
import '../features/timer/services/shared_preferences_persistence_repository.dart';
import '../features/timer/presentation/overview_screen.dart';
import 'theme/app_theme.dart';
import '../features/timer/presentation/home_screen.dart';

class FocusMalteseApp extends StatelessWidget {
  const FocusMalteseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '집중해 말티즈',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _repository = const SharedPreferencesPersistenceRepository();
  final _feedbackService = const FeedbackService();
  final _notificationService = LocalNotificationService();
  int _currentIndex = 0;
  int _homeRevision = 0;
  AppSnapshot _snapshot = AppSnapshot.initial();

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    _syncNotificationPermissions();
  }

  Future<void> _syncNotificationPermissions() async {
    final granted = await _notificationService.checkPermissions();
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = _snapshot.copyWith(
        settings: _snapshot.settings.copyWith(
          notificationPermissionGranted: granted,
          notificationsEnabled:
              granted && _snapshot.settings.notificationsEnabled,
        ),
      );
    });
  }

  Future<void> _saveSnapshot(AppSnapshot snapshot) async {
    setState(() {
      _snapshot = snapshot;
    });
    await _repository.saveSnapshot(snapshot);
  }

  Future<void> _resetProgress() async {
    final reset = AppSnapshot.initial().copyWith(settings: _snapshot.settings);
    await _repository.clear();
    await _repository.saveSnapshot(reset);
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = reset;
      _currentIndex = 0;
      _homeRevision += 1;
    });
  }

  Future<void> _openSystemSettings() async {
    final uri = Uri.parse('app-settings:');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      FocusHomeScreen(
        key: ValueKey<int>(_homeRevision),
        repository: _repository,
        feedbackService: _feedbackService,
        notificationService: _notificationService,
        onSnapshotChanged: (AppSnapshot snapshot) {
          if (!mounted) {
            return;
          }
          setState(() {
            _snapshot = snapshot;
          });
        },
      ),
      OverviewScreen(snapshot: _snapshot),
      SettingsScreen(
        snapshot: _snapshot,
        onSoundChanged: (bool value) {
          _saveSnapshot(
            _snapshot.copyWith(
              settings: _snapshot.settings.copyWith(soundEnabled: value),
            ),
          );
        },
        onNotificationsChanged: (bool value) {
          if (!value) {
            _saveSnapshot(
              _snapshot.copyWith(
                settings: _snapshot.settings.copyWith(
                  notificationsEnabled: false,
                ),
              ),
            );
            _notificationService.cancelFocusReminder(1001);
            return;
          }

          _notificationService.requestPermissions().then((bool granted) {
            _saveSnapshot(
              _snapshot.copyWith(
                settings: _snapshot.settings.copyWith(
                  notificationsEnabled: granted,
                  notificationPermissionGranted: granted,
                ),
              ),
            );
          });
        },
        onHapticsChanged: (bool value) {
          _saveSnapshot(
            _snapshot.copyWith(
              settings: _snapshot.settings.copyWith(hapticsEnabled: value),
            ),
          );
        },
        onResetProgress: _resetProgress,
        onOpenSystemSettings: _openSystemSettings,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded),
            label: '집중',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: '말티즈',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
