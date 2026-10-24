class Student {
  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.parentName,
    required this.parentPhone,
    required this.department,
    required this.year,
    required this.section,
  });

  final String id;
  String name;
  String rollNumber;
  String parentName;
  String parentPhone;
  String department;
  String year;
  String section;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rollNumber': rollNumber,
        'parentName': parentName,
        'parentPhone': parentPhone,
        'department': department,
        'year': year,
        'section': section,
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        name: json['name'] as String,
        rollNumber: json['rollNumber'] as String,
        parentName: json['parentName'] as String? ?? '',
        parentPhone: json['parentPhone'] as String? ?? '',
        department: json['department'] as String,
        year: json['year'] as String,
        section: json['section'] as String,
      );
}

class AttendanceRecord {
  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.date,
    required this.studentId,
    required this.department,
    required this.year,
    required this.section,
    required this.subject,
    required this.hour,
    required this.present,
  });

  final String id;
  final String sessionId;
  final DateTime date;
  final String studentId;
  final String department;
  final String year;
  final String section;
  final String subject;
  final String hour;
  bool present;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'date': date.toIso8601String(),
        'studentId': studentId,
        'department': department,
        'year': year,
        'section': section,
        'subject': subject,
        'hour': hour,
        'present': present,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        date: DateTime.parse(json['date'] as String),
        studentId: json['studentId'] as String,
        department: json['department'] as String,
        year: json['year'] as String,
        section: json['section'] as String,
        subject: json['subject'] as String,
        hour: json['hour'] as String,
        present: json['present'] as bool,
      );
}

class ClassSelection {
  ClassSelection({
    required this.department,
    required this.year,
    required this.section,
    required this.subject,
    required this.hour,
  });

  String department;
  String year;
  String section;
  String subject;
  String hour;

  String get sessionPrefix =>
      '$department|$year|$section|$subject|$hour';
}

class AttendanceStats {
  const AttendanceStats({
    required this.conducted,
    required this.attended,
  });

  final int conducted;
  final int attended;

  int get absent => conducted - attended;
  double get percentage => conducted == 0 ? 0 : attended / conducted * 100;

  int classesNeededForTarget(double target) {
    if (conducted == 0 || percentage >= target) return 0;
    var future = 0;
    while (((attended + future) / (conducted + future)) * 100 < target) {
      future++;
      if (future > 10000) break;
    }
    return future;
  }
}
