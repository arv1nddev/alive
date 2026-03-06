// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Alive';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get noAccount => 'Don\'t have an account? Register';

  @override
  String get alreadyAccount => 'Already have an account? Login';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get passwordResetSent => 'Password reset email sent!';

  @override
  String get profileDetails => 'Profile Details';

  @override
  String get name => 'Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get pincode => 'Pincode';

  @override
  String get district => 'District';

  @override
  String get state => 'State';

  @override
  String get country => 'Country';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get emergencyContact => 'Emergency Contact Details';

  @override
  String get contactName => 'Contact Name';

  @override
  String get relationship => 'Relationship';

  @override
  String get contactEmail => 'Contact Email';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get requestSentWaiting => 'Request Sent – Waiting for Acceptance';

  @override
  String get requestRejected => 'Request Rejected – Enter Contact Again';

  @override
  String get changeContact => 'Change Contact';

  @override
  String get alive => 'ALIVE';

  @override
  String get statusActive => 'Status: ACTIVE';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get alivePressed => '✓ You\'re marked as Alive!';

  @override
  String get aliveButtonHint => 'Press every 48 hours to confirm you are safe';

  @override
  String get invitationFrom => 'Safety monitoring request from';

  @override
  String get accept => 'Accept';

  @override
  String get deny => 'Deny';

  @override
  String get viewRequest => 'View Request';

  @override
  String get receiverDashboard => 'You are monitoring someone';

  @override
  String get alertReceived =>
      '⚠️ ALERT: Your contact has not checked in for 48 hours!';

  @override
  String get monitoringActive => 'Monitoring Active';

  @override
  String get lastCheckedIn => 'Last checked in';

  @override
  String get noActiveConnections => 'No active monitoring connections';

  @override
  String get noActiveConnectionsHint =>
      'You will receive a notification when someone adds you as their emergency contact.';

  @override
  String get pendingRequest => 'You have a pending request';

  @override
  String get wantsToMonitor => 'wants you to monitor them';

  @override
  String get minutesAgo => 'minutes ago';

  @override
  String get hoursAgo => 'hours ago';

  @override
  String get daysAgo => 'days ago';

  @override
  String get never => 'Never';

  @override
  String get safetyAlert => 'Safety Alert';

  @override
  String get safetyAlertBody =>
      'Your monitored contact has not checked in for 48 hours. Please try to reach them.';

  @override
  String get ok => 'OK';

  @override
  String get monitoredBy => 'Monitored by';

  @override
  String get waitingFor => 'Waiting for';

  @override
  String get toAccept => 'to accept';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong. Please try again.';

  @override
  String get userNotFound =>
      'No user found with that phone number. They must register first.';

  @override
  String get cannotAddSelf =>
      'You cannot add yourself as an emergency contact.';

  @override
  String get fieldRequired => 'Required';

  @override
  String get includeCountryCode => 'Include country code (e.g. +91)';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get emergencyContactHint =>
      'Your emergency contact will receive an alert if you don\'t press ALIVE within 48 hours. They must already have the app installed.';

  @override
  String get wantsYouAsContact =>
      'wants you to be their emergency contact. You will receive an alert if they don\'t press ALIVE within 48 hours.';

  @override
  String get alertSentToContact =>
      '⚠️ Alert has been sent to your emergency contact!';

  @override
  String get dobHint => 'DD/MM/YYYY';

  @override
  String get relationshipHint => 'e.g. Father, Spouse, Friend';

  @override
  String get phoneHint => '+91XXXXXXXXXX';
}
