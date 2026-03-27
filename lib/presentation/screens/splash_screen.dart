import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorSurfaceLogin,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_rounded, size: 96, color: AppColors.colorPrimary)
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: AppColors.colorPrimaryDark),
            const SizedBox(height: 20),
            Text(
              'TerraTech',
              style: AppTextStyles.heading.copyWith(
                fontSize: 40,
                color: AppColors.colorPrimary,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              'Tu jardín inteligente',
              style: AppTextStyles.bodyMedium,
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.colorPrimary,
              strokeWidth: 2,
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
