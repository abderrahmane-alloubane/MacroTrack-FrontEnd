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

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class FoodItem {
  final String name;
  final int calories;

  FoodItem({required this.name, required this.calories});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String? ?? '',
      calories: json['calories'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'calories': calories};
}
