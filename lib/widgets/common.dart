import 'package:flutter/material.dart';

Color riskColor(double p) {
  if (p >= 75) return const Color(0xFF129C67);
  if (p >= 65) return const Color(0xFFF59E0B);
  return const Color(0xFFE5484D);
}

String riskLabel(double p) {
  if (p >= 75) return 'SAFE';
  if (p >= 65) return 'WATCH';
  return 'CRITICAL';
}

class RiskBadge extends StatelessWidget {
  const RiskBadge(this.percentage, {super.key});
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final color = riskColor(percentage);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        riskLabel(percentage),
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(color: Color(0xFF7A8499))),
        ],
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBF3)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: Color(0xFF7A8499), fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ]),
          ),
        ],
      ),
    );
  }
}
