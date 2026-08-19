import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/features/widgets/liquid_glass_switch.dart';

void main() {
  testWidgets('LiquidGlassSwitch toggles state on tap', (tester) async {
    bool value = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LiquidGlassSwitch(
                value: value,
                onChanged: (newValue) {
                  setState(() => value = newValue);
                },
              );
            },
          ),
        ),
      ),
    );

    // Initial state: false
    expect(value, false);

    // Tap switch
    await tester.tap(find.byType(LiquidGlassSwitch));
    await tester.pumpAndSettle();

    // Toggled state: true
    expect(value, true);

    // Tap again
    await tester.tap(find.byType(LiquidGlassSwitch));
    await tester.pumpAndSettle();

    // Toggled back: false
    expect(value, false);
  });

  testWidgets('LiquidGlassSwitch respects disabled state when onChanged is null',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LiquidGlassSwitch(
            value: false,
            onChanged: null,
          ),
        ),
      ),
    );

    // Tap disabled switch
    await tester.tap(find.byType(LiquidGlassSwitch));
    await tester.pumpAndSettle();

    // Should not throw or crash
    expect(find.byType(LiquidGlassSwitch), findsOneWidget);
  });

  testWidgets('LiquidGlassSwitch supports horizontal drag gesture',
      (tester) async {
    bool value = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                return LiquidGlassSwitch(
                  value: value,
                  onChanged: (newValue) {
                    setState(() => value = newValue);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    // Drag from left to right across switch
    await tester.drag(find.byType(LiquidGlassSwitch), const Offset(80, 0));
    await tester.pumpAndSettle();

    expect(value, true);
  });
}
