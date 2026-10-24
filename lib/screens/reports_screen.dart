import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/common.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController tabs;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String subject = 'Machine Learning';
  String department = 'Artificial Intelligence & Machine Learning';
  String year = '3rd Year';
  String section = 'A';

  static const subjects = ['Machine Learning', 'Artificial Intelligence', 'Database Management Systems', 'Computer Networks', 'Mathematics'];
  static const departments = ['Artificial Intelligence & Machine Learning', 'Computer Science Engineering', 'Information Technology'];
  static const years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  static const sections = ['A', 'B', 'C'];

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  List<AttendanceRecord> get monthRecords => widget.controller.records.where((r) => r.date.year == selectedYear && r.date.month == selectedMonth).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: const SectionTitle('Attendance Reports', subtitle: 'Generate monthly and subject-wise attendance insights.')),
      TabBar(controller: tabs, tabs: const [Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Monthly'), Tab(icon: Icon(Icons.menu_book_outlined), text: 'Subject Wise')]),
      Expanded(child: TabBarView(controller: tabs, children: [_monthly(), _subjectWise()])),
    ]));
  }

  Widget _monthly() {
    final records = monthRecords;
    final counts = <String, List<AttendanceRecord>>{};
    for (final r in records) { (counts[r.studentId] ??= []).add(r); }
    final values = counts.entries.map((entry) {
      final attended = entry.value.where((r) => r.present).length;
      return (id: entry.key, conducted: entry.value.length, attended: attended);
    }).toList();
    final classAverage = values.isEmpty ? 0.0 : values.map((e) => e.attended / e.conducted * 100).reduce((a, b) => a + b) / values.length;
    final below = values.where((e) => e.attended / e.conducted * 100 < 75).length;

    return ListView(padding: const EdgeInsets.all(16), children: [
      _filters(),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, c) {
        final cards = [
          StatCard(icon: Icons.groups, label: 'Students in data', value: '${values.length}', color: const Color(0xFF2E5BFF)),
          StatCard(icon: Icons.warning_amber_rounded, label: 'Below 75%', value: '$below', color: const Color(0xFFE5484D)),
          StatCard(icon: Icons.analytics_outlined, label: 'Class average', value: '${classAverage.toStringAsFixed(2)}%', color: const Color(0xFF129C67)),
        ];
        if (c.maxWidth < 700) return Column(children: cards.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: e)).toList());
        return Row(children: cards.map((e) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: e))).toList());
      }),
      const SizedBox(height: 16),
      if (values.isEmpty) _empty('No attendance records for the selected month.'),
      ...values.map((e) {
        final s = widget.controller.students.firstWhere((x) => x.id == e.id, orElse: () => Student(id: e.id, name: 'Deleted Student', rollNumber: e.id, parentName: '', parentPhone: '', department: '', year: '', section: ''));
        final p = e.attended / e.conducted * 100;
        return Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE7EBF3))), child: Row(children: [CircleAvatar(backgroundColor: const Color(0xFFEFF3FF), child: Text(s.rollNumber.length >= 2 ? s.rollNumber.substring(s.rollNumber.length - 2) : '--')), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text(s.rollNumber, style: const TextStyle(fontSize: 11, color: Color(0xFF7A8499)))])), Text('${p.toStringAsFixed(1)}%', style: TextStyle(color: riskColor(p), fontWeight: FontWeight.w900))]));
      }),
      const SizedBox(height: 10),
      const Text('Report meaning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      const Text('Monthly percentage is calculated from actual attendance records for the selected month. Overall eligibility can be reviewed from the Dashboard and Subject Wise report.', style: TextStyle(color: Color(0xFF7A8499), height: 1.35)),
    ]);
  }

  Widget _subjectWise() {
    final records = widget.controller.records.where((r) => r.department == department && r.year == year && r.section == section && r.subject == subject).toList();
    final grouped = <String, List<AttendanceRecord>>{};
    for (final r in records) { (grouped[r.studentId] ??= []).add(r); }

    return ListView(padding: const EdgeInsets.all(16), children: [
      DropdownButtonFormField<String>(initialValue: department, decoration: const InputDecoration(labelText: 'Department'), items: departments.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => department = v!)),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: DropdownButtonFormField<String>(initialValue: year, decoration: const InputDecoration(labelText: 'Year'), items: years.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => year = v!))), const SizedBox(width: 10), Expanded(child: DropdownButtonFormField<String>(initialValue: section, decoration: const InputDecoration(labelText: 'Section'), items: sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => section = v!)))]),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(initialValue: subject, decoration: const InputDecoration(labelText: 'Subject'), items: subjects.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => subject = v!)),
      const SizedBox(height: 14),
      if (grouped.isEmpty) _empty('No records yet for $subject in this class.'),
      ...grouped.entries.map((entry) {
        final list = entry.value;
        final attended = list.where((r) => r.present).length;
        final conducted = list.length;
        final p = conducted == 0 ? 0.0 : attended / conducted * 100;
        final student = widget.controller.students.firstWhere((s) => s.id == entry.key, orElse: () => Student(id: entry.key, name: 'Deleted Student', rollNumber: entry.key, parentName: '', parentPhone: '', department: '', year: '', section: ''));
        final needed = AttendanceStats(conducted: conducted, attended: attended).classesNeededForTarget(75);
        return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7EBF3))), child: Row(children: [CircleAvatar(backgroundColor: riskColor(p).withOpacity(.10), child: Icon(Icons.person_outline, color: riskColor(p))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(student.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${student.rollNumber} • $attended/$conducted classes', style: const TextStyle(fontSize: 11, color: Color(0xFF7A8499))), if (needed > 0) Text('Need next $needed classes to reach 75%', style: TextStyle(fontSize: 11, color: riskColor(p), fontWeight: FontWeight.w700))])), Text('${p.toStringAsFixed(1)}%', style: TextStyle(color: riskColor(p), fontWeight: FontWeight.w900))]));
      }),
    ]);
  }

  Widget _filters() => Row(children: [
        Expanded(child: DropdownButtonFormField<int>(initialValue: selectedMonth, decoration: const InputDecoration(labelText: 'Month'), items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_monthName(i + 1)))), onChanged: (v) => setState(() => selectedMonth = v!))),
        const SizedBox(width: 10),
        Expanded(child: DropdownButtonFormField<int>(initialValue: selectedYear, decoration: const InputDecoration(labelText: 'Year'), items: List.generate(5, (i) => DropdownMenuItem(value: DateTime.now().year - i, child: Text('${DateTime.now().year - i}'))), onChanged: (v) => setState(() => selectedYear = v!))),
      ]);

  Widget _empty(String text) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(children: [const Icon(Icons.bar_chart_rounded, size: 50, color: Color(0xFF7A8499)), const SizedBox(height: 10), Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF7A8499)))]));

  String _monthName(int month) => const ['January','February','March','April','May','June','July','August','September','October','November','December'][month - 1];
}
