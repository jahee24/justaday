import 'package:dio/dio.dart';
import 'package:justaday/data/api/dio_client.dart';
import 'package:justaday/data/models/ai_response.dart';

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
        // print('✅ [JOURNAL SERVICE] Feedback ready (200)');
        return AIResponse.fromJson(res.data as Map<String, dynamic>);
      }
      if (res.statusCode == 202) {
        // print('⏳ [JOURNAL SERVICE] Feedback pending (202)');
        return null;
      }
      if (res.statusCode == 204) {
        return null;
      }
      if (res.statusCode == 404) {
        return null;
      }

    } on DioException catch (e) {
      // 202, 404는 정상 상황이므로 null 반환
      if (e.response?.statusCode == 202 || e.response?.statusCode == 404) {
        return null;
      }

      // print('⚠️ [JOURNAL SERVICE ERROR] ${e.response?.statusCode}: ${e.message}');
      // 다른 에러는 상위로 전파
      rethrow;
    } catch (_) {
      // ignore: 네트워크/서버 오류 시 null 반환
    }
    return null;
  }
}

