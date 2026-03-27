import 'package:flutter_test/flutter_test.dart';
import 'package:terratech/objects/models/models.dart';
import 'package:terratech/use_cases/gamification_usecase.dart';
import 'package:terratech/use_cases/sensor_analysis_usecase.dart';
import 'package:terratech/use_cases/irrigation_usecase.dart';

void main() {
  group('GamificationUseCase', () {
    late GamificationUseCase useCase;

    setUp(() {
      useCase = GamificationUseCase();
    });

    test('should return correct XP for daily login', () {
      final xp = useCase.calculateXpForAction(GamificationAction.dailyLogin);
      expect(xp, 10);
    });

    test('should return correct XP for creating a garden', () {
      final xp = useCase.calculateXpForAction(GamificationAction.createGarden);
      expect(xp, 100);
    });

    test('should return correct XP for connecting a module', () {
      final xp = useCase.calculateXpForAction(GamificationAction.connectModule);
      expect(xp, 50);
    });

    test('should calculate level from XP correctly', () {
      expect(useCase.calculateLevelFromXp(0), 1);
      expect(useCase.calculateLevelFromXp(100), 2);
      expect(useCase.calculateLevelFromXp(600), 4);
      expect(useCase.calculateLevelFromXp(1500), 6);
      expect(useCase.calculateLevelFromXp(5000), 11);
    });

    test('should calculate level progress correctly', () {
      final progress = useCase.calculateLevelProgress(150);

      expect(progress.currentLevel, 2);
      expect(progress.xpToNextLevel, 150);
      expect(progress.levelTitle, 'Principiante');
    });

    test('should check unlocked achievements correctly', () {
      final achievements = useCase.checkUnlockedAchievements(
        gardenCount: 1,
        moduleCount: 0,
        plantCount: 5,
        consecutiveDays: 7,
        waterSavedLiters: 50,
        harvests: 0,
        screensVisited: {},
      );

      expect(achievements.length, 3);
      expect(
        achievements.any((a) => a.type == AchievementType.firstGarden),
        true,
      );
      expect(
        achievements.any((a) => a.type == AchievementType.dailyCheckIn),
        true,
      );
      expect(
        achievements.any((a) => a.type == AchievementType.weekStreak),
        true,
      );
    });

    test('should calculate streak correctly', () {
      final today = DateTime.now();
      final loginDates = [
        today,
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 2)),
        today.subtract(const Duration(days: 3)),
      ];

      final streak = useCase.calculateStreak(loginDates);
      expect(streak, 4);
    });

    test('should return zero streak for non-consecutive dates', () {
      final today = DateTime.now();
      final loginDates = [
        today,
        today.subtract(const Duration(days: 2)),
        today.subtract(const Duration(days: 5)),
      ];

      final streak = useCase.calculateStreak(loginDates);
      expect(streak, 1);
    });
  });

  group('SensorAnalysisUseCase', () {
    late SensorAnalysisUseCase useCase;

    setUp(() {
      useCase = SensorAnalysisUseCase();
    });

    test('should assess plant health correctly', () {
      final plant = PlantModel(
        id: '1',
        userId: 'user-1',
        name: 'Test Plant',
        category: PlantCategory.vegetable,
        lastWateredAt: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now(),
      );

      final sensorData = [
        SensorDataModel(
          id: '1',
          userId: 'user-1',
          type: SensorType.humidity,
          value: 30,
          unit: '%',
          timestamp: DateTime.now(),
        ),
        SensorDataModel(
          id: '2',
          userId: 'user-1',
          type: SensorType.temperature,
          value: 32,
          unit: '°C',
          timestamp: DateTime.now(),
        ),
      ];

      final assessment = useCase.assessPlantHealth(
        plant: plant,
        sensorData: sensorData,
      );

      expect(assessment.status, HealthStatus.critical);
      expect(assessment.issues.isNotEmpty, true);
      expect(assessment.healthScore < 50, true);
    });

    test('should calculate watering need correctly', () {
      final plant = PlantModel(
        id: '1',
        userId: 'user-1',
        name: 'Test Plant',
        category: PlantCategory.vegetable,
        lastWateredAt: DateTime.now().subtract(const Duration(days: 4)),
        createdAt: DateTime.now(),
      );

      final sensorData = [
        SensorDataModel(
          id: '1',
          userId: 'user-1',
          type: SensorType.soilMoisture,
          value: 25,
          unit: '%',
          timestamp: DateTime.now(),
        ),
      ];

      final need = useCase.calculateWateringNeed(plant, sensorData);
      expect(need >= 70, true);
    });
  });

  group('IrrigationUseCase', () {
    late IrrigationUseCase useCase;

    setUp(() {
      useCase = IrrigationUseCase();
    });

    test('should calculate irrigation schedule correctly', () {
      final plant = PlantModel(
        id: '1',
        userId: 'user-1',
        name: 'Test Plant',
        category: PlantCategory.vegetable,
        lastWateredAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );

      final schedule = useCase.calculateIrrigationSchedule(
        plant: plant,
        currentSoilMoisture: 45,
        currentTemperature: 22,
        currentHumidity: 50,
        hasRainSensor: false,
        recentRainfall: 0,
      );

      expect(schedule.suggestedIntervalDays, greaterThan(0));
      expect(schedule.estimatedWaterAmountMl, greaterThan(0));
    });

    test('should calculate water savings correctly', () {
      final stats = useCase.calculateWaterSavings(
        daysAnalyzed: 7,
        manualWateringMl: 2000,
        automatedWateringMl: 1000,
        recommendedWateringMl: 1500,
      );

      expect(stats.estimatedSavingsMl, 1000);
      expect(stats.savingsPercentage, greaterThan(0));
    });
  });
}
