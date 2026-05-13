class DailySummary {
  final String date;
  final int totalCalories;
  final double totalCarbs;
  final double totalProtein;
  final double totalFat;
  final int calorieGoal;
  final List<MealGroup> meals;

  DailySummary({
    required this.date,
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalProtein,
    required this.totalFat,
    required this.calorieGoal,
    required this.meals,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: json['date'] as String? ?? '',
      totalCalories: json['totalCalories'] as int? ?? 0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0,
      calorieGoal: json['calorieGoal'] as int? ?? 2000,
      meals: (json['meals'] as List<dynamic>?)
              ?.map((m) => MealGroup.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  DailySummary copyWith({
    String? date,
    int? totalCalories,
    double? totalCarbs,
    double? totalProtein,
    double? totalFat,
    int? calorieGoal,
    List<MealGroup>? meals,
  }) {
    return DailySummary(
      date: date ?? this.date,
      totalCalories: totalCalories ?? this.totalCalories,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalProtein: totalProtein ?? this.totalProtein,
      totalFat: totalFat ?? this.totalFat,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      meals: meals ?? this.meals,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'totalCalories': totalCalories,
        'totalCarbs': totalCarbs,
        'totalProtein': totalProtein,
        'totalFat': totalFat,
        'calorieGoal': calorieGoal,
        'meals': meals.map((m) => m.toJson()).toList(),
      };
}

class MealGroup {
  final String name;
  final int calories;
  final List<FoodItem> items;

  MealGroup({
    required this.name,
    required this.calories,
    required this.items,
  });

  factory MealGroup.fromJson(Map<String, dynamic> json) {
    return MealGroup(
      name: json['name'] as String? ?? '',
      calories: json['calories'] as int? ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => FoodItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  MealGroup copyWith({
    String? name,
    int? calories,
    List<FoodItem>? items,
  }) {
    return MealGroup(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class FoodItem {
  final String id;
  final String name;
  final int calories;

  FoodItem({required this.id, required this.name, required this.calories});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic id) {
      if (id == null) return '';
      if (id is String) return id;
      if (id is Map) return (id['\$oid'] as String?) ?? '';
      return id.toString();
    }

    return FoodItem(
      id: parseId(json['id'] ?? json['_id']),
      name: json['name'] as String? ?? '',
      calories: json['calories'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'calories': calories};
}
