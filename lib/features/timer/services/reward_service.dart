import '../../pet/models/dog_profile.dart';
import '../models/reward_result.dart';
import '../models/timer_status.dart';

class RewardService {
  const RewardService();

  RewardResult calculate({
    required int minutes,
    required DogProfile currentDog,
  }) {
    final gainedXp = minutes == 50 ? 240 : 120;
    final gainedTreats = minutes == 50 ? 4 : 2;
    final leveledUp =
        _resolveLevel(
          currentLevel: currentDog.level,
          currentExperience: currentDog.experience,
          gainedXp: gainedXp,
        ) >
        currentDog.level;

    return RewardResult(
      gainedXp: gainedXp,
      gainedTreats: gainedTreats,
      leveledUp: leveledUp,
    );
  }

  DogProfile applyReward({
    required DogProfile dog,
    required RewardResult reward,
  }) {
    var level = dog.level;
    var experience = dog.experience + reward.gainedXp;

    while (experience >= _xpThresholdForLevel(level)) {
      experience -= _xpThresholdForLevel(level);
      level += 1;
    }

    return dog.copyWith(
      level: level,
      experience: experience,
      treatCount: dog.treatCount + reward.gainedTreats,
      currentStatus: TimerStatus.success,
    );
  }

  int _resolveLevel({
    required int currentLevel,
    required int currentExperience,
    required int gainedXp,
  }) {
    var level = currentLevel;
    var experience = currentExperience + gainedXp;
    while (experience >= _xpThresholdForLevel(level)) {
      experience -= _xpThresholdForLevel(level);
      level += 1;
    }
    return level;
  }

  int _xpThresholdForLevel(int level) => 120 + ((level - 1) * 80);
}
