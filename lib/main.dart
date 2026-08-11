import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/app_constants.dart';
import 'data/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await windowManager.setMinimumSize(
    const Size(AppConstants.minWindowWidth, AppConstants.minWindowHeight),
  );

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);

  // Restore the previous window geometry (or center on first launch), then
  // persist future resize/move events.
  final windowState = container.read(windowStateServiceProvider);
  await windowState.restore(windowManager);
  windowState.attach(windowManager);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyQuranApp(),
    ),
  );
}
