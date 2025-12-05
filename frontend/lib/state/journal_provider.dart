// lib/state/journal_provider.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/navigation/navigation_service.dart';
import 'package:frontend/data/api/dio_client.dart';
import 'package:frontend/data/api/journal_service.dart';
import 'package:frontend/data/api/log_error_service.dart';
import 'package:frontend/data/models/ai_response.dart';
import 'package:frontend/data/models/journal_request.dart';
import 'package:frontend/data/user/user_service.dart';
import 'package:frontend/data/auth/auth_service.dart';

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
      // 1. 저널 제출 (서버가 즉시 응답)
      final Response<dynamic> res = await _dio.post<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/log',
        data: request.toJson(),
        options: Options(
          receiveTimeout: Duration(seconds: 40),
          sendTimeout: Duration(seconds: 20),
        ),
      );

      final int endTime = DateTime.now().millisecondsSinceEpoch;
      print('🟢 [SUBMIT SUCCESS] Total Latency: ${endTime - startTime}ms');
      print('📊 [RESPONSE] Status: ${res.statusCode}, Data: ${res.data}');

      // ⭐ 핵심 변경: 201 Created 응답 처리
      if (res.statusCode == 201 || res.statusCode == 200) {
        // 저널 제출 완료 마킹
        await UserService.instance.markJournalSubmittedToday();

        // responseCode가 0이면 AI 피드백 준비 중
        if (res.data is Map<String, dynamic>) {
          final responseData = res.data as Map<String, dynamic>;
          final int responseCode = responseData['responseCode'] ?? 0;

          if (responseCode == 0 || responseCode == 201) {
            // AI 피드백이 아직 준비되지 않음 → 폴링으로 가져오기
            print(
              '⏳ [POLLING START] AI feedback not ready yet, starting polling...',
            );

            AIResponse? feedback = await _pollForFeedback(
              maxAttempts: 8,
              intervalSeconds: 3,
            );

            if (feedback != null) {
              print('🎉 [POLLING SUCCESS] Feedback received!');
              await UserService.instance.saveLastFeedback(feedback);
              await NavigationService.navigateToFeedback(
                arguments: feedback,
                replace: true,
              );
            } else {
              // 24초(3초 x 8회) 후에도 피드백이 없으면
              print('⏰ [POLLING TIMEOUT] Feedback not ready after 24 seconds');
              await _showDelayedFeedbackMessage();
            }
            return;
          }
        }

        // responseCode가 200이고 AI 피드백이 함께 온 경우 (이전 방식 호환)
        AIResponse? ai;
        if (res.data is Map<String, dynamic>) {
          try {
            ai = AIResponse.fromJson(res.data as Map<String, dynamic>);
            await UserService.instance.saveLastFeedback(ai);
            await NavigationService.navigateToFeedback(
              arguments: ai,
              replace: true,
            );
            return;
          } catch (e) {
            print('⚠️ [PARSE WARNING] Could not parse as AIResponse: $e');
            // 파싱 실패 시 폴링으로 전환
            AIResponse? feedback = await _pollForFeedback(
              maxAttempts: 8,
              intervalSeconds: 3,
            );
            if (feedback != null) {
              await UserService.instance.saveLastFeedback(feedback);
              await NavigationService.navigateToFeedback(
                arguments: feedback,
                replace: true,
              );
            } else {
              await _showDelayedFeedbackMessage();
            }
          }
        }
      } else if (res.statusCode == 204) {
        // 204 No Content - 폴링으로 피드백 가져오기
        await UserService.instance.markJournalSubmittedToday();
        AIResponse? feedback = await _pollForFeedback(
          maxAttempts: 8,
          intervalSeconds: 3,
        );

        if (feedback != null) {
          await UserService.instance.saveLastFeedback(feedback);
          await NavigationService.navigateToFeedback(
            arguments: feedback,
            replace: true,
          );
        } else {
          await _showDelayedFeedbackMessage();
        }
      }
    } on DioException catch (e) {
      final int errorTime = DateTime.now().millisecondsSinceEpoch;
      print(
        '🔴 [SUBMIT ERROR] Error Time: $errorTime ms. Total Latency: ${errorTime - startTime}ms',
      );
      print(
        '🔴 [SUBMIT ERROR] Type: ${e.type}, Message: ${e.message}, Status: ${e.response?.statusCode}',
      );

      // 409 Conflict는 이미 제출된 경우이므로 특별 처리
      if (e.response?.statusCode == 409) {
        print('⚠️ [ALREADY SUBMITTED] Journal already submitted today');
        await UserService.instance.markJournalSubmittedToday();

        // 오늘의 피드백을 가져와서 화면 전환
        try {
          AIResponse? feedback = await JournalService.instance
              .fetchTodayJournalFeedback();
          if (feedback != null) {
            await UserService.instance.saveLastFeedback(feedback);
            await NavigationService.navigateToFeedback(
              arguments: feedback,
              replace: true,
            );
            return;
          }
        } catch (fetchError) {
          print(
            '⚠️ [FETCH ERROR] Could not fetch today\'s feedback: $fetchError',
          );
        }

        // 피드백을 가져오지 못하면 홈으로
        await NavigationService.navigateToFeedbackList(replace: true);
        return;
      }

      await _handleSubmissionError(
        e.response?.data is Map<String, dynamic>
            ? (e.response?.data['mentText'] as String? ??
                  e.response?.data['message'] as String? ??
                  e.message ??
                  '네트워크 오류가 발생했습니다.')
            : (e.message ?? '네트워크 오류가 발생했습니다.'),
      );
    } catch (e, stack) {
      print('🔴 [SUBMIT ERROR] _handleSubmissionError: Error Message: $e');
      await _handleSubmissionError('알 수 없는 오류: $e');
    } finally {
      _setSubmitting(false);
    }
  }

  /// AI 피드백을 폴링으로 가져오는 헬퍼 메서드
  Future<AIResponse?> _pollForFeedback({
    required int maxAttempts,
    required int intervalSeconds,
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      print('🔄 [POLLING] Attempt $attempt/$maxAttempts...');

      await Future.delayed(Duration(seconds: intervalSeconds));

      try {
        AIResponse? feedback = await JournalService.instance
            .fetchTodayJournalFeedback();

        if (feedback != null && feedback.mentText.isNotEmpty) {
          print('✅ [POLLING] Feedback found on attempt $attempt');
          return feedback;
        }

        print('⏳ [POLLING] No feedback yet, retrying...');
      } catch (e) {
        print('⚠️ [POLLING ERROR] Attempt $attempt failed: $e');
        // 404 에러는 정상 (아직 피드백이 없음)
        if (e is DioException && e.response?.statusCode == 404) {
          continue;
        }
        // 다른 에러는 재시도
        continue;
      }
    }

    print('❌ [POLLING] Max attempts reached, no feedback available');
    return null;
  }

  /// 피드백 지연 시 안내 메시지 표시
  Future<void> _showDelayedFeedbackMessage() async {
    // TODO: 다이얼로그 또는 스낵바로 안내
    print('💬 [INFO] AI 피드백이 지연되고 있습니다. 잠시 후 홈 화면에서 확인해주세요.');
    await NavigationService.navigateToFeedbackList(replace: true);
  }

  Future<void> _handleSubmissionError(String message) async {
    print('🔴 [SUBMIT ERROR] _handleSubmissionError: Error Message: $message');
    await LogErrorService.report(message);
    await NavigationService.showTemporaryErrorDialog();
  }
}
