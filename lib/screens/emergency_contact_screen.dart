import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'startup_screen.dart';
import 'package:alive/generated/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyContactScreen extends StatefulWidget {
  final bool isReEntry;
  const EmergencyContactScreen({super.key, this.isReEntry = false});

  @override
  State<EmergencyContactScreen> createState() =>
      _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  Future<void> _sendInviteNotification({
    required String senderId,
    required String senderName,
    required String receiverFcmToken,
  }) async {
    debugPrint('trying');
    try {
      final response = await http.post(
        Uri.parse('https://alive-worker.mr-arvind9724.workers.dev/send-invite'),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': 'aliveapp123',
        },
        body: jsonEncode({
          'senderId': senderId,
          'senderName': senderName,
          'receiverFcmToken': receiverFcmToken,
        }),
      );
       debugPrint('Worker status: ${response.statusCode}');
       debugPrint('Worker response: ${response.body}');
    } catch (e) {
      debugPrint('Invite notification failed: $e');
    }
    debugPrint('sentttt');
  }

  Future<void> _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final contactEmail = _emailController.text.trim();
      final receiverId = await FirebaseService.findUserByEmail(contactEmail);
      if (receiverId == null) {
        setState(() {
          _error = 'No user found with that email. They must register with this email first.';
          _loading = false;
        });
        return;
      }

      if (receiverId == FirebaseService.currentUid) {
        setState(() {
          _error = 'You cannot add yourself as an emergency contact.';
          _loading = false;
        });
        return;
      }
      if (widget.isReEntry) {
        await FirebaseService.updateConnection(
          receiverId: receiverId,
          contactName: _nameController.text.trim(),
          relationship: _relationshipController.text.trim(),
          contactEmail: contactEmail,
        );
      } else {

        await FirebaseService.createConnection(
          receiverId: receiverId,
          contactName: _nameController.text.trim(),
          relationship: _relationshipController.text.trim(),
          contactEmail: contactEmail,
        );
      }
      final senderData = await FirebaseService.getUserProfile(FirebaseService.currentUid!);
      final receiverData = await FirebaseService.getUserProfile(receiverId);

      debugPrint("Receiver FCM token: $receiverData?['fcmToken']");
      debugPrint('Receiver data: $receiverData');
      await _sendInviteNotification(
        senderId: FirebaseService.currentUid!,
        senderName: senderData?['name'] ?? 'Someone',
        receiverFcmToken: receiverData?['fcmToken'] ?? '',
      );
      debugPrint('invite sent');

      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const StartupScreen()));
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.emergencyContact,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D6EEA).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Your emergency contact will receive an alert if you don\'t press ALIVE within 48 hours. They must already have the app installed.',
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF3D6EEA), height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.contactName,
                  prefixIcon: const Icon(Icons.person_outline,
                      color: Color(0xFF3D6EEA)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationshipController,
                decoration: InputDecoration(
                  labelText: l10n.relationship,
                  hintText: 'e.g. Father, Spouse, Friend',
                  prefixIcon: const Icon(Icons.people_outline,
                      color: Color(0xFF3D6EEA)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.contactEmail,
                  hintText: '+example@email.com',
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: Color(0xFF3D6EEA)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!,
                      style: TextStyle(
                          color: Colors.red.shade700, fontSize: 14)),
                ),
              ],
              const SizedBox(height: 32),
              _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF3D6EEA)))
                  : ElevatedButton(
                      onPressed: _sendRequest,
                      child: Text(l10n.sendRequest),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}