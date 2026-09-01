import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
// auth_providers.dart is provided by a parallel lane; until reconciliation
// the import may not resolve — expected, the analyzer errors are listed.
import '../../data/providers/auth_providers.dart';
import '../widgets/glass_touch_button.dart';

/// Signup screen — "Daftar" (design §0 auth).
///
/// Same visual language as [LoginScreen]: the Rub el Hizb mark and app name up
/// top, a soft glass card holding Nama / Email / Kata Sandi, a loading "Daftar"
/// button, and a link back to the login screen. Pushed from login, so the app
/// bar carries a quiet back pill instead of the full branding block.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Creates the account, surfacing any provider error as a localized message
  /// inside the form card. On success we pop back to the login screen, which
  /// (having awaited our route) signs straight in — the auth state change
  /// re-flows the app from there.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signUp(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
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

  /// Signs in with Facebook, surfacing any provider error as a localized
  /// message inside the form card. On success the auth state change re-flows
  /// the UI, popping back to the login screen if we were pushed as a route.
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

  void _openLogin() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Faint decorative glow behind the card.
            Positioned(
              top: -160,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 360,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.4),
                      radius: 0.9,
                      colors: [
                        scheme.primary.withValues(alpha: 0.10),
                        scheme.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Centered, capped column — mobile-first, comfortable on desktop.
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isMobile ? AppLayout.sp5 : AppLayout.sp6,
                AppLayout.sp6,
                isMobile ? AppLayout.sp5 : AppLayout.sp6,
                AppLayout.sp7,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Center(
                  child: _StaggerIn(
                    children: [
                      // Back pill (login link), top-aligned.
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _BackPill(onPressed: _submitting ? null : _openLogin),
                      ),
                      const SizedBox(height: AppLayout.sp4),
                      const _SignupBranding(),
                      const SizedBox(height: AppLayout.sp6),
                      _buildFormCard(theme, scheme, l10n, isMobile),
                      const SizedBox(height: AppLayout.sp6),
                      TextButton(
                        onPressed: _submitting ? null : _openLogin,
                        child: Text(
                          l10n.authHasAccount,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    final fieldColor = scheme.surfaceContainerHighest.withValues(alpha: 0.55);

    InputDecoration fieldDecoration(String label, {Widget? suffix}) {
      return InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: fieldColor,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppLayout.sp4,
          vertical: AppLayout.sp4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? AppLayout.sp5 : AppLayout.sp6),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_submitting,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              autocorrect: false,
              maxLength: 30,
              validator: _validateName,
              decoration: fieldDecoration(l10n.authNameLabel).copyWith(
                counterText: '',
              ),
            ),
            const SizedBox(height: AppLayout.sp4),
            TextFormField(
              controller: _emailController,
              enabled: !_submitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newUsername, AutofillHints.email],
              autocorrect: false,
              validator: _validateEmail,
              decoration: fieldDecoration(l10n.authEmailLabel),
            ),
            const SizedBox(height: AppLayout.sp4),
            TextFormField(
              controller: _passwordController,
              enabled: !_submitting,
              obscureText: _obscurePassword,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
              validator: _validatePassword,
              decoration: fieldDecoration(
                l10n.authPasswordLabel,
                suffix: IconButton(
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  tooltip: _obscurePassword ? 'Lihat' : 'Sembunyikan',
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppLayout.sp4),
              _ErrorBanner(message: _error!),
            ],
            const SizedBox(height: AppLayout.sp6),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.sp5,
                  vertical: 16,
                ),
              ),
              child: _submitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Text(l10n.authSignUp),
            ),
            const SizedBox(height: AppLayout.sp3),
            // Facebook sign-in — branded blue, outlined so it reads as the
            // secondary path below the primary "Daftar" button.
            OutlinedButton.icon(
              onPressed: _submitting ? null : _signInWithFacebook,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.sp5,
                  vertical: 14,
                ),
                foregroundColor: const Color(0xFF1877F2),
                side: const BorderSide(color: Color(0xFF1877F2)),
              ),
              icon: const Icon(Icons.facebook_rounded, size: 18),
              label: Text(l10n.authSignInWithFacebook),
            ),
          ],
        ),
      ),
    );
  }

  static String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Masukkan nama kamu.';
    return null;
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
    if (value.length < 6) return 'Kata sandi minimal 6 karakter.';
    return null;
  }
}

/// Compact signup header — a smaller mark + "Al-Qur'an" so the screen keeps
/// the family resemblance without repeating the full login branding.
class _SignupBranding extends StatelessWidget {
  const _SignupBranding();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const _RubElHizbMark(),
        const SizedBox(height: AppLayout.sp3),
        Text(
          l10n.authTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Quiet glass back pill — returns to the login screen.
class _BackPill extends StatelessWidget {
  const _BackPill({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassTouchButton(
      onTap: onPressed,
      radius: AppLayout.radiusFull,
      showShadow: false,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.arrow_back_rounded,
          size: 20,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Rub el Hizb — the Islamic end-of-verse star: two rotated squares (an
/// octagram) with a small center dot. Painted with hairline strokes in the
/// tertiary (gold) family so it reads as a quiet heritage detail.
class _RubElHizbMark extends StatelessWidget {
  const _RubElHizbMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomPaint(
          size: const Size.square(44),
          painter: _RubElHizbPainter(
            color: scheme.tertiary,
            dark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }
}

class _RubElHizbPainter extends CustomPainter {
  _RubElHizbPainter({required this.color, required this.dark});

  final Color color;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = size.width / 2;
    final inset = half * 0.18;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = dark ? 1.6 : 1.4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Two overlapping squares, second rotated 45° — the octagram silhouette.
    final rect = Rect.fromCenter(
      center: center,
      width: size.width - inset * 2,
      height: size.height - inset * 2,
    );
    canvas.drawRect(rect, paint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.7853981633974483); // 45°
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(rect, paint);
    canvas.restore();

    // Center dot, filled.
    canvas.drawCircle(
      center,
      size.width * 0.045,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_RubElHizbPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dark != dark;
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
