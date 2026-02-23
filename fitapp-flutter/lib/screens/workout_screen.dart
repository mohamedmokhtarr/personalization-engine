import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/section_header.dart';

class WorkoutScreen extends StatefulWidget {
  final String injury;
  const WorkoutScreen({super.key, required this.injury});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String _intensity  = 'medium';
  String _equipment  = 'gym';
  List<Workout> _workouts = [];
  bool _loading = false;
  String? _error;

  static const _intensityOptions = [
    ('low',    'خفيف',  Color(0xFF60a5fa)),
    ('medium', 'متوسط', Color(0xFF4ade80)),
    ('high',   'شديد',  Color(0xFFf87171)),
  ];

  static const _equipmentOptions = [
    ('gym',  '🏋️ جيم'),
    ('home', '🏠 بيت'),
    ('any',  '📍 أي مكان'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.getWorkouts(
        injury:    widget.injury,
        intensity: _intensity,
        equipment: _equipment == 'any' ? null : _equipment,
      );
      final list = (res['data'] as List).map((w) => Workout.fromJson(w as Map<String, dynamic>)).toList();
      setState(() => _workouts = list);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _intensityColor(String intensity) {
    switch (intensity) {
      case 'high':   return const Color(0xFFf87171);
      case 'medium': return const Color(0xFF4ade80);
      default:       return const Color(0xFF60a5fa);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('اختيار التمارين', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        centerTitle: true, elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFa78bfa)),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filters ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0D1117),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Injury warning
              if (widget.injury != 'none')
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color:  const Color(0xFFf87171).withOpacity(0.08),
                    border: Border.all(color: const Color(0xFFf87171).withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Text('⚠️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(child: Text('وضع الإصابة — التمارين المضرة لـ "${widget.injury}" اتشالت تلقائياً',
                      style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFf87171), fontSize: 12))),
                  ]),
                ),

              // Intensity
              const SectionHeader(title: 'شدة التمرين', small: true),
              Row(children: _intensityOptions.map((opt) {
                final selected = _intensity == opt.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () { setState(() => _intensity = opt.$1); _load(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:  selected ? opt.$3.withOpacity(0.1) : const Color(0xFF111827),
                        border: Border.all(color: selected ? opt.$3 : const Color(0xFF1F2937)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(opt.$2, textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          color: selected ? opt.$3 : Colors.grey)),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 12),

              // Equipment
              const SectionHeader(title: 'المعدات', small: true),
              Row(children: _equipmentOptions.map((opt) {
                final selected = _equipment == opt.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () { setState(() => _equipment = opt.$1); _load(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:  selected ? const Color(0xFFa78bfa).withOpacity(0.1) : const Color(0xFF111827),
                        border: Border.all(color: selected ? const Color(0xFFa78bfa) : const Color(0xFF1F2937)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(opt.$2, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                        color: selected ? const Color(0xFFa78bfa) : Colors.grey)),
                    ),
                  ),
                );
              }).toList()),
            ]),
          ),

          // ── Results ───────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFa78bfa)))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFf87171), fontFamily: 'Cairo')))
                    : _workouts.isEmpty
                        ? const Center(child: Text('مفيش تمارين مناسبة', style: TextStyle(color: Colors.grey, fontFamily: 'Cairo')))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _workouts.length,
                            itemBuilder: (ctx, i) {
                              final w = _workouts[i];
                              final iColor = _intensityColor(w.intensity);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111827),
                                  border: Border.all(color: const Color(0xFF1F2937)),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 46, height: 46,
                                    decoration: BoxDecoration(
                                      color: iColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(child: Text(w.icon, style: const TextStyle(fontSize: 22))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(w.nameAr, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Text(w.muscleAr, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
                                      const Text(' · ', style: TextStyle(color: Colors.grey)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: iColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text(w.intensity.toUpperCase(), style: TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.bold, color: iColor)),
                                      ),
                                    ]),
                                  ])),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text(w.sets, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFa78bfa))),
                                    Text('استراحة ${w.rest}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey)),
                                  ]),
                                ]),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
