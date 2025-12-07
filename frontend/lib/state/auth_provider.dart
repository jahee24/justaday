import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/navigation/navigation_service.dart';
import 'package:frontend/data/api/dio_client.dart';
import 'package:frontend/data/api/journal_service.dart';
import 'package:frontend/data/auth/auth_service.dart';
import 'package:frontend/data/models/ai_response.dart';
import 'package:frontend/data/models/login_response.dart';
import 'package:frontend/data/user/user_service.dart';
import 'package:frontend/state/journal_provider.dart';

class AuthProvider extends ChangeNotifier {
  final Dio _dio = DioClient.dio;
  final AuthService _authService = AuthService.instance;

  bool _isLoading = false;
  String? _error;
  String? _idcheckError;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get idcheckError => _idcheckError;

  void clearError() {
    _error = null;
    _idcheckError = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> checkIdAvailability(String userId) async {
    if (userId.isEmpty) {
      _idcheckError = null;
      notifyListeners();
      return false;
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/auth/check-id',
        queryParameters: {'userId': userId},
      );
      final bool isAvailable = response.data?['isAvailable'] ?? false;
      if (isAvailable) {
        _idcheckError = null;
      } else {
        _idcheckError = '이미 사용 중인 아이디입니다.';
      }
      notifyListeners();
      return isAvailable;
    } catch (e) {
      _idcheckError = '아이디 확인 중 오류 발생';
      notifyListeners();
      return false;
    }
  }

  Future<void> login({required String userId, required String password}) async {
    _setError(null);
    _setLoading(true);
    try {
      final Response<dynamic> res = await _dio.post<dynamic>(
        '/api/v1/auth/login',
        data: <String, dynamic>{'userId': userId, 'password': password},
      );

      if (res.data == null || res.data is! Map<String, dynamic>) {
        _setError('서버 응답이 올바르지 않습니다.');
        return;
      }

      final LoginResponse parsed = LoginResponse.fromJson(
        res.data as Map<String, dynamic>,
      );
      await _authService.saveToken(parsed.token);

      await _routeAfterAuth();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _setError('아이디 또는 비밀번호가 일치하지 않습니다.');
      } else {
        _setError('일시적인 오류가 발생했습니다. 다시 시도해주세요.');
      }
    } catch (_) {
      _setError('일시적인 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup({
    required String userId,
    required String password,
  }) async {
    _setError(null);
    _setLoading(true);
    try {
      // 회원가입 전 최종 아이디 유효성 검사
      final isAvailable = await checkIdAvailability(userId);
      if (!isAvailable) {
        _setError(_idcheckError ?? '아이디를 사용할 수 없습니다.');
        _setLoading(false);
        return;
      }

      await _dio.post<dynamic>(
        '/api/v1/auth/signup',
        data: <String, dynamic>{
          'userId': userId,
          'password': password,
          'aiPersonaId': 0,
        },
      );
      await login(userId: userId, password: password);
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

  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    try {
      await NavigationService.navigateToLoginAndClear();
      Provider.of<JournalProvider>(context, listen: false).resetState();

      await _authService.deleteToken();
      await UserService.instance.clearUserData();

      print('🔒 [LOGOUT] User logged out, all states cleared.');

      await NavigationService.navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } catch (e) {
      print('🔴 [LOGOUT ERROR] Failed to logout: $e');
      await NavigationService.navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _routeAfterAuth() async {
    try {
      final Response<dynamic> userRes = await _dio.get<dynamic>(
        'https://divine-tenderness-production-9284.up.railway.app/api/v1/user',
      );

      if (userRes.data is Map<String, dynamic>) {
        final Map<String, dynamic> userData =
            userRes.data as Map<String, dynamic>;
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

    AIResponse? todayFeedback = await JournalService.instance
        .fetchTodayJournalFeedback();
    if (todayFeedback != null) {
      await UserService.instance.saveLastFeedback(todayFeedback);
      await NavigationService.navigateToFeedback(
        arguments: todayFeedback,
        replace: true,
      );
      return;
    }

    await NavigationService.navigateToRecord();
  }
}
