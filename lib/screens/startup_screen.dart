import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firebase_service.dart';
import 'language_screen.dart';
import 'otp_screen.dart';
import 'profile_screen.dart';
import 'emergency_contact_screen.dart';
import 'sender_dashboard.dart';
import 'receiver_dashboard.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('resolving');
    _resolve();
    debugPrint('resolved');
  }

  Future<void> _resolve() async {
    debugPrint('timer');
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('timed');

    if (!mounted) return;

    debugPrint('lc');
    // 1. Check language
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language');
    if (language == null) {
      _go(LanguageScreen());
      return;
    }

    debugPrint('ac');
    // 2. Check auth
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _go(const OtpScreen());
      return;
    }

    debugPrint('upc');
    // 3. Check user profile
    final profileExists = await FirebaseService.userProfileExists();
    if (!profileExists) {
      _go(const ProfileScreen());
      return;
    }

    debugPrint('cc');
    // 4. Check connection
    final connectionExists = await FirebaseService.connectionExists();
    if (!connectionExists) {
      _go(const EmergencyContactScreen());
      return;
    }

    debugPrint('rc');
    // 5. Detect role and navigate to appropriate dashboard
    final role = await FirebaseService.detectUserRole();
    if (role == 'receiver') {
      _go(const ReceiverDashboard());
    } else {
      _go(const SenderDashboard());
    }
  }

  void _go(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ALIVE',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D6EEA),
                letterSpacing: 8,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Color(0xFF3D6EEA)),
          ],
        ),
      ),
    );
  }
}