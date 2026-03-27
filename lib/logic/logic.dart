import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../objects/models/models.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final int xp;
  final int level;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.displayName,
    this.xp = 0,
    this.level = 1,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? displayName,
    int? xp,
    int? level,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  double get levelProgress => xp / (level * 100);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((data) {
      if (data.session != null) {
        _loadUserProfile();
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });

    final user = _authService.currentUser;
    if (user != null) {
      _loadUserProfile();
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      userId: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      xp: user.userMetadata?['xp'] as int? ?? 0,
      level: user.userMetadata?['level'] as int? ?? 1,
    );
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      await _loadUserProfile();
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Error inesperado. Inténtalo de nuevo.',
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Error inesperado. Inténtalo de nuevo.',
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.signInWithGoogle();
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Error inesperado. Inténtalo de nuevo.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    try {
      await _authService.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      await _loadUserProfile();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al actualizar perfil');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final gardensProvider = FutureProvider<List<GardenModel>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getGardens();
});

final modulesProvider = FutureProvider<List<ModuleModel>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getModules();
});

final plantsProvider = FutureProvider<List<PlantModel>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getPlants();
});

final achievementsProvider = FutureProvider<List<AchievementModel>>((
  ref,
) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getAchievements();
});

final selectedGardenProvider = StateProvider<GardenModel?>((ref) => null);
final selectedModuleProvider = StateProvider<ModuleModel?>((ref) => null);

class GardensNotifier extends StateNotifier<AsyncValue<List<GardenModel>>> {
  final DatabaseService _dbService;

  GardensNotifier(this._dbService) : super(const AsyncValue.loading());

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final gardens = await _dbService.getGardens();
      state = AsyncValue.data(gardens);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<GardenModel> createGarden(GardenModel garden) async {
    final newGarden = await _dbService.createGarden(garden);
    await refresh();
    return newGarden;
  }

  Future<void> updateGarden(GardenModel garden) async {
    await _dbService.updateGarden(garden);
    await refresh();
  }

  Future<void> deleteGarden(String id) async {
    await _dbService.deleteGarden(id);
    await refresh();
  }
}

final gardensNotifierProvider =
    StateNotifierProvider<GardensNotifier, AsyncValue<List<GardenModel>>>((
      ref,
    ) {
      final dbService = ref.watch(databaseServiceProvider);
      return GardensNotifier(dbService);
    });

class ModulesNotifier extends StateNotifier<AsyncValue<List<ModuleModel>>> {
  final DatabaseService _dbService;

  ModulesNotifier(this._dbService) : super(const AsyncValue.loading());

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final modules = await _dbService.getModules();
      state = AsyncValue.data(modules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ModuleModel> createModule(ModuleModel module) async {
    final newModule = await _dbService.createModule(module);
    await refresh();
    return newModule;
  }

  Future<void> updateModule(ModuleModel module) async {
    await _dbService.updateModule(module);
    await refresh();
  }

  Future<void> deleteModule(String id) async {
    await _dbService.deleteModule(id);
    await refresh();
  }
}

final modulesNotifierProvider =
    StateNotifierProvider<ModulesNotifier, AsyncValue<List<ModuleModel>>>((
      ref,
    ) {
      final dbService = ref.watch(databaseServiceProvider);
      return ModulesNotifier(dbService);
    });

class PlantsNotifier extends StateNotifier<AsyncValue<List<PlantModel>>> {
  final DatabaseService _dbService;

  PlantsNotifier(this._dbService) : super(const AsyncValue.loading());

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final plants = await _dbService.getPlants();
      state = AsyncValue.data(plants);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<PlantModel> createPlant(PlantModel plant) async {
    final newPlant = await _dbService.createPlant(plant);
    await refresh();
    return newPlant;
  }

  Future<void> updatePlant(PlantModel plant) async {
    await _dbService.updatePlant(plant);
    await refresh();
  }

  Future<void> deletePlant(String id) async {
    await _dbService.deletePlant(id);
    await refresh();
  }
}

final plantsNotifierProvider =
    StateNotifierProvider<PlantsNotifier, AsyncValue<List<PlantModel>>>((ref) {
      final dbService = ref.watch(databaseServiceProvider);
      return PlantsNotifier(dbService);
    });

final dashboardSensorDataProvider = Provider<List<SensorReading>>((ref) {
  return [
    const SensorReading(
      current: 55,
      min: 0,
      max: 100,
      optimalMin: 40,
      optimalMax: 60,
      unit: '%',
    ),
    const SensorReading(
      current: 22,
      min: -10,
      max: 50,
      optimalMin: 18,
      optimalMax: 26,
      unit: '°C',
    ),
    const SensorReading(
      current: 42,
      min: 0,
      max: 100,
      optimalMin: 30,
      optimalMax: 50,
      unit: '%',
    ),
    const SensorReading(
      current: 7,
      min: 0,
      max: 15,
      optimalMin: 6,
      optimalMax: 10,
      unit: 'k lux',
    ),
  ];
});
