import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../utils/constants/api_constants.dart';

class DevicesRepository {
  const DevicesRepository(this._client);

  final ApiClient _client;

  Future<void> register({
    required String token,
    required String platform,
  }) async {
    await _client.post<Map<String, dynamic>>(
      ApiConstants.devices,
      data: {
        'token': token,
        'platform': platform,
      },
    );
  }

  Future<void> unregister(String token) async {
    await _client.post<void>(
      ApiConstants.devicesUnregister,
      data: {'token': token},
    );
  }
}

String currentDevicePlatform() {
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  return 'android';
}
