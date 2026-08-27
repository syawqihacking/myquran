import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/core/http_result.dart';

void main() {
  group('HttpResult', () {
    test('HttpSuccess holds body and statusCode', () {
      const result = HttpSuccess(body: 'ok', statusCode: 200);
      expect(result.body, 'ok');
      expect(result.statusCode, 200);
      expect(result, isA<HttpResult>());
    });

    test('HttpError holds message and statusCode', () {
      const result = HttpError(message: 'not found', statusCode: 404);
      expect(result.message, 'not found');
      expect(result.statusCode, 404);
      expect(result, isA<HttpResult>());
    });

    test('HttpError without statusCode', () {
      const result = HttpError(message: 'timeout');
      expect(result.message, 'timeout');
      expect(result.statusCode, isNull);
    });
  });
}
