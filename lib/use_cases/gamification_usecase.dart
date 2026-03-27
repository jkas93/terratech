import '../objects/models/models.dart';

class GamificationUseCase {
  int calculateXpForAction(GamificationAction action) {
    switch (action) {
      case GamificationAction.dailyLogin:
        return 10;
      case GamificationAction.viewGarden:
        return 5;
      case GamificationAction.addPlant:
        return 25;
      case GamificationAction.waterPlant:
        return 10;
      case GamificationAction.fertilizePlant:
        return 15;
      case GamificationAction.connectModule:
        return 50;
      case GamificationAction.createGarden:
        return 100;
      case GamificationAction.harvestPlant:
        return 150;
      case GamificationAction.completeTutorial:
        return 30;
      case GamificationAction.shareAchievement:
        return 20;
      case GamificationAction.referFriend:
        return 200;
    }
  }

  int calculateLevelFromXp(int totalXp) {
    if (totalXp < 100) return 1;
    if (totalXp < 300) return 2;
    if (totalXp < 600) return 3;
    if (totalXp < 1000) return 4;
    if (totalXp < 1500) return 5;
    if (totalXp < 2100) return 6;
    if (totalXp < 2800) return 7;
    if (totalXp < 3600) return 8;
    if (totalXp < 4500) return 9;
    return 10 + ((totalXp - 4500) ~/ 1000);
  }

  int xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    if (level == 2) return 100;
    if (level == 3) return 300;
    if (level == 4) return 600;
    if (level == 5) return 1000;
    if (level == 6) return 1500;
    if (level == 7) return 2100;
    if (level == 8) return 2800;
    if (level == 9) return 3600;
    return 4500 + ((level - 10) * 1000);
  }

  LevelProgress calculateLevelProgress(int currentXp) {
    final currentLevel = calculateLevelFromXp(currentXp);
    final currentLevelXp = xpRequiredForLevel(currentLevel);
    final nextLevelXp = xpRequiredForLevel(currentLevel + 1);
    final xpInCurrentLevel = currentXp - currentLevelXp;
    final xpNeededForNextLevel = nextLevelXp - currentLevelXp;
    final progress = xpInCurrentLevel / xpNeededForNextLevel;

    return LevelProgress(
      currentLevel: currentLevel,
      currentXp: currentXp,
      xpToNextLevel: xpNeededForNextLevel - xpInCurrentLevel,
      progress: progress.clamp(0.0, 1.0),
      levelTitle: _getLevelTitle(currentLevel),
    );
  }

  String _getLevelTitle(int level) {
    if (level < 3) return 'Principiante';
    if (level < 5) return 'Aprendiz';
    if (level < 8) return 'Cultivador';
    if (level < 10) return 'Experto';
    if (level < 15) return 'Maestro';
    return 'Leyenda Verde';
  }

  List<AchievementModel> checkUnlockedAchievements({
    required int gardenCount,
    required int moduleCount,
    required int plantCount,
    required int consecutiveDays,
    required int waterSavedLiters,
    required int harvests,
    required Set<String> screensVisited,
  }) {
    final unlocked = <AchievementModel>[];

    if (gardenCount >= 1) {
      final achievement = AchievementModel.allAchievements.firstWhere(
        (a) => a.type == AchievementType.firstGarden,
        orElse: () => AchievementModel(
          id: 'first_garden',
          name: 'Primer Jardín',
          description: 'Crea tu primer jardín',
          type: AchievementType.firstGarden,
          xpReward: 50,
        ),
      );
      unlocked.add(
        achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    if (moduleCount >= 1) {
      final achievement = AchievementModel.allAchievements.firstWhere(
        (a) => a.type == AchievementType.firstModule,
        orElse: () => AchievementModel(
          id: 'first_module',
          name: 'Primer Módulo',
          description: 'Conecta tu primer sensor',
          type: AchievementType.firstModule,
          xpReward: 30,
        ),
      );
      unlocked.add(
        achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    if (consecutiveDays >= 1) {
      final achievement = AchievementModel.allAchievements.firstWhere(
        (a) => a.type == AchievementType.dailyCheckIn,
        orElse: () => AchievementModel(
          id: 'daily_checkin',
          name: 'Check-in Diario',
          description: 'Revisa tu jardín cada día',
          type: AchievementType.dailyCheckIn,
          xpReward: 10,
        ),
      );
      unlocked.add(
        achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    if (consecutiveDays >= 7) {
      final achievement = AchievementModel.allAchievements.firstWhere(
        (a) => a.type == AchievementType.weekStreak,
        orElse: () => AchievementModel(
          id: 'week_streak',
          name: 'Racha de 7 días',
          description: 'Mantén tu racha durante 7 días',
          type: AchievementType.weekStreak,
          xpReward: 100,
        ),
      );
      unlocked.add(
        achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    if (consecutiveDays >= 30) {
      final achievement = AchievementModel.allAchievements.firstWhere(
        (a) => a.type == AchievementType.monthStreak,
        orElse: () => AchievementModel(
          id: 'month_streak',
          name: 'Racha de 30 días',
          description: 'Mantén tu racha durante 30 días',
          type: AchievementType.monthStreak,
          xpReward: 500,
        ),
      );
      unlocked.add(
        achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    if (plantCount >= 10) {
      final achievement = AchievementModel.allAchievements.firstWhere(
        (a) => a.type == AchievementType.plantMaster,
        orElse: () => AchievementModel(
          id: 'plant_master',
          name: 'Maestro de Plantas',
          description: 'Cuida 10 plantas diferentes',
          type: AchievementType.plantMaster,
          xpReward: 200,
        ),
      );
      unlocked.add(
        achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    if (moduleCount >= 5) {
      final achievement = AchievementModel.allAchievements.firstWhere(
        (a) => a.type == AchievementType.sensorMaster,
        orElse: () => AchievementModel(
          id: 'sensor_master',
          name: 'Maestro de Sensores',
          description: 'Conecta 5 sensores',
          type: AchievementType.sensorMaster,
          xpReward: 150,
        ),
      );
      unlocked.add(
        achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    if (waterSavedLiters >= 100) {
      final achievement = AchievementModel.allAchievements.firstWhere(
        (a) => a.type == AchievementType.waterSaver,
        orElse: () => AchievementModel(
          id: 'water_saver',
          name: 'Ahorrador de Agua',
          description: 'Ahorra 100L de agua',
          type: AchievementType.waterSaver,
          xpReward: 100,
        ),
      );
      unlocked.add(
        achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    if (harvests >= 1) {
      final achievement = AchievementModel.allAchievements.firstWhere(
        (a) => a.type == AchievementType.harvestTime,
        orElse: () => AchievementModel(
          id: 'harvest_time',
          name: 'Hora de Cosecha',
          description: 'Cosecha tu primera planta',
          type: AchievementType.harvestTime,
          xpReward: 250,
        ),
      );
      unlocked.add(
        achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    return unlocked;
  }

  int calculateStreak(List<DateTime> loginDates) {
    if (loginDates.isEmpty) return 0;

    final sortedDates = loginDates.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (sortedDates.isEmpty) return 0;

    final normalizedFirstDate = DateTime(
      sortedDates.first.year,
      sortedDates.first.month,
      sortedDates.first.day,
    );

    if (normalizedFirstDate.difference(normalizedToday).inDays.abs() > 1) {
      return 0;
    }

    int streak = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final current = DateTime(
        sortedDates[i].year,
        sortedDates[i].month,
        sortedDates[i].day,
      );
      final previous = DateTime(
        sortedDates[i - 1].year,
        sortedDates[i - 1].month,
        sortedDates[i - 1].day,
      );

      if (previous.difference(current).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}

enum GamificationAction {
  dailyLogin,
  viewGarden,
  addPlant,
  waterPlant,
  fertilizePlant,
  connectModule,
  createGarden,
  harvestPlant,
  completeTutorial,
  shareAchievement,
  referFriend,
}

class LevelProgress {
  final int currentLevel;
  final int currentXp;
  final int xpToNextLevel;
  final double progress;
  final String levelTitle;

  const LevelProgress({
    required this.currentLevel,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.progress,
    required this.levelTitle,
  });
}
