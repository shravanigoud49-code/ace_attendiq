import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../services/storage_service.dart';
import 'app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final e = email.text.trim();
    final p = password.text;
    if (e.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      _error('Enter a valid faculty email.');
      return;
    }
    if (p.length < 4) {
      _error('Password must contain at least 4 characters.');
      return;
    }

    setState(() => loading = true);
    final controller = AppController(StorageService());
    await controller.init();
    if (!mounted) return;
    setState(() => loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AppShell(controller: controller, facultyEmail: e)),
    );
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Container(
                    height: 92,
                    width: 92,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E5BFF), Color(0xFF5A7BFF)],
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'ACE AttendIQ',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF172033)),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Smart Attendance • Risk Analysis • Parent Alerts',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7A8499)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ACE Engineering College • Department of AI & ML',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7A8499), fontSize: 12),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE7EBF3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Faculty Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        const Text('Use your faculty credentials to continue.', style: TextStyle(color: Color(0xFF7A8499))),
                        const SizedBox(height: 18),
                        TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Faculty Email', prefixIcon: Icon(Icons.mail_outline)),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: password,
                          obscureText: obscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => obscure = !obscure),
                              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: loading ? null : login,
                            icon: loading
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.login_rounded),
                            label: Text(loading ? 'LOADING...' : 'LOGIN', style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Demo: any valid email + 4+ character password', style: TextStyle(color: Color(0xFF8A93A6), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
