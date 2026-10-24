# ACE AttendIQ

Smart Classroom Attendance, Risk Analysis, Recovery Planning, and Parent Communication prototype for ACE Engineering College, Department of Artificial Intelligence & Machine Learning.

## Included
- Faculty login validation
- Department / year / section / subject / hour selection
- Student management (add/edit/delete)
- Searchable student roster
- Present/absent attendance marking
- Daily and cumulative attendance percentage
- 75% risk analysis and recovery calculation
- Absent-student review
- Parent message preview / demo send status
- Monthly and subject-wise reports
- Local persistence using shared_preferences

## Project structure

```text
ace_attendiq/
├── lib/
│   ├── main.dart
│   ├── models/models.dart
│   ├── screens/
│   │   ├── app_shell.dart
│   │   ├── attendance_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── login_screen.dart
│   │   ├── parent_message_screen.dart
│   │   ├── reports_screen.dart
│   │   └── student_management_screen.dart
│   ├── services/
│   │   ├── app_controller.dart
│   │   └── storage_service.dart
│   └── widgets/common.dart
├── test/widget_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── .gitignore
```

## Run on Chrome

```powershell
cd F:\ace_attendiq
flutter pub get
flutter run -d chrome
```

## Generate Android/Web platform folders when needed

If this source package does not already have `android/` or `web/` folders, run from the project root:

```powershell
flutter create --platforms=android,web .
flutter pub get
```

This preserves the existing `lib/` code and generates the platform scaffolding using your installed Flutter SDK.

## Important
The parent Send button is currently a demo/local status action. Real SMS/WhatsApp delivery requires a messaging provider and backend integration.


## Bulk Parent Alerts
After attendance is submitted, the Absent Students screen supports **SEND ALL PARENT ALERTS** plus an individual send button. Each generated alert uses the student name, hall ticket number, subject, absent hour and current attendance percentage. The current implementation simulates the send flow; real SMS/WhatsApp delivery requires a backend/provider integration.
