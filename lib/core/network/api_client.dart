import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/constants/api_constants.dart';
import '../errors/app_exception.dart';

class ApiClient {
  ApiClient._(this._dio, this._cookieJar);

  final Dio _dio;
  final CookieJar _cookieJar;

  Dio get dio => _dio;

  CookieJar get cookieJar => _cookieJar;

  static Future<ApiClient> create() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/.cookies/'),
    );
    dio.interceptors.add(CookieManager(cookieJar));

    return ApiClient._(dio, cookieJar);
  }

  Future<String> cookieHeaderFor(Uri uri) async {
    final cookies = await _cookieJar.loadForRequest(uri);
    if (cookies.isEmpty) return '';
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData data,
  }) {
    return _request(
      () => _dio.post<T>(
        path,
        data: data,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() call) async {
    try {
      final response = await call();

      if (response.statusCode == 401) {
        throw const UnauthorizedException();
      }

      if (response.statusCode != null &&
          response.statusCode! >= 400 &&
          response.statusCode! < 500) {
        final message = _extractErrorMessage(response.data) ??
            'Request failed (${response.statusCode})';
        throw NetworkException(message, statusCode: response.statusCode);
      }

      if (response.statusCode != null && response.statusCode! >= 500) {
        throw NetworkException(
          'Server error (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }

      return response;
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw NetworkException(
        error.message ?? 'Network request failed',
        statusCode: error.response?.statusCode,
      );
    }
  }

  String? _extractErrorMessage(Object? data) {
    if (data is! Map) return null;

    if (data['message'] is String) {
      return data['message'] as String;
    }

    final error = data['error'];
    if (error is String) return error;
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }

    return null;
  }
}
