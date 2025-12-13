// lib/data/user/user_service.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:justaday/data/models/ai_response.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  static const String _keyUserName = 'user_name';
  static const String _keyPersonaId = 'user_persona_id';
  static const String _keyLastJournalDate = 'last_journal_date';
  static const String _keyLastFeedback = 'last_feedback';

  Future<void> saveUserName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  Future<String?> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  Future<void> savePersonaId(int personaId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPersonaId, personaId);
  }

  Future<int?> getPersonaId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPersonaId);
  }

  Future<bool> hasUserName() async {
    final String? name = await getUserName();
    return name != null && name.isNotEmpty;
  }

  Future<bool> canSubmitJournalToday() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime now = DateTime.now();
    final String today = '${now.year}-${now.month}-${now.day}';
    final String? lastDate = prefs.getString(_keyLastJournalDate);
    // print('lastDate: $lastDate, today: $today');
    return lastDate != today;
  }

  Future<void> markJournalSubmittedToday() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime now = DateTime.now();
    final String today = '${now.year}-${now.month}-${now.day}';
    await prefs.setString(_keyLastJournalDate, today);
  }

  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyPersonaId);
    await prefs.remove(_keyLastJournalDate);
    await prefs.remove(_keyLastFeedback);
  }

  Future<void> saveLastFeedback(AIResponse response) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastFeedback, jsonEncode(response.toJson()));
  }

  Future<AIResponse?> getLastFeedback() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_keyLastFeedback);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return AIResponse.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

