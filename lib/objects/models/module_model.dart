enum ModuleType { sensor, irrigation, lighting, ventilation, heating }

enum ModuleStatus { online, offline, error, calibrating }

class ModuleModel {
  final String id;
  final String? gardenId;
  final String userId;
  final String name;
  final String? description;
  final ModuleType type;
  final ModuleStatus status;
  final String? firmwareVersion;
  final String? imageUrl;
  final Map<String, dynamic>? settings;
  final DateTime? lastSyncAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ModuleModel({
    required this.id,
    this.gardenId,
    required this.userId,
    required this.name,
    this.description,
    required this.type,
    this.status = ModuleStatus.offline,
    this.firmwareVersion,
    this.imageUrl,
    this.settings,
    this.lastSyncAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String,
      gardenId: json['garden_id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: ModuleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ModuleType.sensor,
      ),
      status: ModuleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ModuleStatus.offline,
      ),
      firmwareVersion: json['firmware_version'] as String?,
      imageUrl: json['image_url'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
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
      'description': description,
      'type': type.name,
      'status': status.name,
      'firmware_version': firmwareVersion,
      'image_url': imageUrl,
      'settings': settings,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ModuleModel copyWith({
    String? id,
    String? gardenId,
    String? userId,
    String? name,
    String? description,
    ModuleType? type,
    ModuleStatus? status,
    String? firmwareVersion,
    String? imageUrl,
    Map<String, dynamic>? settings,
    DateTime? lastSyncAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      gardenId: gardenId ?? this.gardenId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      imageUrl: imageUrl ?? this.imageUrl,
      settings: settings ?? this.settings,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeIcon {
    switch (type) {
      case ModuleType.sensor:
        return 'sensors';
      case ModuleType.irrigation:
        return 'water_drop';
      case ModuleType.lighting:
        return 'light_mode';
      case ModuleType.ventilation:
        return 'air';
      case ModuleType.heating:
        return 'thermostat';
    }
  }

  bool get isOnline => status == ModuleStatus.online;
}
