import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static var _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;

    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env is optional — dart-defines / defaults still work.
    }

    _loaded = true;
  }

  static String get apiBaseUrl =>
      _firstNonEmpty(
        dotenv.env['API_BASE_URL'],
        const String.fromEnvironment('API_BASE_URL'),
      ) ??
      'http://localhost:3000';

  static String get googleClientId =>
      _firstNonEmpty(
        dotenv.env['GOOGLE_CLIENT_ID'],
        const String.fromEnvironment('GOOGLE_CLIENT_ID'),
      ) ??
      '';

  static String? _firstNonEmpty(String? a, String b) {
    if (a != null && a.isNotEmpty) return a;
    if (b.isNotEmpty) return b;
    return null;
  }
}
