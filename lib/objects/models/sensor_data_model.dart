enum SensorType {
  humidity,
  temperature,
  light,
  soilMoisture,
  ph,
  co2,
  wind,
  rain,
}

class SensorDataModel {
  final String id;
  final String? moduleId;
  final String? gardenId;
  final String userId;
  final SensorType type;
  final double value;
  final String unit;
  final DateTime timestamp;

  const SensorDataModel({
    required this.id,
    this.moduleId,
    this.gardenId,
    required this.userId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      id: json['id'] as String,
      moduleId: json['module_id'] as String?,
      gardenId: json['garden_id'] as String?,
      userId: json['user_id'] as String,
      type: SensorType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SensorType.humidity,
      ),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'garden_id': gardenId,
      'user_id': userId,
      'type': type.name,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get displayName {
    switch (type) {
      case SensorType.humidity:
        return 'Humedad';
      case SensorType.temperature:
        return 'Temperatura';
      case SensorType.light:
        return 'Luz';
      case SensorType.soilMoisture:
        return 'Humedad del suelo';
      case SensorType.ph:
        return 'pH';
      case SensorType.co2:
        return 'CO₂';
      case SensorType.wind:
        return 'Viento';
      case SensorType.rain:
        return 'Lluvia';
    }
  }

  String get icon {
    switch (type) {
      case SensorType.humidity:
        return 'water_drop';
      case SensorType.temperature:
        return 'thermostat';
      case SensorType.light:
        return 'light_mode';
      case SensorType.soilMoisture:
        return 'grass';
      case SensorType.ph:
        return 'science';
      case SensorType.co2:
        return 'cloud';
      case SensorType.wind:
        return 'air';
      case SensorType.rain:
        return 'umbrella';
    }
  }

  bool get isOptimal {
    switch (type) {
      case SensorType.humidity:
        return value >= 40 && value <= 60;
      case SensorType.temperature:
        return value >= 18 && value <= 26;
      case SensorType.light:
        return value >= 6 && value <= 10;
      case SensorType.soilMoisture:
        return value >= 30 && value <= 50;
      case SensorType.ph:
        return value >= 6.0 && value <= 7.0;
      case SensorType.co2:
        return value >= 350 && value <= 450;
      default:
        return true;
    }
  }
}

class SensorReading {
  final double current;
  final double min;
  final double max;
  final double optimalMin;
  final double optimalMax;
  final String unit;
  final DateTime? timestamp;

  const SensorReading({
    required this.current,
    required this.min,
    required this.max,
    required this.optimalMin,
    required this.optimalMax,
    required this.unit,
    this.timestamp,
  });

  double get percentage => ((current - min) / (max - min)).clamp(0.0, 1.0);
  bool get isOptimal => current >= optimalMin && current <= optimalMax;
}
