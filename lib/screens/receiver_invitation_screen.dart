import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'receiver_dashboard.dart';
import 'package:alive/generated/app_localizations.dart';

class ReceiverInvitationScreen extends StatefulWidget {
  final String senderId;
  const ReceiverInvitationScreen({super.key, required this.senderId});

  @override
  State<ReceiverInvitationScreen> createState() =>
      _ReceiverInvitationScreenState();
}

class _ReceiverInvitationScreenState
    extends State<ReceiverInvitationScreen> {
  Map<String, dynamic>? _senderData;
  bool _loading = true;
  bool _responding = false;

  @override
  void initState() {
    super.initState();
    _loadSenderData();
  }

  Future<void> _loadSenderData() async {
    try {
      final data = await FirebaseService.getUserProfile(widget.senderId);
      if (mounted) {
        setState(() {
          _senderData = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _accept() async {
    setState(() => _responding = true);
    await FirebaseService.acceptInvitation(widget.senderId);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ReceiverDashboard()),
        (_) => false,
      );
    }
  }

  Future<void> _deny() async {
    setState(() => _responding = true);
    await FirebaseService.denyInvitation(widget.senderId);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ReceiverDashboard()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF3D6EEA))),
      );
    }

    final senderName = _senderData?['name'] ?? 'Unknown';
    final senderPhone = _senderData?['phone'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Invitation header
              const Icon(Icons.favorite_border,
                  size: 64, color: Color(0xFF3D6EEA)),
              const SizedBox(height: 24),
              Text(
                l10n.invitationFrom,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                senderName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
              if (senderPhone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  senderPhone,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
              const SizedBox(height: 32),

              // Explanation card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D6EEA).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF3D6EEA).withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFF3D6EEA)),
                    const SizedBox(height: 12),
                    Text(
                      '$senderName wants you to be their emergency contact. '
                      'You will receive an alert if they don\'t press ALIVE '
                      'within 48 hours.',
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Action buttons
              _responding
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF3D6EEA)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _accept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: Text(l10n.accept,
                              style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _deny,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: Text(l10n.deny,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.red)),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}