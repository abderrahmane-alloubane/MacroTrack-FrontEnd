class AppUser {
  final String id;
  final String email;
  final String name;
  final int dailyCalorieGoal;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.dailyCalorieGoal,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dailyCalorieGoal: json['dailyCalorieGoal'] as int? ?? 2000,
    );
  }
}
