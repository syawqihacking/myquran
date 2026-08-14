import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Zen mode (mode baca fokus) — reader-only UI state.
///
/// When on, the app chrome (sidebar, reader top bar, progress strip) is hidden
/// so only the paper column and the ayah text remain. Ephemeral: not persisted
/// across launches. Toggled from the reader toolbar today; a later phase (E1)
/// binds the Ctrl+B shortcut to [ZenModeController.toggle].
final zenModeProvider =
    NotifierProvider<ZenModeController, bool>(ZenModeController.new);

class ZenModeController extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;

  void toggle() => state = !state;
}
