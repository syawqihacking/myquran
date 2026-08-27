import 'package:flutter/material.dart';

import '../../core/app_layout.dart';

/// Rounded-xl card on `surfaceContainerLowest` with a soft emerald shadow.
/// On hover the shadow deepens and a primary @ 10% border appears.
class HoverCard extends StatefulWidget {
  const HoverCard({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<HoverCard> createState() => HoverCardState();
}

class HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppLayout.sp4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          border: Border.all(
            color: _hovered
                ? scheme.primary.withValues(alpha: 0.10)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: _hovered ? 0.08 : 0.04),
              blurRadius: _hovered ? 32 : 20,
              offset: Offset(0, _hovered ? 12 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
