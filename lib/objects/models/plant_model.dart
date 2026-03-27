enum PlantCategory {
  vegetable,
  fruit,
  herb,
  flower,
  succulent,
  indoor,
  outdoor,
}

class PlantModel {
  final String id;
  final String? gardenId;
  final String userId;
  final String name;
  final String? scientificName;
  final PlantCategory category;
  final String? imageUrl;
  final String? description;
  final double? currentHumidity;
  final double? currentTemperature;
  final double? currentLight;
  final String? healthStatus;
  final DateTime? plantedAt;
  final DateTime? lastWateredAt;
  final DateTime? lastFertilizedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PlantModel({
    required this.id,
    this.gardenId,
    required this.userId,
    required this.name,
    this.scientificName,
    required this.category,
    this.imageUrl,
    this.description,
    this.currentHumidity,
    this.currentTemperature,
    this.currentLight,
    this.healthStatus,
    this.plantedAt,
    this.lastWateredAt,
    this.lastFertilizedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] as String,
      gardenId: json['garden_id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String?,
      category: PlantCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PlantCategory.vegetable,
      ),
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      currentHumidity: (json['current_humidity'] as num?)?.toDouble(),
      currentTemperature: (json['current_temperature'] as num?)?.toDouble(),
      currentLight: (json['current_light'] as num?)?.toDouble(),
      healthStatus: json['health_status'] as String?,
      plantedAt: json['planted_at'] != null
          ? DateTime.parse(json['planted_at'] as String)
          : null,
      lastWateredAt: json['last_watered_at'] != null
          ? DateTime.parse(json['last_watered_at'] as String)
          : null,
      lastFertilizedAt: json['last_fertilized_at'] != null
          ? DateTime.parse(json['last_fertilized_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'garden_id': gardenId,
      'user_id': userId,
      'name': name,
      'scientific_name': scientificName,
      'category': category.name,
      'image_url': imageUrl,
      'description': description,
      'current_humidity': currentHumidity,
      'current_temperature': currentTemperature,
      'current_light': currentLight,
      'health_status': healthStatus,
      'planted_at': plantedAt?.toIso8601String(),
      'last_watered_at': lastWateredAt?.toIso8601String(),
      'last_fertilized_at': lastFertilizedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PlantModel copyWith({
    String? id,
    String? gardenId,
    String? userId,
    String? name,
    String? scientificName,
    PlantCategory? category,
    String? imageUrl,
    String? description,
    double? currentHumidity,
    double? currentTemperature,
    double? currentLight,
    String? healthStatus,
    DateTime? plantedAt,
    DateTime? lastWateredAt,
    DateTime? lastFertilizedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlantModel(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      currentHumidity: currentHumidity ?? this.currentHumidity,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      currentLight: currentLight ?? this.currentLight,
      healthStatus: healthStatus ?? this.healthStatus,
      plantedAt: plantedAt ?? this.plantedAt,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      lastFertilizedAt: lastFertilizedAt ?? this.lastFertilizedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get categoryName {
    switch (category) {
      case PlantCategory.vegetable:
        return 'Hortaliza';
      case PlantCategory.fruit:
        return 'Fruta';
      case PlantCategory.herb:
        return 'Hierba';
      case PlantCategory.flower:
        return 'Flor';
      case PlantCategory.succulent:
        return 'Suculenta';
      case PlantCategory.indoor:
        return 'Interior';
      case PlantCategory.outdoor:
        return 'Exterior';
    }
  }

  bool get needsWater {
    if (lastWateredAt == null) return true;
    return DateTime.now().difference(lastWateredAt!).inDays >= 2;
  }

  bool get needsFertilizer {
    if (lastFertilizedAt == null) return true;
    return DateTime.now().difference(lastFertilizedAt!).inDays >= 14;
  }
}
