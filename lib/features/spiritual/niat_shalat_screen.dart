import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../data/models/niat_shalat_data.dart';
import 'spiritual_reader_screen.dart';

/// Niat Shalat — lists the intentions for the five daily prayers and common
/// sunnah prayers. Reuses the [SpiritualReaderScreen] layout (a numbered list
/// of Arabic + transliteration + Indonesian translation).
class NiatShalatScreen extends StatelessWidget {
  const NiatShalatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SpiritualReaderScreen(
      title: l10n.niatShalatTitle,
      subtitle: l10n.niatShalatCaption,
      items: niatShalatItems,
      icon: Icons.wc_rounded,
    );
  }
}
