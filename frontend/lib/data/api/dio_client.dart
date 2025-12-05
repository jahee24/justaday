//lib/data/api/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_first_app/data/api/interceptors/auth_interceptor.dart';

class DioClient {
  DioClient._internal() {
    final BaseOptions baseOptions = BaseOptions(
      // baseUrl는 HTTPS만 사용하도록 가정합니다. 필요 시 교체하세요.
      baseUrl: '',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 40),
      sendTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
      headers: <String, dynamic>{
        'Accept': 'application/json',
      },
    );

    _dio = Dio(baseOptions);

    // 모든 요청이 HTTPS를 사용하도록 강제
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          final Uri uri = options.uri;
          if (uri.scheme.toLowerCase() != 'https') {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Only HTTPS requests are allowed: ${uri.toString()}',
                type: DioExceptionType.badCertificate,
              ),
            );
          }
          handler.next(options);
        },
      ),
    );

    // 디버그 시 로그 출력
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }

    // 인증 토큰 추가 및 401 처리 인터셉터
    _dio.interceptors.add(AuthInterceptor());
  }

  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  static Dio get dio => _instance._dio;
}


