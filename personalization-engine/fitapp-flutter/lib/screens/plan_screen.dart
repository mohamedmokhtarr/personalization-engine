import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class PlanScreen extends StatefulWidget {
  final String userId;
  const PlanScreen({super.key, required this.userId});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  DailyPlan? _plan;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.generatePlan(userId: widget.userId);
      setState(() => _plan = DailyPlan.fromJson(res));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('خطة اليوم', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        centerTitle: true, elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFa78bfa)),
            onPressed: _generate,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFa78bfa)))
          : _error != null
              ? _buildError()
              : _plan != null
                  ? _buildPlan()
                  : const SizedBox(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFf87171)), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _generate,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFa78bfa), foregroundColor: Colors.black),
            child: const Text('حاول تاني', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  Widget _buildPlan() {
    final p = _plan!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Summary banner ──────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A0D2E), Color(0xFF0D1A2E)],
              begin: Alignment.topRight, end: Alignment.bottomLeft,
            ),
            border: Border.all(color: const Color(0xFFa78bfa).withOpacity(0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.date, style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Row(children: [
              _summaryItem('🔥 هدف',  '${p.targetCalories}',  'kcal', const Color(0xFFa78bfa)),
              _summaryItem('🍽️ أكل',  '${p.totalMealCalories}','kcal', const Color(0xFF4ade80)),
              _summaryItem('⚡ حرق',  '${p.estimatedCalBurn}', 'kcal', const Color(0xFFf87171)),
              _summaryItem('📊 صافي', '${p.netCalories}',      'kcal', const Color(0xFF60a5fa)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _macroBadge('P', '${p.targetProtein}g', const Color(0xFF60a5fa)),
              const SizedBox(width: 6),
              _macroBadge('C', '${p.targetCarbs}g',   const Color(0xFFfacc15)),
              const SizedBox(width: 6),
              _macroBadge('F', '${p.targetFat}g',     const Color(0xFFf87171)),
            ]),
          ]),
        ),
        const SizedBox(height: 24),

        // ── Timeline ─────────────────────────────────────
        const Text('جدول اليوم', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 14),

        // Workout slot (first)
        _timelineItem(
          time: p.workoutTime,
          icon: '💪',
          title: 'وقت التمرين',
          color: const Color(0xFFf87171),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${p.workouts.length} تمرين — ${p.estimatedCalBurn} kcal تقريباً',
              style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: p.workouts.map((w) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFf87171).withOpacity(0.08),
                border: Border.all(color: const Color(0xFFf87171).withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${w.icon} ${w.nameAr}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Color(0xFFf87171))),
            )).toList()),
          ]),
        ),

        // Meal slots
        ...p.meals.map((meal) => _timelineItem(
          time: meal.time,
          icon: meal.icon,
          title: meal.mealNameAr,
          color: const Color(0xFFa78bfa),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('${meal.calories} kcal', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4ade80))),
              const SizedBox(width: 10),
              Text('P:${meal.protein}g · C:${meal.carbs}g · F:${meal.fat}g',
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 11)),
            ]),
            const SizedBox(height: 8),
            ...meal.foods.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(children: [
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFa78bfa), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 13)),
              ]),
            )),
          ]),
        )),

        const SizedBox(height: 20),

        // ── Regenerate ────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.refresh, color: Color(0xFFa78bfa), size: 18),
            label: const Text('ولّد خطة جديدة', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFa78bfa), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFa78bfa), width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _timelineItem({ required String time, required String icon, required String title, required Color color, required Widget child }) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Timeline line + dot
      SizedBox(width: 60, child: Column(children: [
        Text(time, style: TextStyle(fontFamily: 'Cairo', color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)])),
      ])),
      // Content
      Expanded(child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          border: Border.all(color: const Color(0xFF1F2937)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$icon $title', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
          const SizedBox(height: 10),
          child,
        ]),
      )),
    ]);
  }

  Widget _summaryItem(String label, String val, String unit, Color color) => Expanded(
    child: Column(children: [
      Text(val, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 20, color: color)),
      Text(unit, style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 10)),
      Text(label, style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 10)),
    ]),
  );

  Widget _macroBadge(String letter, String val, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))),
    child: Text('$letter: $val', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: color)),
  );
}
