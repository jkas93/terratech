import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/logic.dart';
import '../../objects/models/models.dart';
import '../../use_cases/use_cases.dart';
import '../widgets/common/tt_app_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

final selectedPlantProvider = StateProvider<PlantModel?>((ref) => null);

class MyGardenScreen extends ConsumerWidget {
  const MyGardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsNotifierProvider);
    final selectedPlant = ref.watch(selectedPlantProvider);

    return Scaffold(
      appBar: TtAppBar(
        title: 'Mi Jardín',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlantDialog(context, ref),
          ),
        ],
      ),
      body: plantsAsync.when(
        data: (plants) {
          if (plants.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPlantSelector(plants, ref, selectedPlant),
                if (selectedPlant != null)
                  _buildPlantDetails(context, ref, selectedPlant),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grass_outlined,
              size: 80,
              color: AppColors.colorTextMuted,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Tu jardín está vacío!',
              style: AppTextStyles.heading.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primera planta para comenzar',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddPlantDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Planta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantSelector(
    List<PlantModel> plants,
    WidgetRef ref,
    PlantModel? selected,
  ) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: plants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final plant = plants[index];
          final isSelected = selected?.id == plant.id;
          return GestureDetector(
            onTap: () => ref.read(selectedPlantProvider.notifier).state = plant,
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.colorPrimary
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco,
                    color: plant.needsWater
                        ? Colors.orange
                        : AppColors.colorPrimary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (plant.needsWater)
                    Text(
                      '¡Regar!',
                      style: TextStyle(color: Colors.orange, fontSize: 10),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlantDetails(
    BuildContext context,
    WidgetRef ref,
    PlantModel plant,
  ) {
    final irrigationUseCase = IrrigationUseCase();
    final schedule = irrigationUseCase.calculateIrrigationSchedule(
      plant: plant,
      currentSoilMoisture: plant.currentHumidity ?? 45,
      currentTemperature: plant.currentTemperature ?? 22,
      currentHumidity: 55,
      hasRainSensor: false,
      recentRainfall: 0,
    );

    return Column(
      children: [
        _buildHeroImage(plant),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressSection(schedule.urgency / 100),
              const SizedBox(height: 32),
              _buildMetricsRow(plant),
              const SizedBox(height: 32),
              _buildActionsSection(context, ref, plant),
              const SizedBox(height: 32),
              _buildActivityLog(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(PlantModel plant) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl:
              plant.imageUrl ??
              'https://images.unsplash.com/photo-1618164436241-4473940d1f5c?q=80&w=1200',
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[200]),
          errorWidget: (context, url, error) => Container(
            color: AppColors.colorSurfaceGreen,
            height: 250,
            child: const Icon(
              Icons.eco,
              size: 80,
              color: AppColors.colorPrimary,
            ),
          ),
        ),
        Container(
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plant.categoryName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plant.name,
                style: AppTextStyles.titleLarge.copyWith(fontSize: 28),
              ),
              if (plant.scientificName != null)
                Text(
                  plant.scientificName!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso de Crecimiento',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 18,
                color: AppColors.colorPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 12.0,
          percent: percent,
          backgroundColor: AppColors.colorPrimary.withOpacity(0.1),
          progressColor: AppColors.colorPrimary,
          barRadius: const Radius.circular(10),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStageLabel('SEMILLA', percent >= 0),
            _buildStageLabel('VEGETATIVA', percent >= 0.33),
            _buildStageLabel('MADUREZ', percent >= 0.66),
            _buildStageLabel('COSECHA', percent >= 1),
          ],
        ),
      ],
    );
  }

  Widget _buildStageLabel(String label, bool isActive) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        color: isActive ? AppColors.colorPrimary : AppColors.colorTextMuted,
      ),
    );
  }

  Widget _buildMetricsRow(PlantModel plant) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'HUMEDAD',
            value: '${plant.currentHumidity?.toStringAsFixed(0) ?? '--'}',
            unit: '%',
            icon: Icons.water_drop,
            color: AppColors.colorSecondary,
            footer: plant.needsWater ? '¡Necesita agua!' : 'Óptimo',
            footerColor: plant.needsWater
                ? Colors.orange
                : AppColors.colorPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            label: 'TEMPERATURA',
            value: '${plant.currentTemperature?.toStringAsFixed(0) ?? '--'}',
            unit: '°C',
            icon: Icons.thermostat,
            color: Colors.orange,
            footer: 'Rango: 18-26°C',
            footerColor: AppColors.colorPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String footer,
    required Color footerColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 32,
                  color: AppColors.colorTextPrimary,
                ),
              ),
              Text(unit, style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelSmall),
          const Divider(height: 24),
          Text(
            footer,
            style: TextStyle(
              fontSize: 10,
              color: footerColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    WidgetRef ref,
    PlantModel plant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones de Cuidado',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(Icons.water_drop, 'REGAR', () async {
              final dbService = ref.read(databaseServiceProvider);
              final updatedPlant = plant.copyWith(
                lastWateredAt: DateTime.now(),
              );
              await dbService.updatePlant(updatedPlant);
              ref.invalidate(plantsNotifierProvider);
            }),
            _buildActionButton(Icons.eco, 'FERTILIZAR', () {}),
            _buildActionButton(Icons.light_mode, 'LUZ', () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.colorPrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.colorPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de Actividad',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildLogTile('Riego realizado', 'Hace 2 horas', Icons.check_circle),
        _buildLogTile('Revisión de sensores', 'Ayer, 8:00 PM', Icons.sensors),
        _buildLogTile(
          'Fertilización aplicada',
          'Hace 3 días',
          Icons.add_circle,
        ),
      ],
    );
  }

  Widget _buildLogTile(String title, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.colorTextMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorTextPrimary,
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPlantDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    PlantCategory selectedCategory = PlantCategory.vegetable;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Planta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la planta',
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => DropdownButton<PlantCategory>(
                value: selectedCategory,
                isExpanded: true,
                items: PlantCategory.values.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.name));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final authService = ref.read(authServiceProvider);
                final userId = authService.userId;
                if (userId != null) {
                  final dbService = ref.read(databaseServiceProvider);
                  final newPlant = PlantModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: userId,
                    name: nameController.text,
                    category: selectedCategory,
                    createdAt: DateTime.now(),
                  );
                  await dbService.createPlant(newPlant);
                  ref.invalidate(plantsNotifierProvider);
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
