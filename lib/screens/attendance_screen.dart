import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/common.dart';
import 'parent_message_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    required this.controller,
    required this.selection,
    required this.date,
  });

  final AppController controller;
  final ClassSelection selection;
  final DateTime date;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late List<Student> classStudents;
  final search = TextEditingController();
  final selectedPresent = <String>{};
  bool saving = false;
  String query = '';

  @override
  void initState() {
    super.initState();
    classStudents = widget.controller.studentsForClass(widget.selection);
    final existing = widget.controller.recordsForSession(widget.selection, widget.date);
    if (existing.isNotEmpty) {
      selectedPresent.addAll(
        existing.where((r) => r.present).map((r) => r.studentId),
      );
    } else {
      selectedPresent.addAll(classStudents.map((s) => s.id));
    }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  List<Student> get filtered => classStudents.where((s) {
        final q = query.toLowerCase().trim();
        return q.isEmpty ||
            s.name.toLowerCase().contains(q) ||
            s.rollNumber.toLowerCase().contains(q);
      }).toList();

  int get presentCount => selectedPresent.length;
  int get absentCount => classStudents.length - presentCount;

  void markAll(bool present) {
    setState(() {
      if (present) {
        selectedPresent
          ..clear()
          ..addAll(classStudents.map((s) => s.id));
      } else {
        selectedPresent.clear();
      }
    });
  }

  Future<void> submit() async {
    if (classStudents.isEmpty) {
      _snack('No students in this class. Add students first.');
      return;
    }

    setState(() => saving = true);
    await widget.controller.saveAttendanceSession(
      selection: widget.selection,
      presentStudentIds: selectedPresent.toList(),
      date: widget.date,
    );

    if (!mounted) return;
    setState(() => saving = false);

    final absentIds = classStudents
        .map((s) => s.id)
        .where((id) => !selectedPresent.contains(id))
        .toSet();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AbsentStudentsScreen(
          controller: widget.controller,
          selection: widget.selection,
          date: widget.date,
          absentStudentIds: absentIds,
        ),
      ),
    );
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Attendance',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE7EBF3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selection.subject,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.selection.department} • ${widget.selection.year} • '
                    'Section ${widget.selection.section} • ${widget.selection.hour}',
                    style: const TextStyle(
                      color: Color(0xFF7A8499),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Date: ${widget.date.day.toString().padLeft(2, '0')}/'
                    '${widget.date.month.toString().padLeft(2, '0')}/'
                    '${widget.date.year}',
                    style: const TextStyle(
                      color: Color(0xFF7A8499),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _counter(
                          'Present',
                          presentCount,
                          const Color(0xFF129C67),
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _counter(
                          'Absent',
                          absentCount,
                          const Color(0xFFE5484D),
                          Icons.cancel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: search,
                onChanged: (v) => setState(() => query = v),
                decoration: const InputDecoration(
                  hintText: 'Search name or hall ticket number',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => markAll(true),
                    icon: const Icon(Icons.done_all),
                    label: const Text('All Present'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => markAll(false),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('All Absent'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 9),
                itemBuilder: (_, i) {
                  final student = filtered[i];
                  final isPresent = selectedPresent.contains(student.id);
                  final stats = widget.controller.statsForStudent(
                    student.id,
                    subject: widget.selection.subject,
                  );
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE7EBF3)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFEFF3FF),
                          child: Text(
                            '${classStudents.indexOf(student) + 1}',
                            style: const TextStyle(
                              color: Color(0xFF2E5BFF),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hall Ticket: ${student.rollNumber}',
                                style: const TextStyle(
                                  color: Color(0xFF7A8499),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Before today: ${stats.attended}/${stats.conducted} • '
                                '${stats.percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF667089),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Switch.adaptive(
                              value: isPresent,
                              onChanged: (v) => setState(() {
                                if (v) {
                                  selectedPresent.add(student.id);
                                } else {
                                  selectedPresent.remove(student.id);
                                }
                              }),
                            ),
                            Text(
                              isPresent ? 'Present' : 'Absent',
                              style: TextStyle(
                                color: isPresent
                                    ? const Color(0xFF129C67)
                                    : const Color(0xFFE5484D),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: saving ? null : submit,
                icon: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  saving ? 'SAVING...' : 'SUBMIT ATTENDANCE',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counter(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AbsentStudentsScreen extends StatefulWidget {
  const AbsentStudentsScreen({
    super.key,
    required this.controller,
    required this.selection,
    required this.date,
    required this.absentStudentIds,
  });

  final AppController controller;
  final ClassSelection selection;
  final DateTime date;
  final Set<String> absentStudentIds;

  @override
  State<AbsentStudentsScreen> createState() => _AbsentStudentsScreenState();
}

class _AbsentStudentsScreenState extends State<AbsentStudentsScreen> {
  final Set<String> sentIds = <String>{};
  bool sendingAll = false;

  List<Student> get students => widget.controller
      .studentsForClass(widget.selection)
      .where((s) => widget.absentStudentIds.contains(s.id))
      .toList();

  Future<void> _sendAll() async {
    if (students.isEmpty || sendingAll) return;

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send all parent alerts?'),
        content: Text(
          '${students.length} absent student(s) will receive individualized parent alerts.\n\n'
          'Each message includes the student name, hall ticket number, subject, absent hour and current attendance percentage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SEND ALL'),
          ),
        ],
      ),
    );

    if (shouldSend != true || !mounted) return;

    setState(() => sendingAll = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      sentIds.addAll(students.map((s) => s.id));
      sendingAll = false;
    });

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parent Alerts Sent'),
        content: Text(
          '✅ ${students.length}/${students.length} parent alerts prepared successfully.\n\n'
          'Each message is personalized for the absent student.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSingle(Student student) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParentMessageScreen(
          controller: widget.controller,
          student: student,
          selection: widget.selection,
          date: widget.date,
          onSent: () {
            if (mounted) {
              setState(() => sentIds.add(student.id));
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Absent Students',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: students.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 72,
                      color: Color(0xFF129C67),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Perfect Attendance',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'No students were marked absent.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF172033), Color(0xFF2B3850)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Absence Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${students.length} absent • ${widget.selection.subject} • ${widget.selection.hour}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.campaign_rounded,
                        color: Color(0xFF2E5BFF),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${students.length} parent alert(s) ready',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF172033),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              sentIds.length == students.length
                                  ? 'All alerts sent for this attendance session.'
                                  : 'Send all at once or choose an individual student below.',
                              style: const TextStyle(
                                color: Color(0xFF29479C),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: (sendingAll || sentIds.length == students.length)
                        ? null
                        : _sendAll,
                    icon: sendingAll
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      sentIds.length == students.length
                          ? 'ALL PARENT ALERTS SENT'
                          : sendingAll
                              ? 'SENDING ALL ALERTS...'
                              : 'SEND ALL PARENT ALERTS',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ...students.map((student) => _card(context, student)),
              ],
            ),
    );
  }

  Widget _card(BuildContext context, Student student) {
    final stats = widget.controller.statsForStudent(
      student.id,
      subject: widget.selection.subject,
      department: widget.selection.department,
      year: widget.selection.year,
      section: widget.selection.section,
    );
    final after = AttendanceStats(
      conducted: stats.conducted + 1,
      attended: stats.attended,
    );
    final needed = after.classesNeededForTarget(75);
    final p = after.percentage;
    final isSent = sentIds.contains(student.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EBF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFEEEE),
                child: Icon(Icons.person, color: Color(0xFFE5484D)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Hall Ticket: ${student.rollNumber}',
                      style: const TextStyle(
                        color: Color(0xFF7A8499),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              RiskBadge(p),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _detail('Absent Hour', widget.selection.hour)),
              Expanded(child: _detail('Current', '${p.toStringAsFixed(2)}%')),
              Expanded(child: _detail('Target', '75%')),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: riskColor(p).withOpacity(.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: riskColor(p)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p >= 75
                        ? 'Attendance is still above the minimum requirement.'
                        : 'Recovery plan: attend the next $needed classes continuously to reach 75%.',
                    style: TextStyle(
                      color: riskColor(p),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSent ? null : () => _openSingle(student),
              icon: Icon(
                isSent ? Icons.check_circle : Icons.send_outlined,
              ),
              label: Text(isSent ? 'ALERT SENT' : 'SEND PARENT ALERT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A93A6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      );
}
