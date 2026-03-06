import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore get db => _db;
  // ── Auth ──────────────────────────────────────────────────────────────────

  static String? get currentUid => _auth.currentUser?.uid;

  static Future<void> sendMagicLink(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://alive-app-b604e.firebaseapp.com/login',
      handleCodeInApp: true,
      androidPackageName: 'com.example.alive',
      androidInstallApp: true,
      androidMinimumVersion: '21',
    );
    debugPrint('Sending to: "$email"');
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  static Future<UserCredential> signInWithMagicLink({
    required String email,
    required String emailLink,
  }) async {
    return await _auth.signInWithEmailLink(
        email: email, emailLink: emailLink);
  }

  static bool isValidMagicLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  // ── User Profile ─────────────────────────────────────────────────────────

  static Future<bool> userProfileExists() async {
      if (currentUid == null) return false;
      final doc = await _db.collection('users').doc(currentUid).get();
      return doc.exists;
    }

  static Future<void> saveUserProfile({
    required String name,
    required String dob,
    required String pincode,
    required String district,
    required String state,
    required String country,
    required String phone,    // kept for details only
    required String language,
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final email = _auth.currentUser?.email ?? '';  // ← get email from auth
    await _db.collection('users').doc(currentUid).set({
      'name': name,
      'dob': dob,
      'pincode': pincode,
      'district': district,
      'state': state,
      'country': country,
      'phone': phone,
      'email': email,
      'language': language,
      'fcmToken': fcmToken ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateFcmToken(String token) async {
    if (currentUid == null) return;
    await _db.collection('users').doc(currentUid).update({'fcmToken': token});
  }

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── Connections ───────────────────────────────────────────────────────────

  static Future<bool> connectionExists() async {
    if (currentUid == null) return false;
    final doc = await _db.collection('connections').doc(currentUid).get();
    return doc.exists;
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchConnection(
      String senderId) {
    return _db.collection('connections').doc(senderId).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchReceiverConnections(
      String receiverId) {
    return _db
        .collection('connections')
        .where('receiverId', isEqualTo: receiverId)
        .where('status', whereIn: ['PENDING', 'ACTIVE']).snapshots();
  }

  static Future<String?> findUserByEmail(String email) async {
    // Firebase Auth lets us look up uid by email directly
    try {
      // final methods = await _auth.fetchSignInMethodsForEmail(email);
      // if (methods.isEmpty) return null;
      // Get uid from users collection by email
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      return query.docs.first.id;
    } catch (e) {
      return null;
    }
  }

  /// Sender creates a connection and triggers FCM invite via Cloud Function
  static Future<void> createConnection({
    required String receiverId,
    required String contactName,
    required String relationship,
    required String contactEmail,
  }) async {
    final senderId = currentUid!;
    await _db.collection('connections').doc(senderId).set({
      'senderId': senderId,
      'receiverId': receiverId,
      'contactName': contactName,
      'relationship': relationship,
      'contactEmail': contactEmail,
      'status': 'PENDING',
      'lastAliveTimestamp': null,
      'alertSent': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sender re-enters contact after rejection (overwrites connection doc)
  static Future<void> updateConnection({
    required String receiverId,
    required String contactName,
    required String relationship,
    required String contactEmail,
  }) async {
    final senderId = currentUid!;
    await _db.collection('connections').doc(senderId).update({
      'receiverId': receiverId,
      'contactName': contactName,
      'relationship': relationship,
      'contactEmail': contactEmail,
      'status': 'PENDING',
      'lastAliveTimestamp': null,
      'alertSent': false,
    });
  }

  /// Sender presses ALIVE button
  static Future<void> pressAlive() async {
    final senderId = currentUid!;
    await _db.collection('connections').doc(senderId).update({
      'lastAliveTimestamp': FieldValue.serverTimestamp(),
      'alertSent': false,
    });
  }

  /// Receiver accepts the invitation
  static Future<void> acceptInvitation(String senderId) async {
    await _db.collection('connections').doc(senderId).update({
      'status': 'ACTIVE',
      'lastAliveTimestamp': FieldValue.serverTimestamp(),
      'alertSent': false,
    });
  }

  /// Receiver denies the invitation
  static Future<void> denyInvitation(String senderId) async {
    await _db.collection('connections').doc(senderId).update({
      'status': 'REJECTED',
    });
  }

  // ── Role detection ────────────────────────────────────────────────────────

  /// Returns 'sender', 'receiver', or 'none'
  static Future<String> detectUserRole() async {
    if (currentUid == null) return 'none';

    // Is this user a sender?
    final senderDoc =
        await _db.collection('connections').doc(currentUid).get();
    if (senderDoc.exists) return 'sender';

    // Is this user a receiver?
    final receiverQuery = await _db
        .collection('connections')
        .where('receiverId', isEqualTo: currentUid)
        .limit(1)
        .get();
    if (receiverQuery.docs.isNotEmpty) return 'receiver';

    return 'none';
  }

  static Future<String?> getSenderIdForReceiver() async {
    if (currentUid == null) return null;
    final query = await _db
        .collection('connections')
        .where('receiverId', isEqualTo: currentUid)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> getPendingInvitation() async {
    if (currentUid == null) return null;
    final query = await _db
        .collection('connections')
        .where('receiverId', isEqualTo: currentUid)
        .where('status', isEqualTo: 'PENDING')
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }
}