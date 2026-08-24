import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'devices_repository.dart';

class PushService {
  PushService(this._devices);

  final DevicesRepository _devices;
  String? _registeredToken;

  /// Best-effort: no-ops when Firebase isn't configured or permission denied.
  Future<void> registerCurrentDevice() async {
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;

      await _devices.register(
        token: token,
        platform: currentDevicePlatform(),
      );
      _registeredToken = token;
    } catch (error) {
      debugPrint('[push] register skipped: $error');
    }
  }

  Future<void> unregisterCurrentDevice() async {
    final token = _registeredToken;
    if (token == null) return;

    try {
      await _devices.unregister(token);
    } catch (error) {
      debugPrint('[push] unregister failed: $error');
    } finally {
      _registeredToken = null;
    }
  }
}
