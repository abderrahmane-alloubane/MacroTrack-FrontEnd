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
  final double? ServingSize;
  double? servingGrams;

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
    this.ServingSize,
    this.servingGrams,
  });

  factory Product.fromSearchJson(Map<String, dynamic> json) {
    String parseId(dynamic id) {
      if (id == null) return '';
      if (id is String) return id;
      if (id is Map) return (id['\$oid'] as String?) ?? '';
      return id.toString();
    }

    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};
    return Product(
      id: parseId(json['_id'] ?? json['id']),
      name: (json['product_name'] ?? json['name'] ?? 'Unknown') as String,
      brand: json['brands'] as String?,
      servingSize: json['serving_size'] as String?,
      calories: _parseNutriment(
        nutriments['energy-kcal_serving'] ?? json['calories'],
      ),
      carbs: _parseNutrimentDouble(
        nutriments['carbohydrates_serving'] ?? json['carbs'],
      ),
      protein: _parseNutrimentDouble(
        nutriments['proteins_serving'] ?? json['protein'],
      ),
      fat: _parseNutrimentDouble(
        nutriments['fat_serving'] ?? json['fat'],
      ),
      sugar: _parseNutrimentDouble(
        nutriments['sugars_serving'] ?? json['sugar'],
      ),
      saturatedFat: _parseNutrimentDouble(
        nutriments['saturated-fat_serving'] ?? json['saturatedFat'],
      ),
      ServingSize: _parseNutrimentDouble(
        nutriments['serving_size'] ?? json['servingSize'],
      ),
    );
  }

  factory Product.fromDetailsJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      name: (json['name'] ?? json['product_name'] ?? 'Unknown') as String,
      brand: json['brands'] as String?,
      servingSize: (json['servingSize'] ?? json['serving_size']) as String?,
      calories: _parseInt(json['servingCal'] ?? json['serving_cal']),
      carbs: _parseDouble(json['servingCarbs'] ?? json['serving_carbs']),
      protein: _parseDouble(json['servingProtein'] ?? json['serving_Protein'] ?? json['serving_protein']),
      fat: _parseDouble(json['servingFat'] ?? json['serving_fat']),
      sugar: _parseDouble(json['servingSugar'] ?? json['serving_sugar']),
      saturatedFat: _parseDouble(json['servingSatFat'] ?? json['serving_satFat'] ?? json['serving_sat_fat']),
      ServingSize: _parseNutrimentDouble(json['serving_size'] ?? json['servingSize']),
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
