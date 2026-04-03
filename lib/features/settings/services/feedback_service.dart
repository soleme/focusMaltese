import 'package:flutter/services.dart';

import '../models/app_settings.dart';

class FeedbackService {
  const FeedbackService();

  Future<void> onPresetSelected(AppSettings settings) async {
    await _playSound(settings, SystemSoundType.click);
    await _selectionHaptic(settings);
  }

  Future<void> onSessionStarted(AppSettings settings) async {
    await _playSound(settings, SystemSoundType.click);
    await _lightImpact(settings);
  }

  Future<void> onSessionPaused(AppSettings settings) async {
    await _playSound(settings, SystemSoundType.alert);
    await _selectionHaptic(settings);
  }

  Future<void> onSessionResumed(AppSettings settings) async {
    await _playSound(settings, SystemSoundType.click);
    await _lightImpact(settings);
  }

  Future<void> onSessionSuccess(AppSettings settings) async {
    await _playSound(settings, SystemSoundType.alert);
    await _successHaptic(settings);
  }

  Future<void> onSessionFailed(AppSettings settings) async {
    await _playSound(settings, SystemSoundType.alert);
    await _errorHaptic(settings);
  }

  Future<void> onRewardCollected(AppSettings settings) async {
    await _playSound(settings, SystemSoundType.click);
    await _successHaptic(settings);
  }

  Future<void> onRetry(AppSettings settings) async {
    await _playSound(settings, SystemSoundType.click);
    await _lightImpact(settings);
  }

  Future<void> _playSound(AppSettings settings, SystemSoundType type) async {
    if (!settings.soundEnabled) {
      return;
    }
    await SystemSound.play(type);
  }

  Future<void> _selectionHaptic(AppSettings settings) async {
    if (!settings.hapticsEnabled) {
      return;
    }
    await HapticFeedback.selectionClick();
  }

  Future<void> _lightImpact(AppSettings settings) async {
    if (!settings.hapticsEnabled) {
      return;
    }
    await HapticFeedback.lightImpact();
  }

  Future<void> _successHaptic(AppSettings settings) async {
    if (!settings.hapticsEnabled) {
      return;
    }
    await HapticFeedback.mediumImpact();
  }

  Future<void> _errorHaptic(AppSettings settings) async {
    if (!settings.hapticsEnabled) {
      return;
    }
    await HapticFeedback.heavyImpact();
  }
}
