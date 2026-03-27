enum AchievementType {
  firstGarden,
  firstModule,
  dailyCheckIn,
  weekStreak,
  monthStreak,
  plantMaster,
  sensorMaster,
  waterSaver,
  harvestTime,
  explorer,
  contributor,
}

class AchievementModel {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final int xpReward;
  final String? iconUrl;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.xpReward,
    this.iconUrl,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.firstGarden,
      ),
      xpReward: json['xp_reward'] as int,
      iconUrl: json['icon_url'] as String?,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'xp_reward': xpReward,
      'icon_url': iconUrl,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'is_unlocked': isUnlocked,
    };
  }

  AchievementModel copyWith({
    String? id,
    String? name,
    String? description,
    AchievementType? type,
    int? xpReward,
    String? iconUrl,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      xpReward: xpReward ?? this.xpReward,
      iconUrl: iconUrl ?? this.iconUrl,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  static List<AchievementModel> get allAchievements => [
    const AchievementModel(
      id: 'first_garden',
      name: 'Primer Jardín',
      description: 'Crea tu primer jardín',
      type: AchievementType.firstGarden,
      xpReward: 50,
    ),
    const AchievementModel(
      id: 'first_module',
      name: 'Primer Módulo',
      description: 'Conecta tu primer sensor',
      type: AchievementType.firstModule,
      xpReward: 30,
    ),
    const AchievementModel(
      id: 'daily_checkin',
      name: 'Check-in Diario',
      description: 'Revisa tu jardín cada día',
      type: AchievementType.dailyCheckIn,
      xpReward: 10,
    ),
    const AchievementModel(
      id: 'week_streak',
      name: 'Racha de 7 días',
      description: 'Mantén tu racha durante 7 días',
      type: AchievementType.weekStreak,
      xpReward: 100,
    ),
    const AchievementModel(
      id: 'month_streak',
      name: 'Racha de 30 días',
      description: 'Mantén tu racha durante 30 días',
      type: AchievementType.monthStreak,
      xpReward: 500,
    ),
    const AchievementModel(
      id: 'plant_master',
      name: 'Maestro de Plantas',
      description: 'Cuida 10 plantas diferentes',
      type: AchievementType.plantMaster,
      xpReward: 200,
    ),
    const AchievementModel(
      id: 'sensor_master',
      name: 'Maestro de Sensores',
      description: 'Conecta 5 sensores',
      type: AchievementType.sensorMaster,
      xpReward: 150,
    ),
    const AchievementModel(
      id: 'water_saver',
      name: 'Ahorrador de Agua',
      description: 'Ahorra 100L de agua',
      type: AchievementType.waterSaver,
      xpReward: 100,
    ),
    const AchievementModel(
      id: 'harvest_time',
      name: 'Hora de Cosecha',
      description: 'Cosecha tu primera planta',
      type: AchievementType.harvestTime,
      xpReward: 250,
    ),
    const AchievementModel(
      id: 'explorer',
      name: 'Explorador',
      description: 'Explora todas las pantallas',
      type: AchievementType.explorer,
      xpReward: 50,
    ),
  ];
}
