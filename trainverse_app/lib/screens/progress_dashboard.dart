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
  Widget build(BuildContext context) {
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
            // --- تعديل جزء الـ Level والـ Progress Bar الجديد ---
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
                            // حسبة الـ XP المتبقي للفل القادم
                            Text(
                              "${gamificationProvider.totalXP % 500} / 500 XP to next level",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // شريط التقدم (Progress Bar)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (gamificationProvider.totalXP % 500) / 500,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.amber,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            // ------------------------------------------------

            _buildStreakCard(),
            _buildMoodButton(context),
            const Divider(thickness: 2),

            if (gamificationProvider.badges.isNotEmpty)
              _buildBadgesPreview(gamificationProvider.badges),

            _buildMonthSelector(context),
            
            _buildBarChartSection(
              "Weight Progress (kg)", 
              gamificationProvider.weightHistory, 
              ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"], 
              Colors.green
            ),

            _buildBarChartSection(
              "Daily XP", 
              gamificationProvider.xpHistory, 
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
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.transparent, 
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(1),
                        TextStyle(color: color, fontWeight: FontWeight.bold),
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
                    showingTooltipIndicators: [0],
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

  Widget _buildStreakCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 35),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("7 consecutive days!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Continue to commit to achieving your goals.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
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