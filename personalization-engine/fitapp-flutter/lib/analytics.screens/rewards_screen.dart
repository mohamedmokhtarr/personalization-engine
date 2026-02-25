import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استدعاء البروفايدر لقراءة البيانات الحقيقية
    final provider = Provider.of<GamificationProvider>(context);
    final myBadges = provider.badges; // الأوسمة اللي اليوزر كسبها

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rewards & Achievements"),
        backgroundColor: Colors.purple.shade700,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. الجزء العلوي: أحدث وسام حصل عليه
            if (myBadges.isNotEmpty)
              _buildLatestRewardHeader(myBadges.last)
            else
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Start training to earn your first medal!", 
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            const Divider(),

            // 2. قائمة الأوسمة التي حصلت عليها (المجموعة الخاصة)
            _buildSectionTitle("My Collection"),
            _buildEarnedBadgesList(myBadges),

            const Divider(),

            // 3. قائمة التحديات (القائمة الثابتة - المفتوح والمقفول)
            _buildSectionTitle("Upcoming Challenges (Locked)"),
            _buildLockedBadgesList(myBadges, provider.allPossibleBadges),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 1. ويدجت الهيدر المميز
  Widget _buildLatestRewardHeader(dynamic lastBadge) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.deepPurple]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Icon(Icons.stars, size: 80, color: Colors.amber),
          const SizedBox(height: 10),
          Text(
            lastBadge['badgeName'] ?? "New Medal",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text("LATEST ACHIEVEMENT", style: TextStyle(color: Colors.white70, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  // 2. قائمة الأوسمة المحققة
  Widget _buildEarnedBadgesList(List<dynamic> myBadges) {
    if (myBadges.isEmpty) {
      return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Text("No medals earned yet.", style: TextStyle(color: Colors.grey)),
    );
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: myBadges.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.emoji_events, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(myBadges[index]['badgeName'], 
                     textAlign: TextAlign.center,
                     maxLines: 2,
                     style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  // 3. قائمة التحديات المفتوحة والمقفولة (الربط الحقيقي)
  Widget _buildLockedBadgesList(List<dynamic> myBadges, List<Map<String, String>> allPossible) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allPossible.length,
      itemBuilder: (context, index) {
        final badge = allPossible[index];
        // تشبيك: هل الاسم موجود في المصفوفة اللي جاية من السيرفر؟
        bool isEarned = myBadges.any((b) => b['badgeName'] == badge['name']);
        
        return ListTile(
          leading: Icon(
            isEarned ? Icons.check_circle : Icons.lock,
            color: isEarned ? Colors.green : Colors.grey,
            size: 30,
          ),
          title: Text(badge['name']!, 
            style: TextStyle(
              fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
              color: isEarned ? Colors.black : Colors.grey,
            )
          ),
          subtitle: Text("Target: ${badge['goal']}"),
          trailing: isEarned ? null : const Icon(Icons.chevron_right, size: 18),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}