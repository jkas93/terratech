import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/logic.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSignUp = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      bool success;

      if (_isSignUp) {
        final name = _nameController.text.trim();
        success = await authNotifier.signUpWithEmail(
          email: email,
          password: password,
          displayName: name.isNotEmpty ? name : null,
        );
      } else {
        success = await authNotifier.signInWithEmail(
          email: email,
          password: password,
        );
      }

      if (success && mounted) {
        context.go('/home');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState.errorMessage != null && _errorMessage == null) {
      _errorMessage = authState.errorMessage;
    }

    return Scaffold(
      backgroundColor: AppColors.colorSurfaceLogin,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 48),
              _buildFormCard(),
              const SizedBox(height: 24),
              _buildPartners(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.eco_rounded, size: 72, color: AppColors.colorPrimary)
            .animate()
            .fadeIn(duration: 600.ms)
            .scaleXY(begin: 0.7, curve: Curves.elasticOut),
        const SizedBox(height: 8),
        Text(
          'TerraTech',
          style: AppTextStyles.heading.copyWith(
            fontSize: 36,
            color: AppColors.colorPrimary,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: -0.3),
        const SizedBox(height: 8),
        Text(
          'Tu jardín inteligente',
          style: AppTextStyles.bodyMedium,
        ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPrimary.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isSignUp ? '¡Crea tu cuenta!' : '¡Bienvenido de vuelta!',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 26,
                  color: AppColors.colorPrimaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isSignUp
                    ? 'Únete a la comunidad verde'
                    : '¿Listo para cultivar hoy?',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),
              if (_isSignUp) ...[_buildNameField(), const SizedBox(height: 16)],
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 8),
              if (!_isSignUp) _buildForgotPassword(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                _buildErrorMessage(),
              ],
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildGoogleButton(),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 700.ms, delay: 400.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        hintText: 'Nombre',
        prefixIcon: Icon(Icons.person_outline, color: AppColors.colorPrimary),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'Email',
        prefixIcon: Icon(Icons.email_outlined, color: AppColors.colorPrimary),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        hintText: 'Contraseña',
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.colorPrimary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.colorTextMuted,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: AppColors.colorSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.colorError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.colorError,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.colorError, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 4,
          shadowColor: AppColors.colorPrimary.withOpacity(0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isSignUp ? 'Crear cuenta →' : 'Iniciar sesión →',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _isSignUp ? 'O régistrate con' : 'O',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                final success = await ref
                    .read(authProvider.notifier)
                    .signInWithGoogle();
                if (success && mounted) {
                  context.go('/home');
                } else {
                  setState(() => _isLoading = false);
                }
              },
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.colorSecondaryLight,
          foregroundColor: AppColors.colorSecondary,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        icon: Image.network(
          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
          width: 20,
          height: 20,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.g_mobiledata, size: 24),
        ),
        label: Text(
          _isSignUp ? 'Registrarse con Google' : 'Ingresar con Google',
          style: TextStyle(
            color: AppColors.colorSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPartners() {
    return Column(
      children: [
        Text('SOCIOS: APECO · FICUS PERÚ', style: AppTextStyles.labelSmall),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isSignUp ? '¿Ya tienes cuenta? ' : '¿Nuevo en TerraTech? ',
              style: AppTextStyles.bodyMedium,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                  _errorMessage = null;
                });
                ref.read(authProvider.notifier).clearError();
              },
              child: Text(
                _isSignUp ? '¡Inicia sesión!' : '¡Únete al jardín!',
                style: TextStyle(
                  color: AppColors.colorPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
