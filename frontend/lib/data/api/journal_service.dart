import 'package:dio/dio.dart';
import 'package:frontend/data/api/dio_client.dart';
import 'package:frontend/data/models/ai_response.dart';

class JournalService {
  JournalService._();
  static final JournalService instance = JournalService._();
  static final Dio _dio = DioClient.dio;

  /// 오늘 작성한 저널이 있다면 AIResponse를 반환하고,
  /// 작성하지 않았다면 null을 반환합니다.
  Future<AIResponse?> fetchTodayJournalFeedback() async {
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/log/latest',
      );

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return AIResponse.fromJson(res.data as Map<String, dynamic>);
      }

      if (res.statusCode == 204) {
        return null;
      }
    } catch (_) {
      // ignore: 네트워크/서버 오류 시 null 반환
    }
    return null;
  }
}

