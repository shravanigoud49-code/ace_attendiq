import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller, required this.onRefresh});
  final AppController controller;
  final VoidCallback onRefresh;

  static const requiredAttendance = 75.0;

  @override
  Widget build(BuildContext context) {
    final currentStudents = controller.students.where((s) => s.department == 'Artificial Intelligence & Machine Learning').toList();
    final critical = currentStudents.where((s) {
      final stats = controller.statsForStudent(s.id);
      return stats.conducted > 0 && stats.percentage < 65;
    }).length;
    final watch = currentStudents.where((s) {
      final stats = controller.statsForStudent(s.id);
      return stats.conducted > 0 && stats.percentage >= 65 && stats.percentage < requiredAttendance;
    }).length;
    final safe = currentStudents.where((s) {
      final stats = controller.statsForStudent(s.id);
      return stats.conducted == 0 || stats.percentage >= requiredAttendance;
    }).length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ACE AttendIQ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    Text('Faculty Dashboard', style: TextStyle(fontSize: 12, color: Color(0xFF7A8499))),
                  ]),
                ),
                CircleAvatar(backgroundColor: const Color(0xFFEFF3FF), child: const Icon(Icons.school_rounded, color: Color(0xFF2E5BFF))),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2E5BFF), Color(0xFF5274FF)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Good day 👋', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                    Text('Attendance intelligence at a glance', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    SizedBox(height: 7),
                    Text('Record attendance, find risk and plan recovery.', style: TextStyle(color: Colors.white70, height: 1.35)),
                  ])),
                  Icon(Icons.auto_graph_rounded, color: Colors.white70, size: 62),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, c) {
              final wide = c.maxWidth > 680;
              final cards = [
                StatCard(icon: Icons.groups_rounded, label: 'Students', value: '${currentStudents.length}', color: const Color(0xFF2E5BFF)),
                StatCard(icon: Icons.verified_rounded, label: 'Safe', value: '$safe', color: const Color(0xFF129C67)),
                StatCard(icon: Icons.visibility_rounded, label: 'Watch', value: '$watch', color: const Color(0xFFF59E0B)),
                StatCard(icon: Icons.warning_rounded, label: 'Critical', value: '$critical', color: const Color(0xFFE5484D)),
              ];
              if (!wide) {
                return Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: c)).toList());
              }
              return Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: c))).toList());
            }),
            const SizedBox(height: 20),
            const Text('Attendance Risk', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...currentStudents.map((student) {
              final stats = controller.statsForStudent(student.id);
              if (stats.conducted == 0) return _noData(student);
              final needed = stats.classesNeededForTarget(requiredAttendance);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7EBF3))),
                child: Row(children: [
                  CircleAvatar(backgroundColor: riskColor(stats.percentage).withOpacity(.10), child: Icon(Icons.person_outline, color: riskColor(stats.percentage))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(student.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${student.rollNumber} • ${stats.attended}/${stats.conducted} • ${stats.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: Color(0xFF7A8499))),
                    if (needed > 0) Text('Attend next $needed classes continuously to reach 75%', style: TextStyle(fontSize: 11, color: riskColor(stats.percentage), fontWeight: FontWeight.w700)),
                  ])),
                  RiskBadge(stats.percentage),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _noData(Student student) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [const Icon(Icons.info_outline, color: Color(0xFF7A8499)), const SizedBox(width: 10), Text('${student.name}: no attendance records yet', style: const TextStyle(color: Color(0xFF7A8499)))]),
      );
}
