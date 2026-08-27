import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../reader/reader_screen.dart';

/// Hoverable, ripple-free list tile used across the read lists.
class HoverTile extends StatefulWidget {
  const HoverTile({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<HoverTile> createState() => _HoverTileState();
}

class _HoverTileState extends State<HoverTile> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          hoverColor: Colors.transparent,
          child: AnimatedScale(
            scale: _pressed ? 0.985 : (_hovered ? 1.01 : 1.0),
            duration: AppLayout.durQuick,
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: AppLayout.durBase,
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.sp4,
                vertical: AppLayout.sp3,
              ),
              decoration: BoxDecoration(
                color: _hovered
                    ? theme.colorScheme.surfaceContainerLow
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pushes the reader for [surahId], optionally scrolled to an ayah.
void openSurah(BuildContext context, int surahId, {int? initialAyahId}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          ReaderScreen(surahId: surahId, initialAyahId: initialAyahId),
    ),
  );
}
