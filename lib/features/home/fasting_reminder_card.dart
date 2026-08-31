import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/app_layout.dart';
import '../../core/utils/fasting_logic.dart';

class FastingReminderCard extends StatefulWidget {
  const FastingReminderCard({super.key});

  @override
  State<FastingReminderCard> createState() => _FastingReminderCardState();
}

class _FastingReminderCardState extends State<FastingReminderCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Only show if the current time is afternoon (e.g. >= 15:00)
    final now = DateTime.now();
    if (now.hour < 15) {
      return const SizedBox.shrink();
    }

    final fastingInfo = FastingLogic.getTomorrowFasting();
    if (fastingInfo == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative watermark
          Positioned(
            right: -32,
            top: -36,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 150,
                color: scheme.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppLayout.sp5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, size: 20, color: scheme.primary),
                    const SizedBox(width: AppLayout.sp2),
                    Text(
                      'PENGINGAT PUASA',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppLayout.sp3),
                Text(
                  'Besok adalah jadwal ${fastingInfo.title}. Jangan lupa siapkan sahur dan niat dari malam hari.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppLayout.sp4),
                Material(
                  color: scheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(AppLayout.sp3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.article_rounded,
                                size: 18,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: AppLayout.sp2),
                              Expanded(
                                child: Text(
                                  'Niat ${fastingInfo.title}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: scheme.primary,
                              ),
                            ],
                          ),
                          if (_isExpanded) ...[
                            const SizedBox(height: AppLayout.sp4),
                            Text(
                              fastingInfo.arabic,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontFamily: 'Amiri', // Assuming Amiri is the standard Arabic font here
                                color: scheme.onSurface,
                                height: 1.8,
                              ),
                            ),
                            const SizedBox(height: AppLayout.sp3),
                            Text(
                              fastingInfo.latin,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.primary,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppLayout.sp2),
                            Text(
                              '"${fastingInfo.meaning}"',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
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
