import 'package:flutter/material.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('How do you feel after the workout?')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("What is your current mood?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodIcon(context, "🤩", "Excellent", 5),
                _buildMoodIcon(context, "🙂", "Good", 4),
                _buildMoodIcon(context, "😐", "Average", 3),
                _buildMoodIcon(context, "😴", "Tired", 2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodIcon(BuildContext context, String emoji, String label, int score) {
    return InkWell(
      onTap: () {
        // call log-mode from back-end
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Your mode has been recorded: $label. Keep moving forward!")),
        );
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 50)),
          Text(label, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}