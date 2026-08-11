import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/quran_palette.dart';

const String _arabicIndicDigits = '\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669';

/// Converts a Western number to Arabic-Indic digits (١٢٣…).
String toArabicIndic(int n) => n.toString().replaceAllMapped(
    RegExp('[0-9]'), (m) => _arabicIndicDigits[int.parse(m.group(0)!)]);

/// Circular ayah-end marker (§16).
///
/// Transparent fill, accent-colored Arabic-Indic numeral, 1.5 px accent border
/// at 70% opacity. Rendered at the visual end (left) of the ayah's first line.
class AyahNumberBadge extends StatelessWidget {
  const AyahNumberBadge({super.key, required this.number, required this.size});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) {
    final quran = context.quran;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: quran.quranAccent.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Text(
        toArabicIndic(number),
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: AppConstants.fontQuran,
          fontSize: size * 0.55,
          height: 1.0,
          color: quran.quranAccent,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
