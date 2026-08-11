import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../core/quran_palette.dart';

/// Decorative flourish used between reader header blocks (§15).
///
/// A hairline rule, accent diamond, hairline rule. Lightweight, non-semantic.
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key, this.thickness = 1, this.width = 160});

  final double thickness;
  final double width;

  @override
  Widget build(BuildContext context) {
    final quran = context.quran;
    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: Container(height: thickness, color: quran.quranRule)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp3),
            child: Transform.rotate(
              angle: 0.7853981633974483, // 45°
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: quran.quranAccent,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
          Expanded(child: Container(height: thickness, color: quran.quranRule)),
        ],
      ),
    );
  }
}
