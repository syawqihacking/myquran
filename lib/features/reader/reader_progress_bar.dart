import 'package:flutter/material.dart';

import '../../core/app_layout.dart';

/// Thin progress bar shown below the top bar.
class ReaderProgressBar extends StatelessWidget {
  const ReaderProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: AppLayout.progressBarHeight,
      color: scheme.surfaceContainerHighest,
      child: LayoutBuilder(
        builder: (ctx, c) => AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          width: c.maxWidth * progress,
          color: scheme.primary,
        ),
      ),
    );
  }
}
