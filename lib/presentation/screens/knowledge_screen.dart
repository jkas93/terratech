import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/logic.dart';
import '../widgets/common/tt_app_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';

class KnowledgeScreen extends ConsumerWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: const TtAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildKnowledgeCard(
                title: 'Hidroponía para Principiantes',
                description:
                    'Fundamentos de los sistemas NFT y su funcionamiento.',
                progress: 0.65,
                badgeText: 'NIVEL 1',
                badgeColor: AppColors.colorSecondary,
                duration: '8 min',
                cardColor: Colors.white,
                textColor: AppColors.colorTextPrimary,
              ),
              const SizedBox(height: 20),
              _buildKnowledgeCard(
                title: 'La Magia del pH',
                description:
                    'Cómo las plantas absorben nutrientes según la acidez.',
                progress: 0.12,
                badgeText: 'QUÍMICA',
                badgeColor: AppColors.colorTertiary,
                duration: '15 min',
                cardColor: AppColors.colorTertiary,
                textColor: Colors.white,
              ),
              const SizedBox(height: 20),
              _buildLockedCard(
                title: 'Compostaje Urbano',
                description:
                    'Alianza estratégica para recircular tus desechos orgánicos.',
                badgeText: 'ALIANZA FICUS PERÚ',
                badgeColor: AppColors.colorPrimary,
                duration: '12 min',
                cardColor: AppColors.colorSurfaceGreen,
                textColor: AppColors.colorPrimaryDeep,
                requiredXp: 50,
                currentXp: authState.xp,
              ),
              const SizedBox(height: 32),
              _buildPartnerSection(),
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
        Text(
          'APRENDER Y CRECER',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.colorPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Centro de Conocimiento',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 8),
        Text(
          'Domina el arte de la jardinería de alta tecnología y expande tu saber.',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLockedCard({
    required String title,
    required String description,
    double progress = 0.0,
    required String badgeText,
    required Color badgeColor,
    required String duration,
    required Color cardColor,
    required Color textColor,
    required int requiredXp,
    required int currentXp,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                duration,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: textColor,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor,
              foregroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              'Desbloquear con ${requiredXp}XP (tienes $currentXp)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeCard({
    required String title,
    required String description,
    required double progress,
    required String badgeText,
    required Color badgeColor,
    required String duration,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                duration,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: textColor,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8.0,
            percent: progress,
            backgroundColor: textColor.withOpacity(0.1),
            progressColor: AppColors.colorPrimary,
            barRadius: const Radius.circular(10),
            trailing: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                iconSize: 40,
                icon: Icon(
                  Icons.play_circle_fill,
                  color: AppColors.colorPrimary,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Contenido de Socios',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
            ),
            Text(
              'Ver Todos >',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.colorPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPartnerItem(
          'FICUS PERÚ',
          'Soluciones de saneamiento ecológico y áreas verdes.',
          Icons.yard,
          'APECO',
        ),
        _buildPartnerItem(
          'Huertas Urbanas',
          'Cómo empezar tu primer cultivo en el balcón.',
          Icons.home_work,
          'FICUS PERÚ',
        ),
      ],
    );
  }

  Widget _buildPartnerItem(
    String title,
    String description,
    IconData icon,
    String partnerType,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.colorSurfaceLogin,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.colorPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Socio: $partnerType',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.colorPrimary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
