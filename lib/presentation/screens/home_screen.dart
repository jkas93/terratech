import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/logic.dart';
import '../../objects/models/models.dart';
import '../widgets/common/tt_app_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final gardensAsync = ref.watch(gardensNotifierProvider);
    final plantsAsync = ref.watch(plantsNotifierProvider);
    final modulesAsync = ref.watch(modulesNotifierProvider);

    return Scaffold(
      appBar: TtAppBar(
        title: 'Hola, ${authState.displayName ?? 'Usuario'} 👋',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(gardensNotifierProvider);
          ref.invalidate(plantsNotifierProvider);
          ref.invalidate(modulesNotifierProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildActiveModuleCard(context, gardensAsync, modulesAsync),
              const SizedBox(height: 24),
              _buildXpProgressCard(authState),
              const SizedBox(height: 24),
              _buildAdventureCard(context),
              const SizedBox(height: 24),
              _buildSensorOverview(context, ref),
              const SizedBox(height: 24),
              _buildPlantsCard(context, plantsAsync),
              const SizedBox(height: 24),
              _buildCarbonFootprintCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveModuleCard(
    BuildContext context,
    AsyncValue<List<GardenModel>> gardensAsync,
    AsyncValue<List<ModuleModel>> modulesAsync,
  ) {
    return gardensAsync.when(
      data: (gardens) {
        final garden = gardens.isNotEmpty ? gardens.first : null;
        final moduleCount = modulesAsync.maybeWhen(
          data: (modules) =>
              modules.where((m) => m.gardenId == garden?.id).length,
          orElse: () => 0,
        );
        final onlineCount = modulesAsync.maybeWhen(
          data: (modules) => modules.where((m) => m.isOnline).length,
          orElse: () => 0,
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.colorPrimaryDark,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPrimaryDark.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MÓDULO ACTIVO',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.colorTextMuted,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: onlineCount > 0 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$onlineCount/$moduleCount online',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                garden?.name ?? 'Mi TerraGarden',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                garden?.location ?? 'Sin ubicación',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBar(
                      label: 'SALUD',
                      value: 0.88,
                      color: AppColors.colorXPBar,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricBar(
                      label: 'CRECIMIENTO',
                      value: 0.62,
                      color: AppColors.colorSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(),
      error: (_, __) => _buildErrorCard('Error al cargar jardines'),
    );
  }

  Widget _buildMetricBar({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 8.0,
          percent: value,
          backgroundColor: Colors.white24,
          progressColor: color,
          barRadius: const Radius.circular(10),
          trailing: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildXpProgressCard(AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorSurfaceGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.colorPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${authState.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nivel ${authState.level}',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text('${authState.xp} XP', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 6.0,
                  percent: authState.levelProgress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white38,
                  progressColor: AppColors.colorPrimaryDark,
                  barRadius: const Radius.circular(10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdventureCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorSurfaceGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Listo para una nueva aventura?',
            style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Expande tu ecosistema con un módulo nuevo.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorPrimaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: const Text('Iniciar nueva construcción →'),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorOverview(BuildContext context, WidgetRef ref) {
    final sensorData = ref.watch(dashboardSensorDataProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sensores',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sensorData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final sensor = sensorData[index];
              return _buildSensorCard(sensor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSensorCard(SensorReading sensor) {
    IconData icon;
    switch (sensor.unit) {
      case '%':
        icon = Icons.water_drop;
        break;
      case '°C':
        icon = Icons.thermostat;
        break;
      case 'k lux':
        icon = Icons.light_mode;
        break;
      default:
        icon = Icons.sensors;
    }

    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sensor.isOptimal
              ? AppColors.colorXPBar
              : AppColors.colorError.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: sensor.isOptimal
                ? AppColors.colorPrimary
                : AppColors.colorError,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            '${sensor.current.toStringAsFixed(1)} ${sensor.unit}',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 4.0,
            percent: sensor.percentage,
            backgroundColor: Colors.grey.shade200,
            progressColor: sensor.isOptimal
                ? AppColors.colorXPBar
                : AppColors.colorError,
            barRadius: const Radius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantsCard(
    BuildContext context,
    AsyncValue<List<PlantModel>> plantsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Plantas',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
            ),
            TextButton(onPressed: () {}, child: const Text('Ver todas')),
          ],
        ),
        const SizedBox(height: 8),
        plantsAsync.when(
          data: (plants) {
            if (plants.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.grass_outlined,
                      size: 48,
                      color: AppColors.colorTextMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No tienes plantas aún',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            return SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: plants.length.clamp(0, 5),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return _buildPlantCard(plant);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildErrorCard('Error al cargar plantas'),
        ),
      ],
    );
  }

  Widget _buildPlantCard(PlantModel plant) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plant.needsWater ? Colors.orange : AppColors.colorXPBar,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            color: plant.needsWater ? Colors.orange : AppColors.colorPrimary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            plant.name,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (plant.needsWater)
            Text(
              '¡Regar!',
              style: TextStyle(color: Colors.orange, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildCarbonFootprintCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HUELLA DE CARBONO', style: AppTextStyles.labelSmall),
              const SizedBox(height: 8),
              Text(
                '-14.2 kg',
                style: AppTextStyles.heading.copyWith(fontSize: 40),
              ),
              const SizedBox(height: 4),
              Text('CO₂ offset este mes', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              Text(
                'Tu jardín virtual ha alcanzado una eficiencia fotosintética equivalente a un roble de 2 años.',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.eco_outlined,
              size: 80,
              color: AppColors.colorTextMuted.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.colorPrimaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.colorError),
          const SizedBox(width: 12),
          Text(message, style: TextStyle(color: AppColors.colorError)),
        ],
      ),
    );
  }
}
