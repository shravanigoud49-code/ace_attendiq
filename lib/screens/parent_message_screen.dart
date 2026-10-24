import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_controller.dart';
import '../widgets/common.dart';

class ParentMessageScreen extends StatefulWidget {
  const ParentMessageScreen({super.key, required this.controller, required this.student, required this.selection, required this.date, this.onSent});
  final AppController controller;
  final Student student;
  final ClassSelection selection;
  final DateTime date;
  final VoidCallback? onSent;

  @override
  State<ParentMessageScreen> createState() => _ParentMessageScreenState();
}

class _ParentMessageScreenState extends State<ParentMessageScreen> {
  bool sending = false;
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    final stats = widget.controller.statsForStudent(widget.student.id, subject: widget.selection.subject, department: widget.selection.department, year: widget.selection.year, section: widget.selection.section);
    final after = AttendanceStats(conducted: stats.conducted, attended: stats.attended);
    final message = '''ACE AttendIQ - Attendance Alert

Dear ${widget.student.parentName.isEmpty ? 'Parent' : widget.student.parentName},

Your ward ${widget.student.name}
Hall Ticket No: ${widget.student.rollNumber}

was marked ABSENT for:
Subject: ${widget.selection.subject}
Hour: ${widget.selection.hour}
Date: ${widget.date.day.toString().padLeft(2, '0')}/${widget.date.month.toString().padLeft(2, '0')}/${widget.date.year}

Current Attendance: ${after.percentage.toStringAsFixed(2)}%

Required Attendance: 75%

- ACE Engineering College
Department of Artificial Intelligence & Machine Learning''';

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Alert', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE7EBF3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Message Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF7F8FC), borderRadius: BorderRadius.circular(16)), child: SelectableText(message, style: const TextStyle(height: 1.55, fontSize: 14))),
        ])),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: riskColor(after.percentage).withOpacity(.08), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(after.percentage < 75 ? Icons.warning_amber_rounded : Icons.check_circle, color: riskColor(after.percentage)), const SizedBox(width: 10), Expanded(child: Text('Current attendance: ${after.percentage.toStringAsFixed(2)}%', style: TextStyle(color: riskColor(after.percentage), fontWeight: FontWeight.w800)))])),
        const SizedBox(height: 10),
        if (widget.student.parentPhone.trim().isEmpty) const Text('Parent phone number is missing. Add it in Student Management before sending.', style: TextStyle(color: Color(0xFFE5484D))),
        const SizedBox(height: 14),
        SizedBox(height: 52, child: FilledButton.icon(onPressed: widget.student.parentPhone.trim().isEmpty || sending || sent ? null : () => _send(message), icon: sent ? const Icon(Icons.check_circle) : sending ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send), label: Text(sent ? 'MESSAGE SENT' : sending ? 'SENDING...' : 'SEND MESSAGE', style: const TextStyle(fontWeight: FontWeight.w800)))),
      ]),
    );
  }

  Future<void> _send(String message) async {
    setState(() => sending = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() { sending = false; sent = true; });
    widget.onSent?.call();
    if (!mounted) return;
    await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Notification Sent'), content: Text('Demo message prepared for ${widget.student.parentName.isEmpty ? 'the parent' : widget.student.parentName}.\n\nParent phone: ${widget.student.parentPhone}\n\nReal SMS/WhatsApp delivery will be connected through a backend/provider.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
  }
}
