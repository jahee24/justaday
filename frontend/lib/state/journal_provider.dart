// lib/state/journal_provider.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:justaday/core/navigation/navigation_service.dart';
import 'package:justaday/data/api/dio_client.dart';
import 'package:justaday/data/api/journal_service.dart';
import 'package:justaday/data/api/log_error_service.dart';
import 'package:justaday/data/models/ai_response.dart';
import 'package:justaday/data/models/journal_request.dart';
import 'package:justaday/data/user/user_service.dart';
import 'package:justaday/data/auth/auth_service.dart';

class JournalProvider extends ChangeNotifier {
  final Dio _dio = DioClient.dio;

  bool _isSubmitting = false;
  String? _error;
  bool _hasSubmittedToday = false;
  bool _isCheckingStatus = true;
  AIResponse? _latestFeedback; // 1. 최신 피드백을 저장할 상태 변수 추가

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  bool get hasSubmittedToday => _hasSubmittedToday;
  bool get isCheckingStatus => _isCheckingStatus;
  AIResponse? get latestFeedback => _latestFeedback; // 2. getter 추가

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> checkSubmissionStatus() async {
    _isCheckingStatus = true;
    notifyListeners();

    try {
      final feedback = await JournalService.instance.fetchTodayJournalFeedback();
      if (feedback != null) {
        _hasSubmittedToday = true;
        _latestFeedback = feedback; // 3. 상태 확인 시에도 피드백 저장
      } else {
        _hasSubmittedToday = false;
        _latestFeedback = null;
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        _hasSubmittedToday = false;
        _latestFeedback = null;
      } else {
        _error = "상태를 확인하는 중 오류가 발생했습니다.";
        _hasSubmittedToday = false;
        _latestFeedback = null;
        // print('🔴 [STATUS CHECK ERROR] $e');
      }
    } finally {
      _isCheckingStatus = false;
      notifyListeners();
    }
  }

  Future<void> submitJournal(JournalRequest request) async {
    _setError(null);
    _setSubmitting(true);

    try {
      final Response<dynamic> res = await _dio.post<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/log',
        data: request.toJson(),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        await UserService.instance.markJournalSubmittedToday();

        // print('⏳ [POLLING START] AI feedback not ready yet, starting polling...');
        // 4. 폴링 시작 (기존 로직 유지)
        await _pollForFeedback(maxAttempts: 8, intervalSeconds: 3);
        // 5. 폴링이 끝나면 (성공이든 실패든) 상태를 다시 확인하여 UI를 갱신
        await checkSubmissionStatus();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // print('⚠️ [ALREADY SUBMITTED] Journal already submitted today');
        await UserService.instance.markJournalSubmittedToday();
        // 이미 제출된 경우에도 상태를 다시 확인하여 UI를 동기화
        await checkSubmissionStatus();
      } else {
        await _handleSubmissionError(e.response?.data['message'] ?? '제출 중 오류가 발생했습니다.');
      }
    } catch (e) {
      await _handleSubmissionError('알 수 없는 오류: ${e.toString()}');
    } finally {
      _setSubmitting(false);
    }
  }

  // _pollForFeedback 메서드는 화면 이동 로직이 없으므로 수정할 필요 없이 그대로 둡니다.
  Future<AIResponse?> _pollForFeedback({
    required int maxAttempts,
    required int intervalSeconds,
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      // print('🔄 [POLLING] Attempt $attempt/$maxAttempts...');
      await Future.delayed(Duration(seconds: intervalSeconds));
      try {
        AIResponse? feedback = await JournalService.instance.fetchTodayJournalFeedback();
        if (feedback != null && (feedback.responseCode != 102 && feedback.mentText.isNotEmpty)) {
          // print('✅ [POLLING] Feedback found on attempt $attempt');
          return feedback;
        }
        // print('⏳ [POLLING] No feedback yet, retrying...');
      } catch (e) {
        // print('⚠️ [POLLING ERROR] Attempt $attempt failed: $e');
        if (e is DioException && e.response?.statusCode == 401) {
          // print('❌ [POLLING ABORT] Authentication error, stopping polling');
          return null;
        }
      }
    }
    // print('❌ [POLLING] Max attempts reached, no feedback available');
    return null;
  }

  // _showDelayedFeedbackMessage와 _handleSubmissionError는 화면 이동 로직을 포함하므로,
  // 이 부분은 상태 갱신 후 MainRecordScreen에서 처리하도록 비워두거나 다른 방식으로 처리해야 합니다.
  // 여기서는 일단 그대로 두겠습니다.
  Future<void> _showDelayedFeedbackMessage() async {
    // print('💬 [INFO] AI 피드백이 지연되고 있습니다. 잠시 후 홈 화면에서 확인해주세요.');
    // await NavigationService.navigateToFeedbackList(replace: true); // 화면 이동 제거
  }

  Future<void> _handleSubmissionError(String message) async {
    // print('🔴 [SUBMIT ERROR] _handleSubmissionError: Error Message: $message');
    _setError(message); // 에러 상태만 설정
    // await LogErrorService.report(message);
    // await NavigationService.showTemporaryErrorDialog();
  }

  void resetState() {
    _isSubmitting = false;
    _error = null;
    _hasSubmittedToday = false;
    _isCheckingStatus = true;
    _latestFeedback = null; // 6. resetState에도 추가
    notifyListeners();
    // print('🔄 [STATE RESET] JournalProvider has been reset.');
  }
}
