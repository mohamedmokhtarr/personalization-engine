import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GamificationProvider with ChangeNotifier {
  // 1. بيانات الجيميفيكيشن (من ياسمينا)
  int totalXP = 0;
  int streak = 0;
  List<dynamic> badges = []; 
  List<double> xpHistory = [];

  // 2. بيانات الوزن (من مختار)
  // خليتها تبدأ بقيم افتراضية عشان الجراف ميبقاش فاضي لو مفيش نت
  List<double> weightHistory = [85.0, 84.0, 84.5, 83.0, 82.5]; 

  // القائمة الكاملة للأوسمة (ثابتة في الموبايل للمقارنة ببيانات السيرفر)
  final List<Map<String, String>> allPossibleBadges = [
    {'name': 'First Step', 'goal': 'Reach 10 XP', 'icon': 'stars'},
    {'name': 'Getting Started', 'goal': 'Reach 50 XP', 'icon': 'emoji_events'},
    {'name': 'Dedicated', 'goal': 'Reach 100 XP', 'icon': 'workspace_premium'},
    {'name': 'Committed', 'goal': 'Reach 200 XP', 'icon': 'military_tech'},
    {'name': 'Very Experienced', 'goal': 'Reach 500 XP', 'icon': 'auto_awesome'},
  ];

  int get currentLevel {
    return (totalXP / 100).floor() + 1;
  }

  // --- الدالة الأساسية لجلب كل البيانات ---
  Future<void> fetchProgress([String userId = "yasmine-01"]) async {
    const String baseUrl = "http://localhost:5000"; // تأكدي من الـ IP والـ Port

    try {
      // أ- طلب بيانات الجيميفيكيشن (ياسمينا)
      final gamiUrl = Uri.parse('$baseUrl/api/gamification/status/$userId');
      final gamiResponse = await http.get(gamiUrl);

      if (gamiResponse.statusCode == 200) {
        final data = json.decode(gamiResponse.body);
        totalXP = data['totalXP'] ?? 0;
        streak = data['streak'] ?? 0;
        badges = data['badges'] ?? []; 
        
        if (data['xpHistory'] != null) {
          xpHistory = (data['xpHistory'] as List)
              .map((x) => (x['xp'] as num).toDouble())
              .toList();
        }
      }

      // ب- طلب بيانات الوزن التاريخية (مختار) - "التعديل الجديد"
      final profileUrl = Uri.parse('$baseUrl/api/profile/$userId');
      final profileResponse = await http.get(profileUrl);

      if (profileResponse.statusCode == 200) {
        final profileBody = json.decode(profileResponse.body);
        
        // الوصول للـ weightHistory بناءً على الـ Structure اللي مختار عمله
        // data -> profile -> weightHistory
        final List<dynamic>? historyFromApi = profileBody['data']?['profile']?['weightHistory'];
        
        if (historyFromApi != null && historyFromApi.isNotEmpty) {
          weightHistory = historyFromApi
              .map((item) => (item['weight'] as num).toDouble())
              .toList();
        } else {
          // لو مفيش تاريخ، بناخد الوزن الحالي بس ونعرضه
          double currentWeight = (profileBody['data']['profile']['weight'] as num).toDouble();
          weightHistory = [currentWeight];
        }
      }

      // إشعار الشاشات بالتحديث
      notifyListeners(); 
      print("System Integration: Fetched data from Gamification & Profile services.");

    } catch (e) {
      print("Connection Error: $e");
    }
  }

  Future<void> manualAddXP(int amount) async {
      totalXP += amount;
      notifyListeners();
  }
}