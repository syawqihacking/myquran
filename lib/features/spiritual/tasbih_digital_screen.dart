import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_layout.dart';

class TasbihCountNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void reset() => state = 0;
}

final tasbihCountProvider = NotifierProvider<TasbihCountNotifier, int>(TasbihCountNotifier.new);

class TasbihDigitalScreen extends ConsumerStatefulWidget {
  const TasbihDigitalScreen({super.key});

  @override
  ConsumerState<TasbihDigitalScreen> createState() => _TasbihDigitalScreenState();
}

class _TasbihDigitalScreenState extends ConsumerState<TasbihDigitalScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    ref.read(tasbihCountProvider.notifier).increment();
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());
  }

  void _onReset() {
    ref.read(tasbihCountProvider.notifier).reset();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(tasbihCountProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Digital'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _onTap,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [scheme.primary, scheme.primary.withValues(alpha: 0.7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$count',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 72,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap untuk berdzikir',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimary.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              TextButton.icon(
                onPressed: count > 0 ? _onReset : null,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: scheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
