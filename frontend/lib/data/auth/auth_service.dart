import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  static const String _tokenKey = 'jwt_token';

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
      aOptions: _androidOptions,
    );
  }

  Future<String?> getToken() async {
    return _storage.read(
      key: _tokenKey,
      aOptions: _androidOptions,
    );
  }

  Future<void> deleteToken() async {
    await _storage.delete(
      key: _tokenKey,
      aOptions: _androidOptions,
    );
  }
}


