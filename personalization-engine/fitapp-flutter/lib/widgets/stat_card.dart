import 'package:flutter/material.dart';

// ── StatCard ──────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color  color;
  final String? sub;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color:  const Color(0xFF111827),
        border: Border.all(color: color.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        Container(height: 2, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.transparent, color, Colors.transparent]),
          borderRadius: BorderRadius.circular(1),
        )),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 22, color: color, height: 1)),
        Text(unit,  style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12)),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(sub!, style: TextStyle(fontFamily: 'Cairo', color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ]),
    );
  }
}

// ── SectionHeader ─────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final bool small;

  const SectionHeader({super.key, required this.title, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: small ? 8 : 10, top: small ? 4 : 0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Cairo',
          color:  Colors.grey[600],
          fontSize: small ? 11 : 12,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
