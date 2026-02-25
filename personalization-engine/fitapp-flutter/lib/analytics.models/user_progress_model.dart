class UserProgressModel {
  final int totalXP;
  final int level;
  final List<dynamic> badges;

  UserProgressModel({required this.totalXP, required this.level, required this.badges});

  // دالة بتحول الـ JSON اللي جاي من الـ Node.js لبيانات فلاتر تفهمها
  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      totalXP: json['currentXP'] ?? 0,
      level: json['currentLevel'] ?? 1,
      badges: json['badges'] ?? [],
    );
  }
}