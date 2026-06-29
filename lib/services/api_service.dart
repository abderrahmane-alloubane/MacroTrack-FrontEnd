import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/daily_summary.dart';
import './api_details.dart';

class ApiService {
  ApiService._();
  
  static String get _baseUrl => Api().getAdr();
  static String? token;

  static bool isConnected = false;

  static double proteinRatio = 40.0;
  static double fatRatio = 20.0;
  static double carbsRatio = 40.0;
  static int dailyCalorieGoal = 2000;

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
    dailyCalorieGoal = body['dailyCalorieGoal'] as int? ?? 2000;
    proteinRatio = (body['proteinRatio'] as num?)?.toDouble() ?? 30.0;
    fatRatio = (body['fatRatio'] as num?)?.toDouble() ?? 30.0;
    carbsRatio = (body['carbsRatio'] as num?)?.toDouble() ?? 40.0;
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
    dailyCalorieGoal = body['dailyCalorieGoal'] as int? ?? 2000;
    proteinRatio = (body['proteinRatio'] as num?)?.toDouble() ?? 30.0;
    fatRatio = (body['fatRatio'] as num?)?.toDouble() ?? 30.0;
    carbsRatio = (body['carbsRatio'] as num?)?.toDouble() ?? 40.0;
    return body;
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    int? dailyCalorieGoal,
    double? proteinRatio,
    double? fatRatio,
    double? carbsRatio,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/user/profile'),
      headers: _headers,
      body: jsonEncode({
        'name': ?name,
        'dailyCalorieGoal': ?dailyCalorieGoal,
        'proteinRatio': ?proteinRatio,
        'fatRatio': ?fatRatio,
        'carbsRatio': ?carbsRatio,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['error'] as String? ?? 'Failed to update profile');
    }
    ApiService.dailyCalorieGoal = body['dailyCalorieGoal'] as int? ?? ApiService.dailyCalorieGoal;
    ApiService.proteinRatio = (body['proteinRatio'] as num?)?.toDouble() ?? ApiService.proteinRatio;
    ApiService.fatRatio = (body['fatRatio'] as num?)?.toDouble() ?? ApiService.fatRatio;
    ApiService.carbsRatio = (body['carbsRatio'] as num?)?.toDouble() ?? ApiService.carbsRatio;
    return body;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/profile'),
      headers: _headers,
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['error'] as String? ?? 'Failed to load profile');
    }
    dailyCalorieGoal = body['dailyCalorieGoal'] as int? ?? 2000;
    proteinRatio = (body['proteinRatio'] as num?)?.toDouble() ?? 30.0;
    fatRatio = (body['fatRatio'] as num?)?.toDouble() ?? 30.0;
    carbsRatio = (body['carbsRatio'] as num?)?.toDouble() ?? 40.0;
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
