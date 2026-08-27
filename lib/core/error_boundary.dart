import 'package:flutter/material.dart';

/// Global error boundary that catches Flutter framework errors and displays
/// a user-friendly error screen instead of the red error screen.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({super.key, required this.child});
  final Widget child;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() => _error = details);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorScreen(
        error: _error!,
        onRetry: () => setState(() => _error = null),
      );
    }
    return widget.child;
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error, required this.onRetry});
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aplikasi mengalami error yang tidak terduga.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sets up the global error handler for the Flutter framework.
void setupErrorBoundary() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Catch errors from async operations that aren't caught
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    // Log to console for now; could be extended to crashlytics
    debugPrint('Uncaught error: $error');
    debugPrint('Stack: $stack');
    return true;
  };
}
