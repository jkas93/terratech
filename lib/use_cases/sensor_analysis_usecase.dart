import '../objects/models/models.dart';

class SensorAnalysisUseCase {
  double calculatePhotosyntheticEfficiency(List<SensorDataModel> data) {
    if (data.isEmpty) return 0.0;

    final lightData = data.where((d) => d.type == SensorType.light).toList();
    if (lightData.isEmpty) return 0.0;

    final avgLight =
        lightData.map((d) => d.value).reduce((a, b) => a + b) /
        lightData.length;
    final optimalLight = 7.5;
    final efficiency = (avgLight / optimalLight).clamp(0.0, 1.0);

    return efficiency * 100;
  }

  double calculateWateringNeed(
    PlantModel plant,
    List<SensorDataModel> sensorData,
  ) {
    double needScore = 0;

    final soilMoisture = sensorData
        .where((d) => d.type == SensorType.soilMoisture)
        .firstOrNull;

    if (soilMoisture != null) {
      if (soilMoisture.value < 30) {
        needScore += 40;
      } else if (soilMoisture.value < 40) {
        needScore += 20;
      }
    }

    if (plant.lastWateredAt != null) {
      final daysSinceWatering = DateTime.now()
          .difference(plant.lastWateredAt!)
          .inDays;
      if (daysSinceWatering >= 3) {
        needScore += 30;
      } else if (daysSinceWatering >= 2) {
        needScore += 15;
      }
    } else {
      needScore += 30;
    }

    final temperature = sensorData
        .where((d) => d.type == SensorType.temperature)
        .firstOrNull;

    if (temperature != null && temperature.value > 28) {
      needScore += 20;
    }

    return needScore.clamp(0, 100);
  }

  IrrigationRecommendation getIrrigationRecommendation(double wateringNeed) {
    if (wateringNeed >= 70) {
      return IrrigationRecommendation.urgent;
    } else if (wateringNeed >= 40) {
      return IrrigationRecommendation.recommended;
    } else if (wateringNeed >= 20) {
      return IrrigationRecommendation.optional;
    } else {
      return IrrigationRecommendation.notNeeded;
    }
  }

  PlantHealthAssessment assessPlantHealth({
    required PlantModel plant,
    required List<SensorDataModel> sensorData,
  }) {
    int issuesCount = 0;
    List<String> issues = [];
    List<String> recommendations = [];

    final humidity = sensorData
        .where((d) => d.type == SensorType.humidity)
        .firstOrNull;
    if (humidity != null && !humidity.isOptimal) {
      issuesCount++;
      if (humidity.value < 40) {
        issues.add('Humedad baja');
        recommendations.add('Considera aumentar la humedad rociando las hojas');
      } else {
        issues.add('Humedad alta');
        recommendations.add('Mejora la ventilación para reducir la humedad');
      }
    }

    final temperature = sensorData
        .where((d) => d.type == SensorType.temperature)
        .firstOrNull;
    if (temperature != null && !temperature.isOptimal) {
      issuesCount++;
      if (temperature.value < 18) {
        issues.add('Temperatura baja');
        recommendations.add('Protege la planta del frío');
      } else {
        issues.add('Temperatura alta');
        recommendations.add(
          'Proporciona sombra o move la planta a un lugar más fresco',
        );
      }
    }

    final light = sensorData
        .where((d) => d.type == SensorType.light)
        .firstOrNull;
    if (light != null && !light.isOptimal) {
      issuesCount++;
      if (light.value < 6) {
        issues.add('Luz insuficiente');
        recommendations.add('Mueve la planta a un lugar con más luz');
      } else {
        issues.add('Exceso de luz');
        recommendations.add('Protege la planta de la luz solar directa');
      }
    }

    final soilMoisture = sensorData
        .where((d) => d.type == SensorType.soilMoisture)
        .firstOrNull;
    if (soilMoisture != null && soilMoisture.value < 30) {
      issuesCount++;
      issues.add('Suelo seco');
      recommendations.add('Riega la planta inmediatamente');
    }

    if (plant.needsWater) {
      issuesCount++;
      issues.add('Necesita agua');
      recommendations.add('Riega la planta');
    }

    if (plant.needsFertilizer) {
      issuesCount++;
      issues.add('Necesita fertilizante');
      recommendations.add('Aplica fertilizante al suelo');
    }

    HealthStatus status;
    if (issuesCount == 0) {
      status = HealthStatus.healthy;
    } else if (issuesCount <= 2) {
      status = HealthStatus.warning;
    } else {
      status = HealthStatus.critical;
    }

    return PlantHealthAssessment(
      status: status,
      issues: issues,
      recommendations: recommendations,
      healthScore: ((4 - issuesCount) / 4 * 100).clamp(0, 100).toDouble(),
    );
  }
}

enum IrrigationRecommendation { urgent, recommended, optional, notNeeded }

class PlantHealthAssessment {
  final HealthStatus status;
  final List<String> issues;
  final List<String> recommendations;
  final double healthScore;

  const PlantHealthAssessment({
    required this.status,
    required this.issues,
    required this.recommendations,
    required this.healthScore,
  });
}

enum HealthStatus { healthy, warning, critical }
