import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/providers/auth_providers.dart';
import 'signup_screen.dart';

/// Login screen — "Masuk" (design §0 auth).
///
/// A full-screen, dark-green themed gate: the app's Rub el Hizb mark and
/// "Al-Qur'an" branding up top, a soft glass card holding the email/password
/// form, a loading "Masuk" button, a quiet "Lanjut sebagai Tamu" escape hatch,
/// and a link to the signup screen. Content is one responsive column (~440px)
/// that scrolls on short screens and centers on wide ones.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Signs in with the entered credentials, surfacing any provider error as a
  /// localized message inside the form card.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;
      // Signed in — the auth state change re-flows the UI; if this screen
      // was pushed as a route we pop back to reveal the signed-in profile.
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _mapAuthError(e, AppLocalizations.of(context)!));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Continues as a guest, then leaves the auth flow.
  Future<void> _continueAsGuest() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).continueAsGuest();
      if (!mounted) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _mapAuthError(e, AppLocalizations.of(context)!));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Signs in with Facebook, surfacing any provider error as a localized
  /// message inside the form card. On success the auth state change re-flows
  /// the UI, popping back to the signed-in profile if we were pushed as a route.
  Future<void> _signInWithFacebook() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signInWithFacebook();
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _mapAuthError(e, AppLocalizations.of(context)!));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Maps the auth provider's l10n message key to a localized error string.
  /// Unknown keys fall back to the generic error.
  static String _mapAuthError(Object error, AppLocalizations l10n) {
    final key = error.toString();
    return switch (key) {
      'emailInUse' => l10n.authErrorEmailInUse,
      'invalidCredentials' => l10n.authErrorInvalidCredentials,
      'weakPassword' => l10n.authErrorWeakPassword,
      'invalidEmail' => l10n.authErrorInvalidEmail,
      'confirmEmail' => l10n.authConfirmEmail,
      _ => l10n.authErrorGeneric,
    };
  }

  void _openSignup() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image from Splash
          Image.asset(
            'assets/images/splash_bg.jpg',
            fit: BoxFit.cover,
          ),
          // Overlay to ensure text readability, adapting to theme
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0B1A13).withValues(alpha: 0.85),
                  const Color(0xFF08130E).withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isMobile ? AppLayout.sp5 : AppLayout.sp6,
                AppLayout.sp7,
                isMobile ? AppLayout.sp5 : AppLayout.sp6,
                AppLayout.sp7,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Center(
                  child: _StaggerIn(
                    children: [
                      const _AuthBranding(),
                      const SizedBox(height: AppLayout.sp7),
                      _buildFormCard(theme, scheme, l10n, isMobile, isDark),
                      const SizedBox(height: AppLayout.sp6),
                      TextButton(
                        onPressed: _submitting ? null : _openSignup,
                        child: Text(
                          l10n.authNoAccount,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isDark ? Colors.white : scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
    bool isMobile,
    bool isDark,
  ) {
    final colorGold = const Color(0xFFD6B560);
    final colorSage = const Color(0xFFA2C6AC);
    final colorCardBg = const Color(0xFF29322D).withValues(alpha: 0.95);
    final colorFieldBg = const Color(0xFF1D2420);
    final colorOutline = const Color(0xFF3B4640);

    InputDecoration fieldDecoration(String hint, IconData prefixIcon, {Widget? suffix}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 15,
        ),
        filled: true,
        fillColor: colorFieldBg,
        prefixIcon: Icon(prefixIcon, color: colorGold, size: 22),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp4,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorGold.withValues(alpha: 0.5), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner ornament
          Positioned.fill(
            child: CustomPaint(
              painter: _CornerOrnamentPainter(color: colorGold.withValues(alpha: 0.4)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? AppLayout.sp5 : AppLayout.sp6),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    enabled: !_submitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    validator: _validateEmail,
                    style: const TextStyle(color: Colors.white),
                    decoration: fieldDecoration('Email', Icons.email_outlined),
                  ),
                  const SizedBox(height: AppLayout.sp4),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_submitting,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    validator: _validatePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: fieldDecoration(
                      'Kata Sandi',
                      Icons.lock_outline,
                      suffix: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, // Placeholder for forgot password
                      style: TextButton.styleFrom(
                        foregroundColor: colorGold,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lupa kata sandi?',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppLayout.sp4),
                    _ErrorBanner(message: _error!),
                  ],
                  const SizedBox(height: AppLayout.sp5),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorSage,
                      foregroundColor: const Color(0xFF111A15),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF111A15),
                            ),
                          )
                        : const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppLayout.sp6),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorOutline, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.diamond_outlined, color: colorGold, size: 16),
                      ),
                      Expanded(child: Divider(color: colorOutline, thickness: 1)),
                    ],
                  ),
                  
                  const SizedBox(height: AppLayout.sp6),
                  
                  // Secondary path
                  OutlinedButton.icon(
                    onPressed: _submitting ? null : _continueAsGuest,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.white,
                      side: BorderSide(color: colorOutline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.person_outline_rounded, size: 20),
                    label: const Text(
                      'Lanjut sebagai Tamu',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp4),
                  // Facebook sign-in
                  OutlinedButton.icon(
                    onPressed: _submitting ? null : _signInWithFacebook,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: const Color(0xFF4C75D2),
                      side: BorderSide(color: colorOutline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.facebook_rounded, size: 20),
                    label: const Text(
                      'Masuk dengan Facebook',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Masukkan alamat email.';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(email)) return 'Format email tidak valid.';
    return null;
  }

  static String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Masukkan kata sandi.';
    return null;
  }
}

/// App branding — App Logo + "Selamat Datang"
class _AuthBranding extends StatelessWidget {
  const _AuthBranding();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _AppLogo(),
        const SizedBox(height: AppLayout.sp6),
        const Text(
          'Selamat Datang',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD6B560),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        const Text(
          'Memulai perjalanan spiritual Anda',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF8B9990),
          ),
        ),
      ],
    );
  }
}

/// Circular App Logo
class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1D2420),
        border: Border.all(
          color: const Color(0xFFD6B560),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/app_logo.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Inline localized error banner inside the form card.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp3,
      ),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: scheme.error),
          const SizedBox(width: AppLayout.sp2),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple staggered entrance: children fade in while rising slightly, each
/// starting a beat after the previous. Honors prefers-reduced-motion.
class _StaggerIn extends StatelessWidget {
  const _StaggerIn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: reduce ? 1 : 0, end: 1),
            duration: Duration(milliseconds: 450 + i * 90),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) {
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 14),
                  child: child,
                ),
              );
            },
            child: children[i],
          ),
      ],
    );
  }
}

/// A subtle corner ornament matching the reference design.
class _CornerOrnamentPainter extends CustomPainter {
  _CornerOrnamentPainter({required this.color});
  
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Top left curve
    final path1 = Path()
      ..moveTo(0, 30)
      ..quadraticBezierTo(20, 20, 30, 0);
    canvas.drawPath(path1, paint);

    // Top right curve
    final path2 = Path()
      ..moveTo(size.width, 30)
      ..quadraticBezierTo(size.width - 20, 20, size.width - 30, 0);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerOrnamentPainter oldDelegate) => oldDelegate.color != color;
}
