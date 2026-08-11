import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/quran_palette.dart';
import '../../core/quran_scale.dart';

/// Quran text display (§9).
///
/// Always Amiri Qur'an, always `letterSpacing: 0` (see quran_scale.dart), and
/// by default the "paper" ink color. Size/line-height come from the scale step.
class QTextDisplay extends StatelessWidget {
  const QTextDisplay({
    super.key,
    required this.text,
    required this.step,
    this.alignment,
    this.textDirection = TextDirection.rtl,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.softWrap = true,
  });

  final String text;
  final int step;
  final TextAlign? alignment;
  final TextDirection textDirection;
  final Color? color;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    final quran = context.quran;
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      textAlign: alignment ??
          (textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left),
      style: TextStyle(
        fontFamily: AppConstants.fontQuran,
        fontSize: quranFontSize(step),
        height: quranLineHeight(step),
        color: color ?? quran.quranInk,
        letterSpacing: 0, // never letter-space Arabic
      ),
    );
  }
}
