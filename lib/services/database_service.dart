import 'package:supabase_flutter/supabase_flutter.dart';
import '../objects/models/models.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<GardenModel>> getGardens() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('gardens')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => GardenModel.fromJson(json))
        .toList();
  }

  Future<GardenModel?> getGarden(String id) async {
    final response = await _client
        .from('gardens')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? GardenModel.fromJson(response) : null;
  }

  Future<GardenModel> createGarden(GardenModel garden) async {
    final response = await _client
        .from('gardens')
        .insert(garden.toJson())
        .select()
        .single();
    return GardenModel.fromJson(response);
  }

  Future<GardenModel> updateGarden(GardenModel garden) async {
    final response = await _client
        .from('gardens')
        .update(garden.toJson())
        .eq('id', garden.id)
        .select()
        .single();
    return GardenModel.fromJson(response);
  }

  Future<void> deleteGarden(String id) async {
    await _client.from('gardens').delete().eq('id', id);
  }

  Future<List<ModuleModel>> getModules({String? gardenId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    var query = _client.from('modules').select().eq('user_id', userId);
    if (gardenId != null) {
      query = query.eq('garden_id', gardenId);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((json) => ModuleModel.fromJson(json))
        .toList();
  }

  Future<ModuleModel> createModule(ModuleModel module) async {
    final response = await _client
        .from('modules')
        .insert(module.toJson())
        .select()
        .single();
    return ModuleModel.fromJson(response);
  }

  Future<ModuleModel> updateModule(ModuleModel module) async {
    final response = await _client
        .from('modules')
        .update(module.toJson())
        .eq('id', module.id)
        .select()
        .single();
    return ModuleModel.fromJson(response);
  }

  Future<void> deleteModule(String id) async {
    await _client.from('modules').delete().eq('id', id);
  }

  Future<List<PlantModel>> getPlants({String? gardenId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    var query = _client.from('plants').select().eq('user_id', userId);
    if (gardenId != null) {
      query = query.eq('garden_id', gardenId);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => PlantModel.fromJson(json)).toList();
  }

  Future<PlantModel> createPlant(PlantModel plant) async {
    final response = await _client
        .from('plants')
        .insert(plant.toJson())
        .select()
        .single();
    return PlantModel.fromJson(response);
  }

  Future<PlantModel> updatePlant(PlantModel plant) async {
    final response = await _client
        .from('plants')
        .update(plant.toJson())
        .eq('id', plant.id)
        .select()
        .single();
    return PlantModel.fromJson(response);
  }

  Future<void> deletePlant(String id) async {
    await _client.from('plants').delete().eq('id', id);
  }

  Future<List<SensorDataModel>> getSensorData({
    required String moduleId,
    int limit = 100,
  }) async {
    final response = await _client
        .from('sensor_data')
        .select()
        .eq('module_id', moduleId)
        .order('timestamp', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => SensorDataModel.fromJson(json))
        .toList();
  }

  Future<SensorDataModel> insertSensorData(SensorDataModel data) async {
    final response = await _client
        .from('sensor_data')
        .insert(data.toJson())
        .select()
        .single();
    return SensorDataModel.fromJson(response);
  }

  Future<UserModel?> getUserProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response != null ? UserModel.fromJson(response) : null;
  }

  Future<UserModel> updateUserProfile(UserModel profile) async {
    final response = await _client
        .from('user_profiles')
        .upsert(profile.toJson())
        .select()
        .single();
    return UserModel.fromJson(response);
  }

  Future<void> addXp(int amount) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.rpc(
      'add_xp',
      params: {'amount': amount, 'user_id_param': userId},
    );
  }

  Future<List<AchievementModel>> getAchievements() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return AchievementModel.allAchievements;

    final response = await _client
        .from('user_achievements')
        .select()
        .eq('user_id', userId);

    final unlockedIds = (response as List)
        .map((e) => e['achievement_id'] as String)
        .toSet();

    return AchievementModel.allAchievements.map((a) {
      if (unlockedIds.contains(a.id)) {
        return a.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return a;
    }).toList();
  }

  Future<void> unlockAchievement(String achievementId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('user_achievements').insert({
      'user_id': userId,
      'achievement_id': achievementId,
      'unlocked_at': DateTime.now().toIso8601String(),
    });

    final achievement = AchievementModel.allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found'),
    );

    await addXp(achievement.xpReward);
  }
}
