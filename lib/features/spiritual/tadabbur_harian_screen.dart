import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../data/models/tadabbur_harian_data.dart';
import 'spiritual_reader_screen.dart';

/// Tadabbur Harian — a curated set of short daily reflections. Each item is a
/// Quran ayah (Arabic + Indonesian translation) with a short renungan in the
/// `note` field. Reuses the [SpiritualReaderScreen] layout.
class TadabburHarianScreen extends StatelessWidget {
  const TadabburHarianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SpiritualReaderScreen(
      title: l10n.tadabburTitle,
      subtitle: l10n.tadabburCaption,
      items: tadabburHarianItems,
      icon: Icons.auto_awesome_rounded,
    );
  }
}
