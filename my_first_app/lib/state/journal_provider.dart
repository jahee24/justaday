// lib/state/journal_provider.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:my_first_app/core/navigation/navigation_service.dart';
import 'package:my_first_app/data/api/dio_client.dart';
import 'package:my_first_app/data/api/journal_service.dart';
import 'package:my_first_app/data/api/log_error_service.dart';
import 'package:my_first_app/data/models/ai_response.dart';
import 'package:my_first_app/data/models/journal_request.dart';
import 'package:my_first_app/data/user/user_service.dart';
import 'package:my_first_app/data/auth/auth_service.dart';

class JournalProvider extends ChangeNotifier {
  final Dio _dio = DioClient.dio;

  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> submitJournal(JournalRequest request) async {
    _setError(null);
    final int startTime = DateTime.now().millisecondsSinceEpoch; 
    
    print('✅ [SUBMIT START] Starting submission at $startTime ms');
    // 하루에 한 번만 저널 입력 가능한지 확인
    final bool canSubmit = await UserService.instance.canSubmitJournalToday();
    if (!canSubmit) {
      _setError('하루에 한 번만 저널을 입력할 수 있습니다.');
      return;
    }
    
    _setSubmitting(true);
          final String? token = await AuthService.instance.getToken();
      print('📝 [LOG REPORT] Token exists: ${token != null && token.isNotEmpty}. Token value: $token');

    try {
      final Response<dynamic> res = await _dio.post<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/log',
        data: request.toJson(),
      );
      final int endTime = DateTime.now().millisecondsSinceEpoch; // ★ 성공 종료 시간 기록
      print('🟢 [SUBMIT SUCCESS] Total Latency: ${endTime - startTime}ms');

      AIResponse? ai;
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        ai = AIResponse.fromJson(res.data as Map<String, dynamic>);
      } else if (res.statusCode == 204 || res.data == null) {
        // 서버가 본문 없이 응답하는 경우 최신 피드백을 다시 조회
        ai = await JournalService.instance.fetchTodayJournalFeedback();
      }

      if (ai == null) {
        throw StateError('서버에서 피드백 데이터를 받지 못했습니다.');
      }

      await UserService.instance.markJournalSubmittedToday();
      await UserService.instance.saveLastFeedback(ai);

      await NavigationService.navigateToFeedback(
        arguments: ai,
        replace: true,
      );
    } on DioException catch (e) {
      final int errorTime = DateTime.now().millisecondsSinceEpoch; // ★ 오류 발생 시간 기록
      print('🔴 [SUBMIT ERROR] Error Time: $errorTime ms. Total Latency: ${errorTime - startTime}ms');
      print('🔴 [SUBMIT ERROR] Type: ${e.type}, Message: ${e.message}, Status: ${e.response?.statusCode}');
      await _handleSubmissionError(
        e.response?.data is Map<String, dynamic>
            ? (e.response?.data['message'] as String? ??
                e.message ??
                '네트워크 오류가 발생했습니다.')
            : (e.message ?? '네트워크 오류가 발생했습니다.'),
      );
    } catch (e, stack) {
      await _handleSubmissionError('알 수 없는 오류: $e\n$stack');
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> _handleSubmissionError(String message) async {
    print('🔴 [SUBMIT ERROR] _handleSubmissionError: Error Message: $message');
    await LogErrorService.report(message);
    await NavigationService.showTemporaryErrorDialog();
  }
}


