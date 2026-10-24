import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class StorageService {
  static const _studentsKey = 'ace_attendiq_students_v1';
  static const _attendanceKey = 'ace_attendiq_attendance_v1';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<List<Student>> loadStudents() async {
    final raw = await _prefs.getString(_studentsKey);
    if (raw == null) {
      final seed = _seedStudents();
      await saveStudents(seed);
      return seed;
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Student.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      final seed = _seedStudents();
      await saveStudents(seed);
      return seed;
    }
  }

  Future<void> saveStudents(List<Student> students) async {
    await _prefs.setString(
      _studentsKey,
      jsonEncode(students.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<AttendanceRecord>> loadAttendance() async {
    final raw = await _prefs.getString(_attendanceKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => AttendanceRecord.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAttendance(List<AttendanceRecord> records) async {
    await _prefs.setString(
      _attendanceKey,
      jsonEncode(records.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveAttendanceSession(
    List<AttendanceRecord> records,
    String sessionId,
  ) async {
    final all = await loadAttendance();
    all.removeWhere((r) => r.sessionId == sessionId);
    all.addAll(records);
    await saveAttendance(all);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_studentsKey);
    await _prefs.remove(_attendanceKey);
  }

  List<Student> _seedStudents() => [
        Student(
          id: '23AIML001',
          name: 'Anjali Reddy',
          rollNumber: '23AIML001',
          parentName: 'Ramesh Reddy',
          parentPhone: '9876500001',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
        Student(
          id: '23AIML002',
          name: 'Rahul Kumar',
          rollNumber: '23AIML002',
          parentName: 'Suresh Kumar',
          parentPhone: '9876500002',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
        Student(
          id: '23AIML003',
          name: 'Priya Sharma',
          rollNumber: '23AIML003',
          parentName: 'Mahesh Sharma',
          parentPhone: '9876500003',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
        Student(
          id: '23AIML004',
          name: 'Kiran Kumar',
          rollNumber: '23AIML004',
          parentName: 'Ravi Kumar',
          parentPhone: '9876500004',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
        Student(
          id: '23AIML005',
          name: 'Sneha Reddy',
          rollNumber: '23AIML005',
          parentName: 'Srinivas Reddy',
          parentPhone: '9876500005',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
        Student(
          id: '23AIML006',
          name: 'Varun Sai',
          rollNumber: '23AIML006',
          parentName: 'Naresh Sai',
          parentPhone: '9876500006',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
        Student(
          id: '23AIML007',
          name: 'Harsha Vardhan',
          rollNumber: '23AIML007',
          parentName: 'Vijay Vardhan',
          parentPhone: '9876500007',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
        Student(
          id: '23AIML008',
          name: 'Keerthana Rao',
          rollNumber: '23AIML008',
          parentName: 'Mohan Rao',
          parentPhone: '9876500008',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
        Student(
          id: '23AIML009',
          name: 'Sai Teja',
          rollNumber: '23AIML009',
          parentName: 'Satish Teja',
          parentPhone: '9876500009',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
        Student(
          id: '23AIML010',
          name: 'Meghana Das',
          rollNumber: '23AIML010',
          parentName: 'Prakash Das',
          parentPhone: '9876500010',
          department: 'Artificial Intelligence & Machine Learning',
          year: '3rd Year',
          section: 'A',
        ),
      ];
}
