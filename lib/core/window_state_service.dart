import 'dart:async';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app_constants.dart';

/// Persisted window geometry (size + position).
class WindowState {
  const WindowState({required this.size, required this.position});

  final Size size;
  final Offset position;
}

/// Persists and restores the desktop window geometry across sessions.
///
/// Values are stored as doubles in [SharedPreferences]; a state is only
/// considered saved when all four keys are present. Saving is debounced so a
/// resize/move drag does not hammer the preferences file on every frame.
class WindowStateService {
  WindowStateService(this._prefs);

  static const String kWidthKey = 'window_width';
  static const String kHeightKey = 'window_height';
  static const String kXKey = 'window_x';
  static const String kYKey = 'window_y';

  /// Debounce window for resize/move events (Linux emits configure-event
  /// continuously while dragging).
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  final SharedPreferences _prefs;

  /// Saved geometry, or null when nothing has been persisted yet.
  WindowState? load() {
    final width = _prefs.getDouble(kWidthKey);
    final height = _prefs.getDouble(kHeightKey);
    final x = _prefs.getDouble(kXKey);
    final y = _prefs.getDouble(kYKey);
    if (width == null || height == null || x == null || y == null) {
      return null;
    }
    return WindowState(size: Size(width, height), position: Offset(x, y));
  }

  /// Persists the given window geometry.
  Future<void> save(Size size, Offset position) async {
    await _prefs.setDouble(kWidthKey, size.width);
    await _prefs.setDouble(kHeightKey, size.height);
    await _prefs.setDouble(kXKey, position.dx);
    await _prefs.setDouble(kYKey, position.dy);
  }

  /// Applies the saved geometry to [windowManager], or centers the window when
  /// nothing has been saved yet (first launch). Restored sizes are clamped up
  /// to the app minimum so a stale/edited preference cannot shrink the window
  /// below the supported layout.
  Future<void> restore(WindowManager windowManager) async {
    final saved = load();
    if (saved == null) {
      await windowManager.center();
      return;
    }
    final size = Size(
      saved.size.width < AppConstants.minWindowWidth
          ? AppConstants.minWindowWidth
          : saved.size.width,
      saved.size.height < AppConstants.minWindowHeight
          ? AppConstants.minWindowHeight
          : saved.size.height,
    );
    await windowManager.setSize(size);
    await windowManager.setPosition(saved.position);
  }

  /// Registers a listener that persists the geometry whenever the window is
  /// resized or moved.
  void attach(WindowManager windowManager) {
    windowManager.addListener(_WindowStateListener(this, windowManager));
  }
}

class _WindowStateListener with WindowListener {
  _WindowStateListener(this._service, this._windowManager);

  final WindowStateService _service;
  final WindowManager _windowManager;
  Timer? _debounce;

  @override
  void onWindowResize() => _schedule();

  @override
  void onWindowMove() => _schedule();

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(WindowStateService._debounceDuration, _persist);
  }

  Future<void> _persist() async {
    final size = await _windowManager.getSize();
    final position = await _windowManager.getPosition();
    await _service.save(size, position);
  }
}