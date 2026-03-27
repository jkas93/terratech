class GardenModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? location;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final int plantCount;
  final int moduleCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GardenModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.location,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.imageUrl,
    this.plantCount = 0,
    this.moduleCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory GardenModel.fromJson(Map<String, dynamic> json) {
    return GardenModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      plantCount: json['plant_count'] as int? ?? 0,
      moduleCount: json['module_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'plant_count': plantCount,
      'module_count': moduleCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  GardenModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    int? plantCount,
    int? moduleCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GardenModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      plantCount: plantCount ?? this.plantCount,
      moduleCount: moduleCount ?? this.moduleCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
