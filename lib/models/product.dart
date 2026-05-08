class Product {
  final String id;
  final String name;
  final String? brand;
  final String? servingSize;
  final int calories;
  final double? carbs;
  final double? protein;
  final double? fat;
  final double? sugar;
  final double? saturatedFat;

  Product({
    required this.id,
    required this.name,
    this.brand,
    this.servingSize,
    required this.calories,
    this.carbs,
    this.protein,
    this.fat,
    this.sugar,
    this.saturatedFat,
  });

  factory Product.fromSearchJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};
    return Product(
      id: (json['_id'] as String?) ?? '',
      name: (json['product_name'] as String?) ?? 'Unknown',
      brand: json['brands'] as String?,
      servingSize: json['serving_size'] as String?,
      calories: _parseNutriment(nutriments['energy-kcal_serving']),
      carbs: _parseNutrimentDouble(nutriments['carbohydrates_serving']),
      protein: _parseNutrimentDouble(nutriments['proteins_serving']),
      fat: _parseNutrimentDouble(nutriments['fat_serving']),
      sugar: _parseNutrimentDouble(nutriments['sugars_serving']),
      saturatedFat: _parseNutrimentDouble(nutriments['saturated-fat_serving']),
    );
  }

  factory Product.fromDetailsJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'Unknown',
      brand: null,
      servingSize: json['servingSize'] as String?,
      calories: _parseInt(json['servingCal']),
      carbs: _parseDouble(json['servingCarbs']),
      protein: _parseDouble(json['servingProtein']),
      fat: _parseDouble(json['servingFat']),
      sugar: _parseDouble(json['servingSugar']),
      saturatedFat: _parseDouble(json['servingSatFat']),
    );
  }

  static int _parseNutriment(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.round();
    final parsed = double.tryParse(value.toString());
    return parsed?.round() ?? 0;
  }

  static double? _parseNutrimentDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
