// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// // استيراد ملفات مختار
// import 'models/models.dart';
// import 'screens/profile_screen.dart';
// import 'screens/goal_screen.dart';
// import 'screens/workout_screen.dart';
// import 'screens/plan_screen.dart';

// // استيراد ملفات بسنت وياسمينا (تأكدي من صحة المسارات عندك)
// import 'providers/gamification_provider.dart';
// import 'analytics.screens/progress_dashboard.dart';

// // استيراد ملفات الطرف الثالث (Workout Library)
// import 'features/workout_library/presentation/workout_library_screen.dart';

// void main() {
//   runApp(
//     // تغليف التطبيق بالـ Provider بتاع بسنت عشان يشتغل في كل الشاشات
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => GamificationProvider()),
//       ],
//       child: const FitApp(),
//     ),
//   );
// }

// class FitApp extends StatelessWidget {
//   const FitApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TrainVerse',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         // استخدمنا ثيم مختار لأنه الأشيك والأكثف (Dark Mode)
//         colorScheme: const ColorScheme.dark(primary: Color(0xFFa78bfa)),
//         scaffoldBackgroundColor: const Color(0xFF070A0E),
//         fontFamily: 'Cairo',
//       ),
//       home: const AppShell(),
//     );
//   }
// }

// class AppShell extends StatefulWidget {
//   const AppShell({super.key});

//   @override
//   State<AppShell> createState() => _AppShellState();
// }

// class _AppShellState extends State<AppShell> {
//   int _tab = 0;

//   // بيانات مختار (Profile & Goal)
//   UserProfile? _profile;
//   FitnessGoal? _goal;
//   static const _userId = 'user_001';

//   @override
//   Widget build(BuildContext context) {
//     // قائمة الشاشات المدمجة (6 شاشات)
//     final screens = [
//       ProfileScreen(
//         userId: _userId,
//         onProfileSaved: (p) => setState(() => _profile = p),
//       ),
//       // شاشة الداشبورد (شغل بسنت)
//       ProgressDashboard(), 
//       // مكتبة التمارين (شغل الطرف الثالث)
//       const WorkoutLibraryScreen(),
//       GoalScreen(
//         userId: _userId,
//         onGoalSaved: (g) => setState(() => _goal = g),
//       ),
//       WorkoutScreen(injury: _profile?.injury ?? 'none'),
//       PlanScreen(userId: _userId),
//     ];

//     return Scaffold(
//       body: IndexedStack(index: _tab, children: screens),
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Color(0xFF0D1117),
//           border: Border(top: BorderSide(color: Color(0xFF1F2937))),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: SingleChildScrollView( // عشان الأيكونات متزحمش لو الشاشة صغيرة
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _navItem(0, Icons.person_outline, Icons.person, 'الملف'),
//                   _navItem(1, Icons.analytics_outlined, Icons.analytics, 'التقدم'), // شاشتك
//                   _navItem(2, Icons.library_books_outlined, Icons.library_books, 'المكتبة'), // المكتبة
//                   _navItem(3, Icons.flag_outlined, Icons.flag, 'الهدف'),
//                   _navItem(4, Icons.fitness_center_outlined, Icons.fitness_center, 'التمارين'),
//                   _navItem(5, Icons.calendar_today_outlined, Icons.calendar_today, 'الخطة'),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _navItem(int idx, IconData outline, IconData filled, String label) {
//     final active = _tab == idx;
//     return GestureDetector(
//       onTap: () => setState(() => _tab = idx),
//       behavior: HitTestBehavior.opaque,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: active ? const Color(0xFFa78bfa).withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Icon(active ? filled : outline, color: active ? const Color(0xFFa78bfa) : const Color(0xFF4B5563), size: 22),
//           const SizedBox(height: 3),
//           Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
//             fontWeight: active ? FontWeight.bold : FontWeight.normal,
//             color: active ? const Color(0xFFa78bfa) : const Color(0xFF4B5563))),
//         ]),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// استيراد ملفات مختار
import 'models/models.dart';
import 'screens/profile_screen.dart';
import 'screens/goal_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/plan_screen.dart';

// استيراد ملفات بسنت وياسمينا
import 'providers/gamification_provider.dart';
import 'analytics.screens/progress_dashboard.dart';

// استيراد ملفات الطرف الثالث
import 'features/workout_library/presentation/workout_library_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // الـ Provider بتاعك يا بسنت اللي بيشغل الـ XP والـ Rewards
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
      ],
      child: const FitApp(),
    ),
  );
}

class FitApp extends StatelessWidget {
  const FitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(primary: Color(0xFFa78bfa)),
        scaffoldBackgroundColor: const Color(0xFF070A0E),
        fontFamily: 'Cairo', // اتأكدي إن الفونت متعرف في الـ pubspec
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  // بيانات مختار لربط الشاشات ببعض
  UserProfile? _profile;
  FitnessGoal? _goal;
  static const _userId = 'user_001';

  @override
  Widget build(BuildContext context) {
    // مصفوفة الشاشات المدمجة - الترتيب هنا هو اللي بيحدد الأيقونة بتفتح إيه
    final List<Widget> screens = [
      ProfileScreen(
        userId: _userId,
        onProfileSaved: (p) => setState(() => _profile = p),
      ),
       ProgressDashboard(), // شاشتك يا بسنت (التقدم والجوائز)
      const WorkoutLibraryScreen(), // مكتبة التمارين
      GoalScreen(
        userId: _userId,
        onGoalSaved: (g) => setState(() => _goal = g),
      ),
      WorkoutScreen(injury: _profile?.injury ?? 'none'),
      PlanScreen(userId: _userId),
    ];

    return Scaffold(
      // IndexedStack بيحافظ على حالة الشاشة لما تتنقلي (ما بيعملش Reload)
      body: IndexedStack(
        index: _tab,
        children: screens,
      ),
      bottomNavigationBar: Container(
        height: 70, // طول مناسب عشان الأيقونات تظهر
        decoration: const BoxDecoration(
          color: Color(0xFF0D1117),
          border: Border(top: BorderSide(color: Color(0xFF1F2937))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.person_outline, Icons.person, 'الملف'),
            _navItem(1, Icons.analytics_outlined, Icons.analytics, 'التقدم'), // شغلك
            _navItem(2, Icons.library_books_outlined, Icons.library_books, 'المكتبة'),
            _navItem(3, Icons.flag_outlined, Icons.flag, 'الهدف'),
            _navItem(4, Icons.fitness_center_outlined, Icons.fitness_center, 'التمارين'),
            _navItem(5, Icons.calendar_today_outlined, Icons.calendar_today, 'الخطة'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData outline, IconData filled, String label) {
    final active = _tab == idx;
    return Expanded( // عشان نوزع المساحة بالتساوي ومفيش حاجة تختفي
      child: InkWell(
        onTap: () => setState(() => _tab = idx),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? filled : outline,
              color: active ? const Color(0xFFa78bfa) : const Color(0xFF4B5563),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: active ? const Color(0xFFa78bfa) : const Color(0xFF4B5563),
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}