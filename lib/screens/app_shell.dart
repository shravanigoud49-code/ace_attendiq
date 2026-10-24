import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/common.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'reports_screen.dart';
import 'student_management_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller, required this.facultyEmail});

  final AppController controller;
  final String facultyEmail;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(controller: widget.controller, onRefresh: refresh),
      ClassSelectionPage(controller: widget.controller),
      StudentManagementScreen(controller: widget.controller, onChanged: refresh),
      ReportsScreen(controller: widget.controller),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.how_to_reg_outlined), selectedIcon: Icon(Icons.how_to_reg), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Reports'),
        ],
      ),
    );
  }
}

class ClassSelectionPage extends StatefulWidget {
  const ClassSelectionPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<ClassSelectionPage> createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  String department = 'Artificial Intelligence & Machine Learning';
  String year = '3rd Year';
  String section = 'A';
  String subject = 'Machine Learning';
  String hour = '3rd Hour';
  DateTime date = DateTime.now();

  static const departments = [
    'Artificial Intelligence & Machine Learning',
    'Computer Science Engineering',
    'Information Technology',
  ];
  static const years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  static const sections = ['A', 'B', 'C'];
  static const subjects = [
    'Machine Learning',
    'Artificial Intelligence',
    'Database Management Systems',
    'Computer Networks',
    'Mathematics',
  ];
  static const hours = ['1st Hour', '2nd Hour', '3rd Hour', '4th Hour', '5th Hour', '6th Hour'];

  int get classCount => widget.controller.studentsForClass(
        ClassSelection(department: department, year: year, section: section, subject: subject, hour: hour),
      ).length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Take Attendance', subtitle: 'Choose the exact class before opening the roster.'),
                const SizedBox(height: 18),
                _dropdown('Department', Icons.account_tree_outlined, department, departments, (v) => setState(() => department = v!)),
                const SizedBox(height: 12),
                _responsivePair(
                  _dropdown('Year', Icons.school_outlined, year, years, (v) => setState(() => year = v!)),
                  _dropdown('Section', Icons.groups_outlined, section, sections, (v) => setState(() => section = v!)),
                ),
                const SizedBox(height: 12),
                _responsivePair(
                  _dropdown('Subject', Icons.menu_book_outlined, subject, subjects, (v) => setState(() => subject = v!)),
                  _dropdown('Hour', Icons.schedule_outlined, hour, hours, (v) => setState(() => hour = v!)),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Attendance Date', prefixIcon: Icon(Icons.calendar_month_outlined)),
                    child: Text('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_rounded, color: Color(0xFF2E5BFF), size: 28),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Roster found: $classCount students\nAttendance will be stored by date + subject + hour.', style: const TextStyle(color: Color(0xFF29479C), height: 1.35))),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: classCount == 0 ? null : _openRoster,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('OPEN STUDENT LIST', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                if (classCount == 0) ...[
                  const SizedBox(height: 10),
                  const Text('No students found for this class. Add them from Students before taking attendance.', style: TextStyle(color: Color(0xFFE5484D), fontSize: 12)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _responsivePair(Widget a, Widget b) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 620) {
        return Column(children: [a, const SizedBox(height: 12), b]);
      }
      return Row(children: [Expanded(child: a), const SizedBox(width: 12), Expanded(child: b)]);
    });
  }

  Widget _dropdown(String label, IconData icon, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _pickDate() async {
    final chosen = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDate: date,
    );
    if (chosen != null) setState(() => date = chosen);
  }

  void _openRoster() {
    final selection = ClassSelection(department: department, year: year, section: section, subject: subject, hour: hour);
    Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen(controller: widget.controller, selection: selection, date: date)));
  }
}
