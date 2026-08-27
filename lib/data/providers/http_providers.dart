import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/http_client.dart';

final httpClientProvider = Provider<AppHttpClient>((ref) {
  final client = AppHttpClient();
  ref.onDispose(client.close);
  return client;
});
