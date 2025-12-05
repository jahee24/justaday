import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:my_first_app/core/navigation/navigation_service.dart';
import 'package:my_first_app/data/api/dio_client.dart';
import 'package:my_first_app/data/api/journal_service.dart';
import 'package:my_first_app/data/auth/auth_service.dart';
import 'package:my_first_app/data/models/ai_response.dart';
import 'package:my_first_app/data/models/login_response.dart';
import 'package:my_first_app/data/user/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final Dio _dio = DioClient.dio;
  final AuthService _authService = AuthService.instance;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> login({required String userId, required String password}) async {
    _setError(null);
    _setLoading(true);
    try {
      final Response<dynamic> res = await _dio.post<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/auth/login',
        data: <String, dynamic>{'userId': userId, 'password': password},
      );
      
      // 응답 데이터 확인
      if (res.data == null) {
        _setError('서버 응답이 없습니다.');
        return;
      }

      // 응답이 Map인지 확인
      if (res.data is! Map<String, dynamic>) {
        _setError('서버 응답 형식이 올바르지 않습니다.');
        return;
      }

      final LoginResponse parsed = LoginResponse.fromJson(res.data as Map<String, dynamic>);
      await _authService.saveToken(parsed.token);
      
      await _routeAfterAuth();
    } on DioException catch (_) {
      _setError('일시적인 오류가 발생했습니다. 다시 시도해주세요.');
    } catch (_) {
      _setError('일시적인 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup({required String userId, required String password}) async {
    _setError(null);
    _setLoading(true);
    try {
      final Response<dynamic> res = await _dio.post<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/auth/signup',
        data: <String, dynamic>{'userId': userId, 'password': password, 'aiPersonaId': 0},
      );
      
      // 응답 데이터 확인
      if (res.data == null) {
        _setError('서버 응답이 없습니다.');
        return;
      }

      // 회원가입 응답은 로그인 응답과 다를 수 있음
      // 응답이 Map이고 token 필드가 있는 경우에만 처리
      if (res.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = res.data as Map<String, dynamic>;
        
        // 토큰이 있는 경우에만 저장
        if (data.containsKey('token') && data['token'] is String) {
          final String token = data['token'] as String;
          await _authService.saveToken(token);
        }
      }
      
      await NavigationService.navigateToPersona();
    } on DioException catch (e) {
      final String? errorMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message'] as String?
          : null;
      _setError(errorMessage ?? e.message ?? '네트워크 오류가 발생했습니다.');
      _setLoading(false);
    } catch (e) {
      _setError('회원가입 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }
  
  Future<void> _routeAfterAuth() async {
    try {
      final Response<dynamic> userRes = await _dio.get<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/user',
      );

      if (userRes.data is Map<String, dynamic>) {
        final Map<String, dynamic> userData = userRes.data as Map<String, dynamic>;
        final int? personaId = userData['aiPersonaId'] as int?;
        final String? name = userData['name'] as String?;

        if (personaId != null) {
          await UserService.instance.savePersonaId(personaId);
        }
        if (name != null && name.isNotEmpty) {
          await UserService.instance.saveUserName(name);
        }

        await _navigateBasedOnState(personaId);
        return;
      }
    } catch (_) {
      // ignore and fallback
    }
    await NavigationService.navigateToPersona();
  }

  Future<void> _navigateBasedOnState(int? personaId) async {
    if (personaId == null || personaId == 0) {
      await NavigationService.navigateToPersona();
      return;
    }

    final bool hasName = await UserService.instance.hasUserName();
    if (!hasName) {
      await NavigationService.navigateToNameSetting(replace: true);
      return;
    }

    // 서버에서 오늘 작성한 저널 피드백 조회
    AIResponse? todayFeedback =        await JournalService.instance.fetchTodayJournalFeedback();
    if (todayFeedback != null) {
      await UserService.instance.saveLastFeedback(todayFeedback);
      await NavigationService.navigateToFeedback(
        arguments: todayFeedback,
        replace: true,
      );
      return;
    }

    // 오늘 작성한 저널이 없으면 저널 입력 화면으로
    await NavigationService.navigateToRecord();
  }
}
