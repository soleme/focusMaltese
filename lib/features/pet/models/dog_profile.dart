import '../../timer/models/timer_status.dart';

class DogProfile {
  const DogProfile({
    required this.breed,
    required this.name,
    required this.level,
    required this.experience,
    required this.treatCount,
    required this.inventory,
    required this.currentStatus,
  });

  factory DogProfile.initial() {
    return const DogProfile(
      breed: 'Maltese',
      name: '말티즈',
      level: 1,
      experience: 0,
      treatCount: 0,
      inventory: <String>[],
      currentStatus: TimerStatus.idle,
    );
  }

  final String breed;
  final String name;
  final int level;
  final int experience;
  final int treatCount;
  final List<String> inventory;
  final TimerStatus currentStatus;

  DogProfile copyWith({
    String? breed,
    String? name,
    int? level,
    int? experience,
    int? treatCount,
    List<String>? inventory,
    TimerStatus? currentStatus,
  }) {
    return DogProfile(
      breed: breed ?? this.breed,
      name: name ?? this.name,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      treatCount: treatCount ?? this.treatCount,
      inventory: inventory ?? this.inventory,
      currentStatus: currentStatus ?? this.currentStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'breed': breed,
      'name': name,
      'level': level,
      'experience': experience,
      'treatCount': treatCount,
      'inventory': inventory,
      'currentStatus': currentStatus.name,
    };
  }

  factory DogProfile.fromJson(Map<String, dynamic> json) {
    return DogProfile(
      breed: json['breed'] as String? ?? 'Maltese',
      name: json['name'] as String? ?? '말티즈',
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      treatCount: json['treatCount'] as int? ?? 0,
      inventory: (json['inventory'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(),
      currentStatus: TimerStatusX.fromName(
        json['currentStatus'] as String? ?? TimerStatus.idle.name,
      ),
    );
  }
}
