import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'startup_screen.dart';
import 'package:alive/generated/app_localizations.dart';
import 'profile_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  bool _otpSent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Please enter phone number');
      return;
    }
    
    setState(() {
      _loading = true;
      _error = null;
    });

    await FirebaseService.verifyPhone(
      phoneNumber: phone,
      onAutoVerified: (credential) async {
        await FirebaseService.signInWithCredential(credential);
        if (mounted) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StartupScreen()));
        }
      },
      onCodeSent: (verificationId, _) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _loading = false;
        });
      },
      onError: (e) {
        setState(() {
          _error = e.message ?? 'Verification failed';
          _loading = false;
        });
      },
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || _verificationId == null) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var cd = await FirebaseService.signInWithOtp(_verificationId!, otp);
      debugPrint('verid : $_verificationId');
      debugPrint('cds : ${cd.toString()}');
      if (mounted) {
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfileScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Invalid OTP';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              const SizedBox(height: 48),
              Text(
                l10n.phoneNumber,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
                decoration: const InputDecoration(
                  hintText: '+91XXXXXXXXXX',
                  prefixIcon:
                      Icon(Icons.phone, color: Color(0xFF3D6EEA)),
                ),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.enterOtp,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    hintText: '------',
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Color(0xFF3D6EEA)),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14)),
              ],
              const SizedBox(height: 24),
              _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF3D6EEA)))
                  : ElevatedButton(
                      onPressed: _otpSent ? _verifyOtp : _sendOtp,
                      child: Text(_otpSent ? l10n.verifyOtp : l10n.sendOtp),
                    ),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() {
                    _otpSent = false;
                    _error = null;
                    _otpController.clear();
                  }),
                  child: const Text('Change number',
                      style: TextStyle(color: Color(0xFF3D6EEA))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}