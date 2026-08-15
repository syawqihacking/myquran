import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../data/models/niat_shalat_data.dart';
import 'spiritual_reader_screen.dart';

/// Niat Shalat — lists the intentions for the five daily prayers and common
/// sunnah prayers. Reuses the [SpiritualReaderScreen] layout (a numbered list
/// of Arabic + transliteration + Indonesian translation).
class NiatShalatScreen extends StatelessWidget {
  const NiatShalatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SpiritualReaderScreen(
      title: S.niatShalatTitle,
      subtitle: S.niatShalatCaption,
      items: niatShalatItems,
      icon: Icons.wc_rounded,
    );
  }
}
