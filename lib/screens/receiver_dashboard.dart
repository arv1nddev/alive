import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'receiver_invitation_screen.dart';
import 'package:alive/generated/app_localizations.dart';

class ReceiverDashboard extends StatefulWidget {
  const ReceiverDashboard({super.key});

  @override
  State<ReceiverDashboard> createState() => _ReceiverDashboardState();
}

class _ReceiverDashboardState extends State<ReceiverDashboard> {
  @override
  void initState() {
    super.initState();
    _setupNotificationHandling();
  }

  void _setupNotificationHandling() {
    NotificationService.onNotificationTap = (data) {
      final type = data['type'];
      if (type == 'alive_request' && mounted) {
        final senderId = data['senderId'];
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                ReceiverInvitationScreen(senderId: senderId)));
      } else if (type == 'alert_triggered' && mounted) {
        _showAlertDialog();
      }
    };
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.orange, size: 48),
        title: const Text('Safety Alert'),
        content: const Text(
            '⚠️ Your monitored contact has not checked in for 48 hours. Please try to reach them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseService.watchReceiverConnections(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3D6EEA)));
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return _buildEmptyView(l10n);
          }

          final connection = docs.first.data();
          final status = connection['status'] as String? ?? 'PENDING';

          if (status == 'PENDING') {
            return _buildPendingView(connection, docs.first.id);
          } else if (status == 'ACTIVE') {
            return _buildActiveMonitorView(l10n, connection);
          }

          return _buildEmptyView(l10n);
        },
      ),
    );
  }

  Widget _buildEmptyView(dynamic l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No active monitoring connections',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive a notification when someone adds you as their emergency contact.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingView(Map<String, dynamic> data, String senderId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF3D6EEA).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF3D6EEA).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person_add_outlined,
                      size: 48, color: Color(0xFF3D6EEA)),
                  const SizedBox(height: 16),
                  const Text('You have a pending request',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${data['contactName'] ?? 'Someone'} wants you to monitor them',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      ReceiverInvitationScreen(senderId: senderId))),
              child: const Text('View Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMonitorView(
      dynamic l10n, Map<String, dynamic> data) {
    final contactName = data['contactName'] ?? 'Unknown';
    final relationship = data['relationship'] ?? '';
    final lastAlive = data['lastAliveTimestamp'] as Timestamp?;
    final alertSent = data['alertSent'] as bool? ?? false;

    String lastSeen = 'Never';
    if (lastAlive != null) {
      final diff = DateTime.now().difference(lastAlive.toDate());
      if (diff.inMinutes < 60) {
        lastSeen = '${diff.inMinutes} minutes ago';
      } else if (diff.inHours < 24) {
        lastSeen = '${diff.inHours} hours ago';
      } else {
        lastSeen = '${diff.inDays} days ago';
      }
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Alert banner
          if (alertSent)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red.shade500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.alertReceived,
                      style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Contact card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor:
                      const Color(0xFF3D6EEA).withOpacity(0.1),
                  child: Text(
                    contactName.isNotEmpty
                        ? contactName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D6EEA)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(contactName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(relationship,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text('Last checked in: $lastSeen',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text('Monitoring Active',
                    style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}