//lib/data/api/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:my_first_app/core/navigation/navigation_service.dart';
import 'package:my_first_app/data/auth/auth_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({AuthService? authService})
    : _authService = authService ?? AuthService.instance;

  final AuthService _authService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await _authService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print('🔑 [AUTH INTERCEPTOR] Token: $token');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🛑 [INTERCEPTOR ERROR] uri: ${err.requestOptions.uri}, Status: ${err.response?.statusCode}, Time: ${DateTime.now()}');
    final int? statusCode = err.response?.statusCode;
    final String? path = err.requestOptions.path;
    print(
      '🛑 [INTERCEPTOR ERROR] Path: $path, Status: $statusCode, Time: ${DateTime.now().toIso8601String()}',
    );
    if (statusCode == 401) {
      if (path!.contains('/log/latest')) {
        print('⚠️ [AUTH WARNING] 401 on polling endpoint, not logging out');
        super.onError(err, handler);
        return;
      }

      print('🚨 [AUTH ERROR] 401 detected. Navigating to login.');
      _handleUnauthorized();
    }
    handler.next(err);
  }

  Future<void> _handleUnauthorized() async {
    try {
      await _authService.deleteToken();
    } finally {
      // 라우트는 앱 전역 NavigatorKey를 통해 로그인 화면으로 이동
      await NavigationService.navigateToLoginAndClear();
    }
  }
}
