import 'package:flutter/material.dart';
import 'models/models.dart';
import 'screens/profile_screen.dart';
import 'screens/goal_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/plan_screen.dart';

void main() => runApp(const FitApp());

class FitApp extends StatelessWidget {
  const FitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(primary: Color(0xFFa78bfa)),
        scaffoldBackgroundColor: const Color(0xFF070A0E),
        fontFamily: 'Cairo',
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

  // Shared state passed between screens
  UserProfile? _profile;
  FitnessGoal? _goal;

  // For demo: fixed userId (in real app comes from auth)
  static const _userId = 'user_001';

  @override
  Widget build(BuildContext context) {
    final screens = [
      ProfileScreen(
        userId: _userId,
        onProfileSaved: (p) => setState(() => _profile = p),
      ),
      GoalScreen(
        userId: _userId,
        onGoalSaved: (g) => setState(() => _goal = g),
      ),
      WorkoutScreen(injury: _profile?.injury ?? 'none'),
      PlanScreen(userId: _userId),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D1117),
          border: Border(top: BorderSide(color: Color(0xFF1F2937))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.person_outline_rounded,     Icons.person_rounded,     'الملف'),
                _navItem(1, Icons.flag_outlined,              Icons.flag_rounded,       'الهدف'),
                _navItem(2, Icons.fitness_center_outlined,   Icons.fitness_center,    'التمارين'),
                _navItem(3, Icons.calendar_today_outlined,   Icons.calendar_today,    'خطة اليوم'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData outline, IconData filled, String label) {
    final active = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFa78bfa).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(active ? filled : outline, color: active ? const Color(0xFFa78bfa) : const Color(0xFF4B5563), size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? const Color(0xFFa78bfa) : const Color(0xFF4B5563))),
          if (active)
            Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(color: Color(0xFFa78bfa), shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}
