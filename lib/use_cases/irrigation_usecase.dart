import '../objects/models/models.dart';

class IrrigationUseCase {
  final double _optimalSoilMoistureMin = 30.0;
  final double _optimalSoilMoistureMax = 50.0;
  final int _baseWateringIntervalDays = 2;
  final double _temperatureFactor = 0.5;

  IrrigationSchedule calculateIrrigationSchedule({
    required PlantModel plant,
    required double currentSoilMoisture,
    required double currentTemperature,
    required double currentHumidity,
    required bool hasRainSensor,
    required double recentRainfall,
  }) {
    final baseInterval = _baseWateringIntervalDays.toDouble();

    double temperatureAdjustment = 0;
    if (currentTemperature > 25) {
      temperatureAdjustment = (currentTemperature - 25) * _temperatureFactor;
    }

    double humidityAdjustment = 0;
    if (currentHumidity < 40) {
      humidityAdjustment = (40 - currentHumidity) / 10;
    }

    double rainfallAdjustment = 0;
    if (hasRainSensor && recentRainfall > 0) {
      rainfallAdjustment = -recentRainfall / 10;
    }

    double moistureAdjustment = 0;
    if (currentSoilMoisture > _optimalSoilMoistureMax) {
      moistureAdjustment = (currentSoilMoisture - _optimalSoilMoistureMax) / 5;
    } else if (currentSoilMoisture < _optimalSoilMoistureMin) {
      moistureAdjustment = -(_optimalSoilMoistureMin - currentSoilMoisture) / 5;
    }

    final adjustedInterval =
        (baseInterval +
                temperatureAdjustment +
                humidityAdjustment +
                rainfallAdjustment +
                moistureAdjustment)
            .clamp(0.5, 7.0);

    final nextWateringDate = plant.lastWateredAt?.add(
      Duration(hours: (adjustedInterval * 24).round()),
    );

    final urgency = _calculateUrgency(
      currentSoilMoisture: currentSoilMoisture,
      lastWateredAt: plant.lastWateredAt,
      temperature: currentTemperature,
    );

    return IrrigationSchedule(
      suggestedIntervalDays: adjustedInterval,
      nextWateringDate: nextWateringDate ?? DateTime.now(),
      estimatedWaterAmountMl: _estimateWaterAmount(
        currentTemperature,
        plant.category,
      ),
      urgency: urgency,
      reason: _generateReason(
        currentSoilMoisture: currentSoilMoisture,
        temperature: currentTemperature,
        humidity: currentHumidity,
        rainfall: recentRainfall,
      ),
    );
  }

  double _calculateUrgency({
    required double currentSoilMoisture,
    required DateTime? lastWateredAt,
    required double temperature,
  }) {
    double urgency = 0;

    if (currentSoilMoisture < 20) {
      urgency += 50;
    } else if (currentSoilMoisture < _optimalSoilMoistureMin) {
      urgency += 30;
    } else if (currentSoilMoisture < 30) {
      urgency += 10;
    }

    if (lastWateredAt != null) {
      final daysSinceWatering = DateTime.now().difference(lastWateredAt).inDays;
      if (daysSinceWatering >= 4) {
        urgency += 30;
      } else if (daysSinceWatering >= 2) {
        urgency += 15;
      }
    }

    if (temperature > 30) {
      urgency += 20;
    }

    return urgency.clamp(0, 100);
  }

  double _estimateWaterAmount(double temperature, PlantCategory category) {
    double baseAmount;

    switch (category) {
      case PlantCategory.vegetable:
        baseAmount = 250;
        break;
      case PlantCategory.fruit:
        baseAmount = 300;
        break;
      case PlantCategory.herb:
        baseAmount = 150;
        break;
      case PlantCategory.flower:
        baseAmount = 200;
        break;
      case PlantCategory.succulent:
        baseAmount = 50;
        break;
      case PlantCategory.indoor:
        baseAmount = 150;
        break;
      case PlantCategory.outdoor:
        baseAmount = 350;
        break;
    }

    if (temperature > 28) {
      baseAmount *= 1.2;
    } else if (temperature < 15) {
      baseAmount *= 0.7;
    }

    return baseAmount;
  }

  String _generateReason({
    required double currentSoilMoisture,
    required double temperature,
    required double humidity,
    required double rainfall,
  }) {
    if (currentSoilMoisture < 20) {
      return 'El suelo está muy seco. Es necesario regar urgentemente.';
    }

    if (currentSoilMoisture < _optimalSoilMoistureMin) {
      return 'La humedad del suelo está por debajo del nivel óptimo.';
    }

    if (temperature > 30) {
      return 'La alta temperatura incrementa la evaporación. Se recomienda riego.';
    }

    if (humidity < 30) {
      return 'La baja humedad ambiental acelera la pérdida de agua.';
    }

    if (rainfall > 0) {
      return 'La lluvia reciente ha contribuido a la hidratación de la planta.';
    }

    return 'Condiciones normales. El riego puede esperar.';
  }

  WaterUsageStatistics calculateWaterSavings({
    required int daysAnalyzed,
    required double manualWateringMl,
    required double automatedWateringMl,
    required double recommendedWateringMl,
  }) {
    final manualSavings = manualWateringMl - recommendedWateringMl;
    final automatedSavings = automatedWateringMl - recommendedWateringMl;
    final totalSavings = manualSavings + automatedSavings;

    return WaterUsageStatistics(
      daysAnalyzed: daysAnalyzed,
      totalManualWateringMl: manualWateringMl,
      totalAutomatedWateringMl: automatedWateringMl,
      recommendedWateringMl: recommendedWateringMl,
      estimatedSavingsMl: totalSavings.abs(),
      savingsPercentage: recommendedWateringMl > 0
          ? (totalSavings.abs() / recommendedWateringMl * 100).clamp(0, 100)
          : 0,
      averageDailyUsageMl:
          (manualWateringMl + automatedWateringMl) / daysAnalyzed,
    );
  }
}

class IrrigationSchedule {
  final double suggestedIntervalDays;
  final DateTime nextWateringDate;
  final double estimatedWaterAmountMl;
  final double urgency;
  final String reason;

  const IrrigationSchedule({
    required this.suggestedIntervalDays,
    required this.nextWateringDate,
    required this.estimatedWaterAmountMl,
    required this.urgency,
    required this.reason,
  });

  bool get isUrgent => urgency >= 70;
  bool get isRecommended => urgency >= 40;
}

class WaterUsageStatistics {
  final int daysAnalyzed;
  final double totalManualWateringMl;
  final double totalAutomatedWateringMl;
  final double recommendedWateringMl;
  final double estimatedSavingsMl;
  final double savingsPercentage;
  final double averageDailyUsageMl;

  const WaterUsageStatistics({
    required this.daysAnalyzed,
    required this.totalManualWateringMl,
    required this.totalAutomatedWateringMl,
    required this.recommendedWateringMl,
    required this.estimatedSavingsMl,
    required this.savingsPercentage,
    required this.averageDailyUsageMl,
  });
}
