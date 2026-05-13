import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_summary.dart';

class LocalStorageService {
  LocalStorageService._();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';
  static const _dailyPrefix = 'daily_summary_';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data != null) return jsonDecode(data) as Map<String, dynamic>;
    return null;
  }

  static Future<void> saveDailySummary(DailySummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '$_dailyPrefix${summary.date}', jsonEncode(summary.toJson()));
  }

  static Future<DailySummary?> getDailySummary(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_dailyPrefix$date');
    if (data != null) {
      return DailySummary.fromJson(jsonDecode(data) as Map<String, dynamic>);
    }
    return null;
  }

  static Future<void> removeDailySummary(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_dailyPrefix$date');
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
