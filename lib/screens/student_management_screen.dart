import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/common.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key, required this.controller, required this.onChanged});
  final AppController controller;
  final VoidCallback onChanged;

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  String department = 'Artificial Intelligence & Machine Learning';
  String year = '3rd Year';
  String section = 'A';
  String query = '';

  static const departments = ['Artificial Intelligence & Machine Learning', 'Computer Science Engineering', 'Information Technology'];
  static const years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  static const sections = ['A', 'B', 'C'];

  List<Student> get filtered {
    final q = query.toLowerCase().trim();
    return widget.controller.students.where((s) {
      final classMatch = s.department == department && s.year == year && s.section == section;
      if (!classMatch) return false;
      return q.isEmpty || s.name.toLowerCase().contains(q) || s.rollNumber.toLowerCase().contains(q);
    }).toList()..sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
      const SectionTitle('Student Management', subtitle: 'Add, edit and validate the roster used by faculty attendance.'),
      const SizedBox(height: 16),
      _classFilters(),
      const SizedBox(height: 12),
      TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by name or roll number')),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: Text('${filtered.length} students in $year - Section $section', style: const TextStyle(fontWeight: FontWeight.w800))),
        FilledButton.icon(onPressed: () => _studentForm(), icon: const Icon(Icons.person_add_alt_1), label: const Text('ADD')),
      ]),
      const SizedBox(height: 10),
      ...filtered.map((s) => _studentTile(s)),
      if (filtered.isEmpty) Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Column(children: [Icon(Icons.groups_2_outlined, size: 50, color: Color(0xFF7A8499)), SizedBox(height: 8), Text('No students in this class.', style: TextStyle(fontWeight: FontWeight.w800)), SizedBox(height: 5), Text('Add a student to build the attendance roster.', style: TextStyle(color: Color(0xFF7A8499)))])),
    ]));
  }

  Widget _classFilters() {
    return LayoutBuilder(builder: (context, c) {
      final children = [
        _dropdown('Department', department, departments, (v) => setState(() => department = v!)),
        _dropdown('Year', year, years, (v) => setState(() => year = v!)),
        _dropdown('Section', section, sections, (v) => setState(() => section = v!)),
      ];
      if (c.maxWidth < 650) return Column(children: [for (final child in children) Padding(padding: const EdgeInsets.only(bottom: 10), child: child)]);
      return Row(children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: c))).toList());
    });
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(initialValue: value, decoration: InputDecoration(labelText: label), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(), onChanged: onChanged);

  Widget _studentTile(Student s) {
    final stats = widget.controller.statsForStudent(s.id);
    return Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7EBF3))), child: Row(children: [CircleAvatar(backgroundColor: const Color(0xFFEFF3FF), child: Text(s.rollNumber.substring(s.rollNumber.length - 2), style: const TextStyle(color: Color(0xFF2E5BFF), fontWeight: FontWeight.w800))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text(s.rollNumber, style: const TextStyle(fontSize: 11, color: Color(0xFF7A8499)), maxLines: 1), Text(s.parentName.isEmpty ? 'Parent not added' : s.parentName, style: const TextStyle(fontSize: 11, color: Color(0xFF667089)))])), if (stats.conducted > 0) RiskBadge(stats.percentage), IconButton(onPressed: () => _studentForm(existing: s), icon: const Icon(Icons.edit_outlined)), IconButton(onPressed: () => _delete(s), icon: const Icon(Icons.delete_outline, color: Color(0xFFE5484D)))]));
  }

  Future<void> _studentForm({Student? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final roll = TextEditingController(text: existing?.rollNumber ?? '');
    final parent = TextEditingController(text: existing?.parentName ?? '');
    final phone = TextEditingController(text: existing?.parentPhone ?? '');

    String formDepartment = existing?.department ?? department;
    String formYear = existing?.year ?? year;
    String formSection = existing?.section ?? section;
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    String? validatePhone(String? value) {
      final raw = value?.trim() ?? '';
      if (raw.isEmpty) return 'Parent phone is required';

      final digits = raw.replaceAll(RegExp(r'\D'), '');
      final validTenDigit = RegExp(r'^[6-9]\d{9}$').hasMatch(digits);
      final validWithCountryCode =
          RegExp(r'^91[6-9]\d{9}$').hasMatch(digits);

      if (!validTenDigit && !validWithCountryCode) {
        return 'Enter a valid 10-digit Indian mobile number';
      }
      return null;
    }

    String normalizePhone(String value) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.startsWith('91') && digits.length == 12) {
        return digits.substring(2);
      }
      return digits;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setLocal) {
          Future<void> saveStudent() async {
            if (saving) return;
            if (!(formKey.currentState?.validate() ?? false)) return;

            setLocal(() => saving = true);

            try {
              final cleanedPhone = normalizePhone(phone.text);
              final student = Student(
                id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                name: name.text.trim(),
                rollNumber: roll.text.trim().toUpperCase(),
                parentName: parent.text.trim(),
                parentPhone: cleanedPhone,
                department: formDepartment,
                year: formYear,
                section: formSection,
              );

              if (existing == null) {
                await widget.controller.addStudent(student);
              } else {
                await widget.controller.updateStudent(student);
              }

              if (!mounted) return;
              Navigator.of(dialogContext).pop();
              setState(() {});
              widget.onChanged();

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    existing == null
                        ? '${student.name} saved successfully.'
                        : '${student.name} updated successfully.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } catch (error) {
              setLocal(() => saving = false);
              if (!mounted) return;
              ScaffoldMessenger.of(dialogContext).hideCurrentSnackBar();
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text('Could not save student: $error'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }

          return AlertDialog(
            title: Text(existing == null ? 'Add Student' : 'Edit Student'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v == null || v.trim().length < 2
                            ? 'Enter student name'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: roll,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Hall Ticket Number',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.length < 4) return 'Enter hall ticket number';
                          final duplicate = widget.controller.students.any(
                            (s) =>
                                s.rollNumber.toLowerCase() == value.toLowerCase() &&
                                s.id != existing?.id,
                          );
                          return duplicate ? 'Hall ticket already exists' : null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: parent,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Parent Name',
                          prefixIcon: Icon(Icons.family_restroom_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Parent Phone',
                          hintText: '9876543210 or +91 9876543210',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: validatePhone,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: formDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.account_tree_outlined),
                        ),
                        items: departments
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: saving
                            ? null
                            : (v) => setLocal(() => formDepartment = v!),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: formYear,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        items: years
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: saving
                            ? null
                            : (v) => setLocal(() => formYear = v!),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: formSection,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          prefixIcon: Icon(Icons.groups_outlined),
                        ),
                        items: sections
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: saving
                            ? null
                            : (v) => setLocal(() => formSection = v!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),
              FilledButton.icon(
                onPressed: saving ? null : saveStudent,
                icon: saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  saving
                      ? 'SAVING...'
                      : existing == null
                          ? 'SAVE STUDENT'
                          : 'SAVE CHANGES',
                ),
              ),
            ],
          );
        },
      ),
    );

    name.dispose();
    roll.dispose();
    parent.dispose();
    phone.dispose();
  }

  Future<void> _delete(Student s) async {
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete Student?'), content: Text('Delete ${s.name} and their saved attendance records?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')), FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE'))]));
    if (yes == true) { await widget.controller.deleteStudent(s.id); setState(() {}); widget.onChanged(); }
  }
}
