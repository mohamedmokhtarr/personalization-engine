import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final void Function(UserProfile) onProfileSaved;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.onProfileSaved,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Form state
  double _weight      = 75;
  double _height      = 175;
  int    _age         = 25;
  String _gender      = 'male';
  String _activity    = 'moderate';
  String _injury      = 'none';

  bool   _loading     = false;
  String? _error;
  UserProfile? _savedProfile;

  final _activityOptions = const [
    ('sedentary', '🛋️ خامل'),
    ('light',     '🚶 خفيف'),
    ('moderate',  '🏃 متوسط'),
    ('active',    '🏋️ عالي'),
    ('extreme',   '🔥 محترف'),
  ];

  final _injuryOptions = const [
    ('none',     '✅ مفيش'),
    ('knee',     '🦵 ركبة'),
    ('shoulder', '💪 كتف'),
    ('back',     '🏃 ظهر'),
    ('wrist',    '✋ رسغ'),
    ('ankle',    '🦶 كاحل'),
  ];

  Future<void> _save() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.upsertProfile(
        userId:        widget.userId,
        weight:        _weight,
        height:        _height,
        age:           _age,
        gender:        _gender,
        activityLevel: _activity,
        injury:        _injury,
      );
      final profile = UserProfile.fromJson(res);
      setState(() { _savedProfile = profile; });
      widget.onProfileSaved(profile);
    } on ApiException catch (e) {
      setState(() { _error = e.message; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('الملف الصحي', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF1A1A2E), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Computed stats (show after save) ──────────
            if (_savedProfile != null) ...[
              Row(children: [
                Expanded(child: StatCard(label: 'BMI',  value: _savedProfile!.bmi.toString(),           unit: 'kg/m²', color: _bmiColor(_savedProfile!.bmiCategory), sub: _savedProfile!.bmiCategory)),
                const SizedBox(width: 8),
                Expanded(child: StatCard(label: 'BMR',  value: _savedProfile!.bmr.toString(),           unit: 'kcal', color: const Color(0xFFa78bfa), sub: 'أساسي')),
                const SizedBox(width: 8),
                Expanded(child: StatCard(label: 'TDEE', value: _savedProfile!.tdee.toString(),          unit: 'kcal', color: const Color(0xFF60a5fa), sub: 'مع النشاط')),
              ]),
              const SizedBox(height: 20),
            ],

            // ── Gender ────────────────────────────────────
            const SectionHeader(title: 'الجنس'),
            Row(children: [
              for (final (val, label) in [('male', '♂ ذكر'), ('female', '♀ أنثى')]) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color:  _gender == val ? const Color(0xFFa78bfa).withOpacity(0.1) : const Color(0xFF111827),
                        border: Border.all(color: _gender == val ? const Color(0xFFa78bfa) : const Color(0xFF1F2937)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(label, textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold,
                          color: _gender == val ? const Color(0xFFa78bfa) : Colors.grey)),
                    ),
                  ),
                ),
                if (val == 'male') const SizedBox(width: 10),
              ],
            ]),
            const SizedBox(height: 16),

            // ── Sliders ───────────────────────────────────
            _buildSlider('الوزن', _weight, 40, 200, 'kg', (v) => setState(() => _weight = v)),
            _buildSlider('الطول', _height, 140, 220, 'cm', (v) => setState(() => _height = v)),
            _buildSlider('العمر', _age.toDouble(), 10, 80, 'سنة', (v) => setState(() => _age = v.round())),

            // ── Activity ──────────────────────────────────
            const SectionHeader(title: 'مستوى النشاط'),
            ..._activityOptions.map((opt) => _buildOptionTile(
              opt.$1, opt.$2, _activity == opt.$1,
              () => setState(() => _activity = opt.$1),
              const Color(0xFFa78bfa),
            )),
            const SizedBox(height: 8),

            // ── Injury ────────────────────────────────────
            const SectionHeader(title: 'هل عندك إصابة؟'),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _injuryOptions.map((opt) {
                final selected = _injury == opt.$1;
                final color = opt.$1 == 'none' ? const Color(0xFF4ade80) : const Color(0xFFf87171);
                return GestureDetector(
                  onTap: () => setState(() => _injury = opt.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color:  selected ? color.withOpacity(0.1) : const Color(0xFF111827),
                      border: Border.all(color: selected ? color : const Color(0xFF1F2937)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(opt.$2, style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? color : Colors.grey)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Error ─────────────────────────────────────
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFf87171).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFFf87171).withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!, style: const TextStyle(color: Color(0xFFf87171), fontFamily: 'Cairo')),
              ),

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
                    : const Text('حفظ الملف الشخصي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, String unit, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 13)),
          Text('${value.round()} $unit', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor:   const Color(0xFFa78bfa),
            inactiveTrackColor: const Color(0xFF1F2937),
            thumbColor:         const Color(0xFFa78bfa),
            overlayColor:       const Color(0xFFa78bfa).withOpacity(0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildOptionTile(String val, String label, bool selected, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:  selected ? color.withOpacity(0.08) : const Color(0xFF111827),
          border: Border.all(color: selected ? color.withOpacity(0.4) : const Color(0xFF1F2937)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? color : Colors.grey))),
          if (selected) Icon(Icons.check_circle_rounded, color: color, size: 18),
        ]),
      ),
    );
  }

  Color _bmiColor(String cat) {
    switch (cat) {
      case 'Underweight': return const Color(0xFF60a5fa);
      case 'Normal':      return const Color(0xFF4ade80);
      case 'Overweight':  return const Color(0xFFfacc15);
      default:            return const Color(0xFFf87171);
    }
  }
}
