import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/core/error_boundary.dart';

void main() {
  group('ErrorBoundary', () {
    testWidgets('renders child normally', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorBoundary(
            child: Text('Hello'),
          ),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('shows error screen when FlutterError occurs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorBoundary(
            child: Text('Hello'),
          ),
        ),
      );

      // Trigger a Flutter framework error
      FlutterError.reportError(FlutterErrorDetails(
        exception: StateError('Test error'),
        stack: StackTrace.empty,
        library: 'test',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Terjadi kesalahan'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('retry button resets error state and shows child',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorBoundary(
            child: Text('Hello'),
          ),
        ),
      );

      // Trigger error
      FlutterError.reportError(FlutterErrorDetails(
        exception: StateError('Test error'),
        stack: StackTrace.empty,
        library: 'test',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Terjadi kesalahan'), findsOneWidget);

      // Tap retry
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Terjadi kesalahan'), findsNothing);
    });
  });
}
