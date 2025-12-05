//lib/data/api/log_error_service.dart
import 'package:dio/dio.dart';
import 'package:my_first_app/data/auth/auth_service.dart';

class LogErrorService {
  LogErrorService._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://divine-tenderness-production-9284.up.railway.app',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static Future<void> report(String message) async {
    try {
      final String? token = await AuthService.instance.getToken();
      print('📝 [LOG REPORT] Token exists: ${token != null && token.isNotEmpty}. Token value: $token');
      await _dio.post<dynamic>(
        '/api/v1/log/error/message',
        data: <String, dynamic>{'message': message},
        options: Options(
          headers: <String, String>{
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (_) {
      // 서버 전달 실패 시 무시
    }
  }
}


