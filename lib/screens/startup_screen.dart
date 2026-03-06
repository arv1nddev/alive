import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import 'language_screen.dart';
import 'otp_screen.dart';
import 'profile_screen.dart';
import 'emergency_contact_screen.dart';
import 'sender_dashboard.dart';
import 'receiver_invitation_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language') == null) { _go(LanguageScreen()); return; }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { _go(const OtpScreen()); return; }

    final profileExists = await FirebaseService.userProfileExists();
    if (!profileExists) { _go(const ProfileScreen()); return; }

    // After profileExists check, before connection check
    // Always update FCM token on login
    final freshToken = await FirebaseMessaging.instance.getToken();
    if (freshToken != null) {
      await FirebaseService.updateFcmToken(freshToken);
    }
    final senderDoc = await FirebaseService.db
        .collection('connections')
        .doc(user.uid)
        .get();
    
    if (!senderDoc.exists) {
      _go(const EmergencyContactScreen());
      return;
    }

    final pendingInvite = await FirebaseService.getPendingInvitation();
    if (pendingInvite != null) {
      final senderId = pendingInvite.data()?['senderId'] as String;
      // Go to dashboard first then push invitation on top
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SenderDashboard()),
        );
        // Small delay so dashboard is mounted before pushing on top
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReceiverInvitationScreen(senderId: senderId),
            ),
          );
        }
      }
      return;
    }

    _go(const SenderDashboard());
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