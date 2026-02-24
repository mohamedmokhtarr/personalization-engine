import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/section_header.dart';

class GoalScreen extends StatefulWidget {
  final String userId;
  final void Function(FitnessGoal) onGoalSaved;

  const GoalScreen({super.key, required this.userId, required this.onGoalSaved});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String _goalType = 'gain';
  int    _manualAdj = 0;
  bool   _loading = false;
  String? _error;
  FitnessGoal? _goal;

  static const _goalOptions = [
    ('lose',    '📉', 'خسارة وزن',     '-500 kcal', Color(0xFFf87171)),
    ('gain',    '📈', 'بناء عضل',      '+400 kcal', Color(0xFF4ade80)),
    ('recomp',  '🔄', 'ريكومب',        '±0 kcal',   Color(0xFFa78bfa)),
    ('maintain','⚖️', 'حفاظ على الوزن','±0 kcal',   Color(0xFF60a5fa)),
  ];

  Future<void> _save() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.setGoal(
        userId:                 widget.userId,
        goalType:               _goalType,
        manualCaloricAdjustment: _manualAdj,
      );
      final goal = FitnessGoal.fromJson(res);
      setState(() => _goal = goal);
      widget.onGoalSaved(goal);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _adjust(int delta) async {
    if (_goal == null) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.adjustGoal(goalId: _goal!.id, delta: delta);
      final updated = FitnessGoal.fromJson({'data': res['data']['goal']});
      setState(() { _goal = updated; _manualAdj += delta; });
      widget.onGoalSaved(updated);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedGoal = _goalOptions.firstWhere((g) => g.$1 == _goalType);

    return Scaffold(
      backgroundColor: const Color(0xFF070A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('الهدف الذكي', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        centerTitle: true, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Goal picker ───────────────────────────────
            const SectionHeader(title: 'اختار هدفك'),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6,
              children: _goalOptions.map((opt) {
                final selected = _goalType == opt.$1;
                return GestureDetector(
                  onTap: () => setState(() { _goalType = opt.$1; _goal = null; _manualAdj = 0; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? opt.$5.withOpacity(0.08) : const Color(0xFF111827),
                      border: Border.all(color: selected ? opt.$5.withOpacity(0.5) : const Color(0xFF1F2937)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(opt.$2, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 6),
                      Text(opt.$3, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14,
                        color: selected ? opt.$5 : Colors.grey)),
                      Text(opt.$4, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: selected ? opt.$5.withOpacity(0.7) : const Color(0xFF374151))),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Error ─────────────────────────────────────
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFf87171).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFf87171).withOpacity(0.3)),
                ),
                child: Text(_error!, style: const TextStyle(color: Color(0xFFf87171), fontFamily: 'Cairo')),
              ),

            // ── Result card ───────────────────────────────
            if (_goal != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: selectedGoal.$5.withOpacity(0.06),
                  border: Border.all(color: selectedGoal.$5.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('الهدف اليومي', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[600], fontSize: 12)),
                      if (_manualAdj != 0)
                        Text('تعديل: ${_manualAdj > 0 ? "+" : ""}$_manualAdj kcal',
                          style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFa78bfa), fontSize: 11, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${_goal!.adjustedCaloricTarget}',
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 48, color: selectedGoal.$5, height: 1)),
                      const SizedBox(width: 6),
                      const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('kcal/يوم', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 13))),
                    ]),
                    const SizedBox(height: 16),

                    // Macro row
                    Row(children: [
                      _macroPill('بروتين', '${_goal!.proteinTarget}g', '${_goal!.proteinPct}%', const Color(0xFF60a5fa)),
                      const SizedBox(width: 8),
                      _macroPill('كارب',   '${_goal!.carbsTarget}g',   '${_goal!.carbsPct}%',   const Color(0xFFfacc15)),
                      const SizedBox(width: 8),
                      _macroPill('دهون',  '${_goal!.fatTarget}g',     '${_goal!.fatPct}%',     const Color(0xFFf87171)),
                    ]),
                    const SizedBox(height: 16),

                    // Smart adjust
                    const Text('تعديل ذكي', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _adjustBtn('↓ قلل 150', const Color(0xFFf87171), () => _adjust(-150))),
                      const SizedBox(width: 8),
                      Expanded(child: _adjustBtn('Reset', Colors.grey, () { setState(() { _manualAdj = 0; }); _save(); })),
                      const SizedBox(width: 8),
                      Expanded(child: _adjustBtn('↑ زود 150', const Color(0xFF4ade80), () => _adjust(150))),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Save button ───────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFa78bfa),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                    : Text(_goal != null ? 'تحديث الهدف' : 'احسب هدفي', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroPill(String label, String val, String pct, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.15))),
        child: Column(children: [
          Text(val, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 17, color: color)),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
          Text(pct,   style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: color.withOpacity(0.7))),
        ]),
      ),
    );
  }

  Widget _adjustBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12, color: color)),
      ),
    );
  }
}
