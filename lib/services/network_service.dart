import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

/// Dio-based network service for all HTTP operations.
/// Single responsibility: configure Dio instances with auth headers,
/// timeouts, and retry interceptor.
class NetworkService {
  late final Dio _dio;
  late final Dio _unsplashDio;

  NetworkService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.pexelsBaseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Authorization': ApiConstants.pexelsApiKey,
      },
    ));

    _unsplashDio = Dio(BaseOptions(
      baseUrl: ApiConstants.unsplashBaseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Authorization': 'Client-ID ${ApiConstants.unsplashAccessKey}',
      },
    ));

    // Retry interceptor — retry once on failure (spec: fail silently, retry once)
    _dio.interceptors.add(_RetryInterceptor(_dio));
    _unsplashDio.interceptors.add(_RetryInterceptor(_unsplashDio));

    // Add logging interceptor in debug mode
    assert(() {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) {}, // Silent in production
      ));
      return true;
    }());
  }

  Dio get pexels => _dio;
  Dio get unsplash => _unsplashDio;
}

/// Simple retry-once interceptor.
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Retry once on connection/timeout errors
    if (_shouldRetry(err) && err.requestOptions.extra['retried'] != true) {
      try {
        err.requestOptions.extra['retried'] = true;
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {
        // Fall through to reject
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
