import 'app_constants.dart';

/// Layout tokens (design system §3, §4, §5).
abstract final class AppLayout {
  // Spacing (base unit 4 px).
  static const double sp1 = 4;
  static const double sp2 = 8;
  static const double sp3 = 12;
  static const double sp4 = 16;
  static const double sp5 = 20;
  static const double sp6 = 24;
  static const double sp7 = 32;
  static const double sp8 = 40;
  static const double sp9 = 48;
  static const double sp10 = 64;
  static const double sp11 = 96;

  // Radius.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusFull = 999;

  // Motion (design system §7).
  static const Duration durQuick = Duration(milliseconds: 100);
  static const Duration durBase = Duration(milliseconds: 200);
  static const Duration durPanel = Duration(milliseconds: 300);
  static const Duration durPage = Duration(milliseconds: 400);

  // Reading column geometry.
  static const double readerMinWidth = AppConstants.readerMinWidth;
  static const double readerMaxWidth = AppConstants.readerMaxWidth;

  // Reader chrome.
  static const double readerTopBarHeight = 56;
  static const double progressBarHeight = 3;
}
