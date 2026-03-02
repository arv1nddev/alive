import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Auth ──────────────────────────────────────────────────────────────────

  static String? get currentUid => _auth.currentUser?.uid;
  static String? get currentPhone => _auth.currentUser?.phoneNumber;

  static Future<void> verifyPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onAutoVerified,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onAutoVerified,
      verificationFailed: onError,
      codeSent: (verificationId, resendToken) =>
          onCodeSent(verificationId, resendToken),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  static Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  static Future<UserCredential> signInWithOtp(
      String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return await _auth.signInWithCredential(credential);
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
    required String language,
  }) async {
    debugPrint("fetching fcm token");
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("fetched fcm token");
    debugPrint("accessing db ");
    await _db.collection('users').doc(currentUid).set({
      'name': name,
      'dob': dob,
      'pincode': pincode,
      'district': district,
      'state': state,
      'country': country,
      'phone': currentPhone ?? '',
      'language': language,
      'fcmToken': fcmToken ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint("saved");
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
    // Check if user is sender
    final senderDoc =
        await _db.collection('connections').doc(currentUid).get();
    if (senderDoc.exists) return true;
    // Check if user is receiver
    final receiverQuery = await _db
        .collection('connections')
        .where('receiverId', isEqualTo: currentUid)
        .limit(1)
        .get();
    return receiverQuery.docs.isNotEmpty;
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

  /// Returns the uid of a user given their phone number, or null if not found.
  static Future<String?> findUserByPhone(String phone) async {
    final query = await _db
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  /// Sender creates a connection and triggers FCM invite via Cloud Function
  static Future<void> createConnection({
    required String receiverId,
    required String contactName,
    required String relationship,
    required String contactPhone,
  }) async {
    final senderId = currentUid!;
    await _db.collection('connections').doc(senderId).set({
      'senderId': senderId,
      'receiverId': receiverId,
      'contactName': contactName,
      'relationship': relationship,
      'contactPhone': contactPhone,
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
    required String contactPhone,
  }) async {
    final senderId = currentUid!;
    await _db.collection('connections').doc(senderId).update({
      'receiverId': receiverId,
      'contactName': contactName,
      'relationship': relationship,
      'contactPhone': contactPhone,
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
}