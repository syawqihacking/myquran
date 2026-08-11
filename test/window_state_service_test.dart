import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/core/window_state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load returns null when nothing has been saved', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = WindowStateService(prefs);

    expect(service.load(), isNull);
  });

  test('load returns null when only some keys are present', () async {
    SharedPreferences.setMockInitialValues({'window_width': 1280.0});
    final prefs = await SharedPreferences.getInstance();
    final service = WindowStateService(prefs);

    expect(service.load(), isNull);
  });

  test('save then load round-trips size and position', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = WindowStateService(prefs);

    await service.save(const Size(1280, 800), const Offset(64, 32));

    final state = service.load();
    expect(state, isNotNull);
    expect(state!.size, const Size(1280, 800));
    expect(state.position, const Offset(64, 32));
  });

  test('save overwrites a previously saved geometry', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = WindowStateService(prefs);

    await service.save(const Size(1280, 800), const Offset(64, 32));
    await service.save(const Size(1024, 768), const Offset(10, 20));

    final state = service.load();
    expect(state, isNotNull);
    expect(state!.size, const Size(1024, 768));
    expect(state.position, const Offset(10, 20));
  });
}