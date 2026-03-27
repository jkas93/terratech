import 'package:flutter_test/flutter_test.dart';
import 'package:terratech/objects/models/models.dart';
import 'package:terratech/use_cases/gamification_usecase.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from JSON', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'display_name': 'Test User',
        'avatar_url': 'https://example.com/avatar.png',
        'xp': 100,
        'level': 2,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.xp, 100);
      expect(user.level, 2);
    });

    test('should convert UserModel to JSON', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        displayName: 'Test User',
        xp: 100,
        level: 2,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['display_name'], 'Test User');
      expect(json['xp'], 100);
    });

    test('should calculate XP to next level correctly', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        level: 2,
        createdAt: DateTime.now(),
      );

      expect(user.xpToNextLevel, 200);
    });
  });

  group('SensorDataModel', () {
    test('should create SensorDataModel from JSON', () {
      final json = {
        'id': '456',
        'module_id': 'module-1',
        'garden_id': 'garden-1',
        'user_id': 'user-1',
        'type': 'humidity',
        'value': 55.5,
        'unit': '%',
        'timestamp': '2024-01-01T12:00:00.000Z',
      };

      final sensorData = SensorDataModel.fromJson(json);

      expect(sensorData.id, '456');
      expect(sensorData.type, SensorType.humidity);
      expect(sensorData.value, 55.5);
      expect(sensorData.unit, '%');
    });

    test('should determine optimal humidity correctly', () {
      final optimalSensor = SensorDataModel(
        id: '1',
        userId: 'user-1',
        type: SensorType.humidity,
        value: 50,
        unit: '%',
        timestamp: DateTime.now(),
      );

      final lowSensor = SensorDataModel(
        id: '2',
        userId: 'user-1',
        type: SensorType.humidity,
        value: 30,
        unit: '%',
        timestamp: DateTime.now(),
      );

      expect(optimalSensor.isOptimal, true);
      expect(lowSensor.isOptimal, false);
    });
  });

  group('PlantModel', () {
    test('should determine if plant needs water', () {
      final needsWater = PlantModel(
        id: '1',
        userId: 'user-1',
        name: 'Tomato',
        category: PlantCategory.vegetable,
        lastWateredAt: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now(),
      );

      final recentlyWatered = PlantModel(
        id: '2',
        userId: 'user-1',
        name: 'Basil',
        category: PlantCategory.herb,
        lastWateredAt: DateTime.now().subtract(const Duration(hours: 12)),
        createdAt: DateTime.now(),
      );

      expect(needsWater.needsWater, true);
      expect(recentlyWatered.needsWater, false);
    });

    test('should return category name correctly', () {
      final plant = PlantModel(
        id: '1',
        userId: 'user-1',
        name: 'Tomato',
        category: PlantCategory.vegetable,
        createdAt: DateTime.now(),
      );

      expect(plant.categoryName, 'Hortaliza');
    });
  });
}
