import '../models/models.dart';
import 'storage_service.dart';

class AppController {
  AppController(this.storage);
  final StorageService storage;

  List<Student> students = [];
  List<AttendanceRecord> records = [];

  Future<void> init() async {
    students = await storage.loadStudents();
    records = await storage.loadAttendance();
  }

  Future<void> saveStudents() async => storage.saveStudents(students);

  Future<void> addStudent(Student student) async {
    students.add(student);
    await saveStudents();
  }

  Future<void> updateStudent(Student student) async {
    final index = students.indexWhere((s) => s.id == student.id);
    if (index >= 0) {
      students[index] = student;
      await saveStudents();
    }
  }

  Future<void> deleteStudent(String id) async {
    students.removeWhere((s) => s.id == id);
    records.removeWhere((r) => r.studentId == id);
    await storage.saveStudents(students);
    await storage.saveAttendance(records);
  }

  List<Student> studentsForClass(ClassSelection selection) {
    return students
        .where((s) =>
            s.department == selection.department &&
            s.year == selection.year &&
            s.section == selection.section)
        .toList()
      ..sort((a, b) => a.rollNumber.compareTo(b.rollNumber));
  }

  AttendanceStats statsForStudent(
    String studentId, {
    String? subject,
    String? department,
    String? year,
    String? section,
    DateTime? from,
    DateTime? to,
  }) {
    final list = records.where((r) {
      if (r.studentId != studentId) return false;
      if (subject != null && subject.isNotEmpty && r.subject != subject) return false;
      if (department != null && department.isNotEmpty && r.department != department) return false;
      if (year != null && year.isNotEmpty && r.year != year) return false;
      if (section != null && section.isNotEmpty && r.section != section) return false;
      if (from != null && r.date.isBefore(from)) return false;
      if (to != null && r.date.isAfter(to)) return false;
      return true;
    }).toList();
    return AttendanceStats(
      conducted: list.length,
      attended: list.where((r) => r.present).length,
    );
  }

  Future<void> saveAttendanceSession({
    required ClassSelection selection,
    required List<String> presentStudentIds,
    required DateTime date,
  }) async {
    final sessionId = '${_dateKey(date)}|${selection.sessionPrefix}';
    final classStudents = studentsForClass(selection);
    final newRecords = classStudents.map((student) {
      return AttendanceRecord(
        id: '${sessionId}|${student.id}',
        sessionId: sessionId,
        date: date,
        studentId: student.id,
        department: selection.department,
        year: selection.year,
        section: selection.section,
        subject: selection.subject,
        hour: selection.hour,
        present: presentStudentIds.contains(student.id),
      );
    }).toList();

    await storage.saveAttendanceSession(newRecords, sessionId);
    records = await storage.loadAttendance();
  }

  List<AttendanceRecord> recordsForSession(
    ClassSelection selection,
    DateTime date,
  ) {
    final sid = '${_dateKey(date)}|${selection.sessionPrefix}';
    return records.where((r) => r.sessionId == sid).toList();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
