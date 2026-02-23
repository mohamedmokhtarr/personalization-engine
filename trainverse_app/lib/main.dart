import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/gamification_provider.dart';
import 'screens/progress_dashboard.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GamificationProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainVerse Analytics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      // شاشة البداية هي الـ Dashboard اللي أنتي مسؤولة عنها
      home: ProgressDashboard(),
    );
  }
}

