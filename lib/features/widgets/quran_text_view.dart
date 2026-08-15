import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/quran_palette.dart';
import '../../core/quran_scale.dart';
import '../../core/tajwid.dart';
import '../../core/tajwid_palette.dart';

/// Quran text display (§9).
///
/// Always Amiri Qur'an, always `letterSpacing: 0` (see quran_scale.dart), and
/// by default the "paper" ink color. Size/line-height come from the scale step.
///
/// When [tajwidRanges] is null (default) the widget renders a plain [Text]
/// byte-identical to the pre-tajwid behavior. When present, it renders a
/// `Text.rich` with the same root style and colored spans for each range.
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
    this.tajwidRanges,
  });

  final String text;
  final int step;
  final TextAlign? alignment;
  final TextDirection textDirection;
  final Color? color;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;

  /// Optional tajwid coloring ranges. When null, renders plain [Text].
  final List<TajwidRange>? tajwidRanges;

  @override
  Widget build(BuildContext context) {
    final quran = context.quran;
    final baseStyle = TextStyle(
      fontFamily: AppConstants.fontQuran,
      fontSize: quranFontSize(step),
      height: quranLineHeight(step),
      color: color ?? quran.quranInk,
      letterSpacing: 0, // never letter-space Arabic
    );

    if (tajwidRanges == null || tajwidRanges!.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textDirection: textDirection,
        textAlign: alignment ??
            (textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left),
        style: baseStyle,
      );
    }

    final tajwid = Theme.of(context).extension<TajwidPalette>();
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final range in tajwidRanges!) {
      if (range.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, range.start)));
      }
      final ruleColor = switch (range.rule) {
        TajwidRule.mad => tajwid?.mad,
        TajwidRule.ghunnah => tajwid?.ghunnah,
        TajwidRule.qalqalah => tajwid?.qalqalah,
      };
      spans.add(
        TextSpan(
          text: text.substring(range.start, range.end),
          style: ruleColor == null ? null : TextStyle(color: ruleColor),
        ),
      );
      cursor = range.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      textAlign: alignment ??
          (textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left),
    );
  }
}
