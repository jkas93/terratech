import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/logic.dart';
import '../../objects/models/models.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final plantsAsync = ref.watch(plantsNotifierProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.colorTextPrimary,
          ),
          onPressed: () {},
        ),
        title: Text(
          'Mi Perfil',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.colorTextPrimary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(plantsNotifierProvider);
          ref.invalidate(achievementsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatarSection(authState),
              const SizedBox(height: 24),
              _buildNameSection(authState),
              const SizedBox(height: 24),
              _buildXpBar(authState),
              const SizedBox(height: 24),
              _buildStatsGrid(plantsAsync, achievementsAsync),
              const SizedBox(height: 24),
              _buildBadgesSection(achievementsAsync),
              const SizedBox(height: 24),
              _buildMenuOptions(context, ref),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(AuthState authState) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.colorPrimary, width: 3),
          ),
          child: CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.colorSurfaceGreen,
            backgroundImage: authState.displayName != null
                ? NetworkImage(
                    'https://api.dicebear.com/7.x/initials/png?seed=${authState.displayName}',
                  )
                : null,
            child: authState.displayName == null
                ? const Icon(
                    Icons.person,
                    size: 64,
                    color: AppColors.colorPrimary,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.colorPrimaryDeep,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'LEVEL ${authState.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection(AuthState authState) {
    return Column(
      children: [
        Text(
          authState.displayName ?? 'Usuario',
          style: AppTextStyles.heading.copyWith(
            fontSize: 24,
            color: AppColors.colorTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Nivel ${authState.level} · ${authState.xp} XP',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.colorPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildXpBar(AuthState authState) {
    final xpToNextLevel = authState.level * 100;
    final progress = authState.levelProgress.clamp(0.0, 1.0);
    final currentLevelXp = (xpToNextLevel * progress).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PRÓXIMO NIVEL — PROGRESO', style: AppTextStyles.labelSmall),
              Text(
                '$currentLevelXp / $xpToNextLevel XP',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.colorPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 12.0,
            percent: progress,
            backgroundColor: AppColors.colorPrimary.withOpacity(0.1),
            progressColor: AppColors.colorXPBar,
            barRadius: const Radius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    AsyncValue<List<PlantModel>> plantsAsync,
    AsyncValue<List<AchievementModel>> achievementsAsync,
  ) {
    final plantCount = plantsAsync.maybeWhen(
      data: (plants) => plants.length,
      orElse: () => 0,
    );
    final unlockedAchievements = achievementsAsync.maybeWhen(
      data: (achievements) => achievements.where((a) => a.isUnlocked).length,
      orElse: () => 0,
    );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          Icons.eco,
          '$plantCount',
          'PLANTAS',
          AppColors.colorPrimary,
        ),
        _buildStatCard(
          Icons.emoji_events,
          '$unlockedAchievements',
          'LOGROS',
          AppColors.colorSecondary,
        ),
        _buildStatCard(
          Icons.cloud_outlined,
          '142 kg',
          'CO₂ OFFSET',
          AppColors.colorTertiary,
        ),
        _buildStatCard(
          Icons.bookmark_outlined,
          '8',
          'GUARDADAS',
          AppColors.colorPrimaryDark,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 22,
                  color: AppColors.colorTextPrimary,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(
    AsyncValue<List<AchievementModel>> achievementsAsync,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Mis Insignias',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
              ),
              Text(
                'VER TODAS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.colorPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          achievementsAsync.when(
            data: (achievements) {
              final unlocked = achievements
                  .where((a) => a.isUnlocked)
                  .take(3)
                  .toList();
              if (unlocked.isEmpty) {
                return const Center(
                  child: Text('Completa logros para desbloquear insignias'),
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: unlocked
                    .map((a) => _buildBadge(a.name, _getBadgeColor(a.type)))
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Error al cargar logros')),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor(AchievementType type) {
    switch (type) {
      case AchievementType.firstGarden:
      case AchievementType.firstModule:
        return AppColors.colorPrimary;
      case AchievementType.dailyCheckIn:
      case AchievementType.weekStreak:
      case AchievementType.monthStreak:
        return AppColors.colorSecondary;
      case AchievementType.plantMaster:
      case AchievementType.harvestTime:
        return Colors.orange;
      case AchievementType.waterSaver:
        return Colors.blue;
      default:
        return AppColors.colorTertiary;
    }
  }

  Widget _buildBadge(String label, Color bgColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: bgColor.withOpacity(0.4), width: 2),
          ),
          child: Icon(Icons.emoji_events, color: bgColor, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label.split(' ').first,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9,
            color: AppColors.colorTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptions(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildMenuOption(Icons.emoji_events_outlined, 'Logros', () {}),
        _buildMenuOption(Icons.settings_outlined, 'Configuración', () {}),
        _buildMenuOption(Icons.help_outline, 'Ayuda y Soporte', () {}),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () async {
            await ref.read(authProvider.notifier).signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
          icon: const Icon(Icons.logout, color: AppColors.colorError),
          label: Text(
            'Cerrar Sesión',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.colorError,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.colorPrimary),
        title: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.colorTextMuted,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
