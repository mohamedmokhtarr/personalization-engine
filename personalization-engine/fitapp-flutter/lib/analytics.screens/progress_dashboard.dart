import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:provider/provider.dart'; 
import '../providers/gamification_provider.dart';
import 'rewards_screen.dart'; 
import 'mood_tracker_screen.dart';

class ProgressDashboard extends StatefulWidget {
  @override
  State<ProgressDashboard> createState() => _ProgressDashboardState();
}

class _ProgressDashboardState extends State<ProgressDashboard> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    // استخدام الدالة الصحيحة الموجودة في الـ Provider بدون Arguments
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<GamificationProvider>(context, listen: false);
      
      try {
      await provider.fetchProgress("yasmine-01"); 
      print("Dashboard Initialized: Combined data loaded.");
      } catch (e) {
        print("Error fetching data: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // استدعاء الـ Provider
    final gamificationProvider = Provider.of<GamificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Analytics - TrainVerse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RewardsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 45),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Level ${gamificationProvider.currentLevel}",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${gamificationProvider.totalXP % 100} / 100 XP to next level",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (gamificationProvider.totalXP % 100) / 100,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.amber,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),

            // استخدام الـ streak من الـ Provider مباشرة
            _buildStreakCard(5),
            
            _buildMoodButton(context),
            const Divider(thickness: 2),

            if (gamificationProvider.badges.isNotEmpty)
              _buildBadgesPreview(gamificationProvider.badges),

            _buildMonthSelector(context),
            
            _buildBarChartSection(
              "Weight Progress (kg)", 
              gamificationProvider.weightHistory, 
              List.generate(gamificationProvider.weightHistory.length, (index) => "Day ${index + 1}"), 
              Colors.green
            ),

            _buildBarChartSection(
              "Daily XP", 
              gamificationProvider.xpHistory.isEmpty ? [0.0] : gamificationProvider.xpHistory, 
              ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"], 
              Colors.blue
            ),

            _buildBarChartSection(
              "Fat Percentage (%)", 
              [25.0, 24.8, 24.5, 24.0, 23.8, 23.5, 23.0], 
              ["W1", "W2", "W3", "W4", "W5", "W6", "W7"], 
              Colors.red
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(int streakCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 35),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$streakCount consecutive days!", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Continue to commit to achieving your goals.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesPreview(List badges) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Text("Recent Badges: ", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          ...badges.take(3).map((b) => const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.workspace_premium, color: Colors.amber, size: 24),
          )).toList(),
          if (badges.length > 3) const Text("..."),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2024),
            lastDate: DateTime(2030),
          );
          if (picked != null && picked != selectedDate) {
            setState(() {
              selectedDate = picked;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Text(
                "Month: ${selectedDate.month} / ${selectedDate.year}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartSection(String title, List<double> values, List<String> labels, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: values.isEmpty ? 100 : values.reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    // لو النسخة قديمة بيستخدم tooltipBgColor ولو جديدة tooltipBackgroundColor
                    // عشان نضمن إنها تشتغل، هنشيل السطر اللي مطلع أيرور ونستخدم التنسيق الأساسي
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toString(),
                        const TextStyle(
                          color: Colors.blueAccent, // خليت اللون هنا عشان يبان حتى لو الخلفية بيضاء
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= labels.length || value.toInt() < 0) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: values.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: color,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MoodTrackerScreen()),
          );
        },
        icon: const Icon(Icons.add_reaction, color: Colors.white),
        label: const Text("Mood log for today"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}