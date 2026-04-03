import 'package:flutter_test/flutter_test.dart';
import 'package:focus_maltese/features/pet/models/dog_profile.dart';
import 'package:focus_maltese/features/timer/services/reward_service.dart';

void main() {
  const rewardService = RewardService();

  test('25분 세션 보상을 계산한다', () {
    final reward = rewardService.calculate(
      minutes: 25,
      currentDog: DogProfile.initial(),
    );

    expect(reward.gainedXp, 120);
    expect(reward.gainedTreats, 2);
    expect(reward.leveledUp, isTrue);
  });

  test('보상 적용 시 레벨과 경험치가 갱신된다', () {
    final dog = DogProfile.initial();
    final reward = rewardService.calculate(minutes: 25, currentDog: dog);
    final updated = rewardService.applyReward(dog: dog, reward: reward);

    expect(updated.level, 2);
    expect(updated.experience, 0);
    expect(updated.treatCount, 2);
  });
}
