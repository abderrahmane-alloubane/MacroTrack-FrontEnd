class AppUser {
  final String id;
  final String email;
  final String name;
  final int dailyCalorieGoal;
  final double proteinRatio;
  final double fatRatio;
  final double carbsRatio;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.dailyCalorieGoal,
    this.proteinRatio = 30.0,
    this.fatRatio = 30.0,
    this.carbsRatio = 40.0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dailyCalorieGoal: json['dailyCalorieGoal'] as int? ?? 2000,
      proteinRatio: (json['proteinRatio'] as num?)?.toDouble() ?? 30.0,
      fatRatio: (json['fatRatio'] as num?)?.toDouble() ?? 30.0,
      carbsRatio: (json['carbsRatio'] as num?)?.toDouble() ?? 40.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': id,
    'email': email,
    'name': name,
    'dailyCalorieGoal': dailyCalorieGoal,
    'proteinRatio': proteinRatio,
    'fatRatio': fatRatio,
    'carbsRatio': carbsRatio,
  };
}
