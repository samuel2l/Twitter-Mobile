import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/network/api_client_provider.dart';
import 'utils/config/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppEnv.load();

  try {
    await Firebase.initializeApp();
  } catch (error) {
    debugPrint(
      '[firebase] init skipped (add FlutterFire config for push): $error',
    );
  }

  final apiClient = await ApiClient.create();

  runApp(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(apiClient),
      ],
      child: const TwitterApp(),
    ),
  );
}
