import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'emergency_contact_screen.dart';
import 'receiver_invitation_screen.dart';
import 'package:alive/generated/app_localizations.dart';

class SenderDashboard extends StatefulWidget {
  const SenderDashboard({super.key});

  @override
  State<SenderDashboard> createState() => _SenderDashboardState();
}

class _SenderDashboardState extends State<SenderDashboard> {
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  bool _pressedRecently = false;

  @override
  void initState() {
    super.initState();
    _setupNotificationHandling();
    _checkPendingInvitations(); 
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPendingInvitations() async {
    // Small delay to let the screen render first
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    final pendingInvite = await FirebaseService.getPendingInvitation();
    if (pendingInvite != null && mounted) {
      final senderId = pendingInvite.data()?['senderId'] as String;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceiverInvitationScreen(senderId: senderId),
        ),
      );
    }
  }
  
  void _setupNotificationHandling() {
    NotificationService.onNotificationTap = (data) {
      final type = data['type'];
      if (type == 'alive_request' && mounted) {
        final senderId = data['senderId'];
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ReceiverInvitationScreen(senderId: senderId)));
      } else if (type == 'alert_triggered' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '⚠️ Alert has been sent to your emergency contact!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    };
  }

  void _startCountdown(Timestamp? lastAlive) {
    _countdownTimer?.cancel();
    if (lastAlive == null) {
      setState(() => _remaining = const Duration(hours: 48));
      return;
    }
    _updateRemaining(lastAlive);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining(lastAlive);
    });
  }

  void _updateRemaining(Timestamp lastAlive) {
    final elapsed = DateTime.now().difference(lastAlive.toDate());
    final remaining = const Duration(hours: 48) - elapsed;
    setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
  }

  Future<void> _pressAlive() async {
    setState(() => _pressedRecently = true);
    await FirebaseService.pressAlive();
    Future.delayed(const Duration(seconds: 3),
        () => mounted ? setState(() => _pressedRecently = false) : null);
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String get _countdownText {
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    return '${_twoDigits(h)}:${_twoDigits(m)}:${_twoDigits(s)}';
  }

  Color get _timerColor {
    if (_remaining.inHours >= 24) return Colors.green;
    if (_remaining.inHours >= 8) return Colors.orange;
    return Colors.red;
  }


  Widget _buildPendingView(dynamic l10n, Map<String, dynamic> data) {
    final contactName = data['contactName'] ?? '';
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.hourglass_top_rounded,
                    size: 64, color: Colors.orange.shade400),
                const SizedBox(height: 16),
                Text(
                  l10n.requestSentWaiting,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (contactName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Waiting for $contactName to accept',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 14)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedView(dynamic l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.cancel_outlined, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  l10n.requestRejected,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) =>
                      const EmergencyContactScreen(isReEntry: true)),
            ),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.changeContact),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView(dynamic l10n, Map<String, dynamic> data) {
    final contactName = data['contactName'] ?? '';
    final relationship = data['relationship'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status badge
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 10, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(l10n.statusActive,
                      style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (contactName.isNotEmpty)
            Center(
              child: Text(
                'Monitored by: $contactName ($relationship)',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          const SizedBox(height: 32),

          // Countdown timer
          Center(
            child: Column(
              children: [
                Text(l10n.timeRemaining,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(
                  _countdownText,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: _timerColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // ALIVE button (circular, matching the design)
          Center(
            child: GestureDetector(
              onTap: _pressAlive,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pressedRecently
                      ? Colors.green
                      : const Color(0xFF3D6EEA),
                  boxShadow: [
                    BoxShadow(
                      color: (_pressedRecently
                              ? Colors.green
                              : const Color(0xFF3D6EEA))
                          .withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _pressedRecently ? '✓' : l10n.alive,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              l10n.aliveButtonHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          if (_pressedRecently) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.alivePressed,
                style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseService.currentUid!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ALIVE',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF3D6EEA))),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseService.watchConnection(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3D6EEA)));
          }

          final data = snapshot.data?.data();
          if (data == null) {
            return Center(child: Text(l10n.error));
          }

          final status = data['status'] as String? ?? 'PENDING';

          if (status == 'PENDING') {
            return _buildPendingView(l10n, data);
          } else if (status == 'REJECTED') {
            return _buildRejectedView(l10n);
          } else if (status == 'ACTIVE') {
            final lastAlive = data['lastAliveTimestamp'] as Timestamp?;
            // Start/update timer when data changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startCountdown(lastAlive);
            });
            return _buildActiveView(l10n, data);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}