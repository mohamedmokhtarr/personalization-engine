import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GamificationProvider with ChangeNotifier {
  int totalXP = 0;
  int level = 1;
  List<dynamic> badges = []; // قائمة الأوسمة التي حصل عليها المستخدم (المفتوحة)

  // 1. أضفنا القائمة دي عشان شاشة الـ Rewards تعرف إيه الجوائز اللي لسه مخدهاش (المقفولة)
  final List<Map<String, String>> allPossibleBadges = [
    {'name': '7-Day Warrior', 'goal': 'Train for 7 days straight', 'icon': 'fire_icon'},
    {'name': 'Diversity King', 'goal': 'Try 3 different workout categories', 'icon': 'category_icon'},
    {'name': 'Stamina Master', 'goal': 'Complete a 30-minute workout', 'icon': 'timer_icon'},
  ];

  // قوائم لتخزين بيانات الجرافات القادمة من السيرفر
  List<double> xpHistory = [50, 120, 80, 150, 60, 90, 200]; // بيانات افتراضية
  List<double> weightHistory = [85.0, 84.2, 83.5, 82.0, 81.5, 80.8, 80.0];

  int get currentLevel {
    return (totalXP / 500).floor() + 1;
  }

  Future<void> fetchProgress(String userId) async {
    final url = Uri.parse('http://10.0.2.2:3000/api/stats/$userId');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // تحديث البيانات الأساسية
        totalXP = data['totalXP'] ?? 0; // تأكدي إن الباك إند بيبعت totalXP أو currentXP ووحديها هنا
        level = data['currentLevel'] ?? 1;
        
        // سحب الأوسمة من السيرفر
        badges = data['badges'] ?? []; 
        
        // تحديث تاريخ الـ XP والوزن
        if (data['xpHistory'] != null && (data['xpHistory'] as List).isNotEmpty) {
          xpHistory = List<double>.from(data['xpHistory'].map((x) => x.toDouble()));
        }
        
        if (data['weightHistory'] != null && (data['weightHistory'] as List).isNotEmpty) {
          weightHistory = List<double>.from(data['weightHistory'].map((x) => x.toDouble()));
        }
        
        notifyListeners(); 
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }
}