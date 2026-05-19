import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/daily_summary.dart';

class ApiService {
  ApiService._();
  static const String _baseUrl = 'http://192.168.1.114:8080/api';
  //static const String _baseUrl = 'http://localhost:8080/api';
  static String? token;

  static bool isConnected = false;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      isConnected = response.statusCode == 200;
    } catch (_) {
      isConnected = false;
    }
    return isConnected;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['error'] as String? ?? 'Login failed');
    }
    token = body['token'] as String?;
    isConnected = true;
    return body;
  }

  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password, {
    int? calorieGoal,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'dailyCalorieGoal': ?calorieGoal,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['error'] as String? ?? 'Signup failed');
    }
    token = body['token'] as String?;
    isConnected = true;
    return body;
  }

  static Future<String> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/food/search?q=${Uri.encodeComponent(query)}'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to search products');
    } else if (response.statusCode == 504) {
      throw Exception('OpenFoodFacts failed');
    }
    return response.body;
  }

  static Future<String> getProductDetails(String barcode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/food/product/$barcode/details'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load product details');
    }
    return response.body;
  }

  static Future<void> forgotPassword(String email) async {
    // TODO: Implement actual forgot password API call
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<DailySummary> getDailySummary(String date) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/meals/daily?date=$date'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load daily data');
    }
    return DailySummary.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<void> addMealEntry({
    required String date,
    required String mealType,
    required String foodName,
    required int calories,
    double? carbs,
    double? protein,
    double? fat,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/meals'),
      headers: _headers,
      body: jsonEncode({
        'date': date,
        'mealType': mealType,
        'foodName': foodName,
        'calories': calories,
        'carbs': ?carbs,
        'protein': ?protein,
        'fat': ?fat,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add meal');
    }
  }

  static Future<void> deleteMealEntry(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/meals/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete meal');
    }
  }

  static Future<List<DailySummary>> getWeeklySummaries() async {
   final response = await http.get(
      Uri.parse('$_baseUrl/meals/weekly'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load weekly summary');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => DailySummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static void logout() {
    token = null;
    isConnected = false;
  }
}
