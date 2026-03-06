import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _emailController = TextEditingController();
  bool _linkSent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await FirebaseService.sendMagicLink(email);

      // Save email locally — needed when the link is tapped to complete sign in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('magic_link_email', email);

      setState(() { _linkSent = true; _loading = false; });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Failed to send link';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              const Text(
                'ALIVE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D6EEA),
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in with magic link',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              if (!_linkSent) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Color(0xFF3D6EEA)),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 14)),
                ],
                const SizedBox(height: 24),
                _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF3D6EEA)))
                    : ElevatedButton(
                        onPressed: _sendLink,
                        child: const Text('Send Magic Link'),
                      ),
              ] else ...[
                // Check inbox screen
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D6EEA).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mark_email_unread_outlined,
                          size: 64, color: Color(0xFF3D6EEA)),
                      const SizedBox(height: 16),
                      const Text(
                        'Check your inbox!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We sent a sign-in link to\n${_emailController.text.trim()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the link in the email to sign in.\nYou can close this screen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Don\'t see it? Check your spam folder.',
                                style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => setState(() {
                    _linkSent = false;
                    _error = null;
                  }),
                  child: const Text('Use a different email',
                      style: TextStyle(color: Color(0xFF3D6EEA))),
                ),
                TextButton(
                  onPressed: _loading ? null : _sendLink,
                  child: const Text('Resend link',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}