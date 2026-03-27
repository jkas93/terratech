import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/logic.dart';
import '../../objects/models/models.dart';
import '../widgets/common/tt_app_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BuildScreen extends ConsumerWidget {
  const BuildScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesNotifierProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: const TtAppBar(title: 'Construir'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(modulesNotifierProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildConstructionCard(modulesAsync),
              const SizedBox(height: 32),
              _buildResourcesCard(),
              const SizedBox(height: 32),
              _buildModuleGrid(context, ref, modulesAsync, authState.level),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONSTRUIR', style: AppTextStyles.labelSmall),
        const SizedBox(height: 4),
        Text(
          'Diseña tu próximo módulo de cultivo',
          style: AppTextStyles.titleMedium,
        ),
      ],
    );
  }

  Widget _buildConstructionCard(AsyncValue<List<ModuleModel>> modulesAsync) {
    final progress = modulesAsync.maybeWhen(
      data: (modules) => modules.isEmpty ? 0.0 : (modules.length % 5) * 0.2,
      orElse: () => 0.42,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.colorPrimaryDeep,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorPrimaryDeep.withOpacity(0.3),
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
                'EN CONSTRUCCIÓN',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          modulesAsync.when(
            data: (modules) => Text(
              modules.isEmpty
                  ? 'Nuevo Módulo'
                  : 'Módulo #${modules.length + 1}',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            loading: () => Text(
              'Cargando...',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            error: (_, __) => Text(
              'Error',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 10.0,
            percent: progress,
            backgroundColor: Colors.white24,
            progressColor: AppColors.colorXPBar,
            barRadius: const Radius.circular(10),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.colorPrimaryDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('Continuar construcción →'),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recursos Disponibles',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildResourceItem(Icons.water_drop, '140L', 'AGUA'),
              _buildResourceItem(Icons.science, '12.5L', 'NUTRIENTES'),
              _buildResourceItem(Icons.sensors, '8 UNID.', 'SENSORES'),
              _buildResourceItem(Icons.electrical_services, '24W', 'ENERGÍA'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceItem(IconData icon, String value, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.colorPrimary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildModuleGrid(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ModuleModel>> modulesAsync,
    int userLevel,
  ) {
    final availableModules = [
      _ModuleInfo('Aquapónico V1', 1, Icons.waves),
      _ModuleInfo('Aeropónico Pro', 5, Icons.cloud_queue),
      _ModuleInfo('Vertical Farm', 3, Icons.account_tree_outlined),
      _ModuleInfo('Ecosistema IoT', 8, Icons.hub_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explorar Módulos',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
          children: availableModules.map((module) {
            final isAvailable = userLevel >= module.requiredLevel;
            return _buildModuleCard(context, ref, module, isAvailable);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    WidgetRef ref,
    _ModuleInfo info,
    bool isAvailable,
  ) {
    return Opacity(
      opacity: isAvailable ? 1.0 : 0.6,
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.colorSurfaceLogin,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(info.icon, color: AppColors.colorPrimary, size: 32),
            ),
            const Spacer(),
            Text(
              info.name,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable
                    ? AppColors.colorPrimary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isAvailable ? 'Disponible' : 'Nivel ${info.requiredLevel}',
                style: TextStyle(
                  fontSize: 10,
                  color: isAvailable
                      ? AppColors.colorPrimary
                      : AppColors.colorTextMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (isAvailable)
              ElevatedButton(
                onPressed: () => _showAddModuleDialog(context, ref, info.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorPrimary,
                  minimumSize: const Size(double.infinity, 36),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Construir',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            else
              const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  void _showAddModuleDialog(
    BuildContext context,
    WidgetRef ref,
    String moduleName,
  ) {
    final nameController = TextEditingController(text: moduleName);
    ModuleType selectedType = ModuleType.sensor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Módulo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre del módulo'),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => DropdownButton<ModuleType>(
                value: selectedType,
                isExpanded: true,
                items: ModuleType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
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
                  final newModule = ModuleModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: userId,
                    name: nameController.text,
                    type: selectedType,
                    status: ModuleStatus.offline,
                    createdAt: DateTime.now(),
                  );
                  await dbService.createModule(newModule);
                  ref.invalidate(modulesNotifierProvider);
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}

class _ModuleInfo {
  final String name;
  final int requiredLevel;
  final IconData icon;

  _ModuleInfo(this.name, this.requiredLevel, this.icon);
}
