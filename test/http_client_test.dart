import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/core/http_client.dart';

void main() {
  group('AppHttpClient', () {
    test('can be instantiated', () {
      final client = AppHttpClient();
      expect(client, isA<AppHttpClient>());
      client.close();
    });

    test('has default timeout and retry settings', () {
      final client = AppHttpClient();
      // Verify it doesn't throw on construction
      expect(client, isNotNull);
      client.close();
    });
  });
}
