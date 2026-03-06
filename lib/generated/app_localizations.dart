import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Alive'**
  String get appName;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get noAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent!'**
  String get passwordResetSent;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile Details'**
  String get profileDetails;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Details'**
  String get emergencyContact;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Email'**
  String get contactEmail;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @requestSentWaiting.
  ///
  /// In en, this message translates to:
  /// **'Request Sent – Waiting for Acceptance'**
  String get requestSentWaiting;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request Rejected – Enter Contact Again'**
  String get requestRejected;

  /// No description provided for @changeContact.
  ///
  /// In en, this message translates to:
  /// **'Change Contact'**
  String get changeContact;

  /// No description provided for @alive.
  ///
  /// In en, this message translates to:
  /// **'ALIVE'**
  String get alive;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Status: ACTIVE'**
  String get statusActive;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// No description provided for @alivePressed.
  ///
  /// In en, this message translates to:
  /// **'✓ You\'re marked as Alive!'**
  String get alivePressed;

  /// No description provided for @aliveButtonHint.
  ///
  /// In en, this message translates to:
  /// **'Press every 48 hours to confirm you are safe'**
  String get aliveButtonHint;

  /// No description provided for @invitationFrom.
  ///
  /// In en, this message translates to:
  /// **'Safety monitoring request from'**
  String get invitationFrom;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @viewRequest.
  ///
  /// In en, this message translates to:
  /// **'View Request'**
  String get viewRequest;

  /// No description provided for @receiverDashboard.
  ///
  /// In en, this message translates to:
  /// **'You are monitoring someone'**
  String get receiverDashboard;

  /// No description provided for @alertReceived.
  ///
  /// In en, this message translates to:
  /// **'⚠️ ALERT: Your contact has not checked in for 48 hours!'**
  String get alertReceived;

  /// No description provided for @monitoringActive.
  ///
  /// In en, this message translates to:
  /// **'Monitoring Active'**
  String get monitoringActive;

  /// No description provided for @lastCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Last checked in'**
  String get lastCheckedIn;

  /// No description provided for @noActiveConnections.
  ///
  /// In en, this message translates to:
  /// **'No active monitoring connections'**
  String get noActiveConnections;

  /// No description provided for @noActiveConnectionsHint.
  ///
  /// In en, this message translates to:
  /// **'You will receive a notification when someone adds you as their emergency contact.'**
  String get noActiveConnectionsHint;

  /// No description provided for @pendingRequest.
  ///
  /// In en, this message translates to:
  /// **'You have a pending request'**
  String get pendingRequest;

  /// No description provided for @wantsToMonitor.
  ///
  /// In en, this message translates to:
  /// **'wants you to monitor them'**
  String get wantsToMonitor;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @safetyAlert.
  ///
  /// In en, this message translates to:
  /// **'Safety Alert'**
  String get safetyAlert;

  /// No description provided for @safetyAlertBody.
  ///
  /// In en, this message translates to:
  /// **'Your monitored contact has not checked in for 48 hours. Please try to reach them.'**
  String get safetyAlertBody;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @monitoredBy.
  ///
  /// In en, this message translates to:
  /// **'Monitored by'**
  String get monitoredBy;

  /// No description provided for @waitingFor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for'**
  String get waitingFor;

  /// No description provided for @toAccept.
  ///
  /// In en, this message translates to:
  /// **'to accept'**
  String get toAccept;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with that phone number. They must register first.'**
  String get userNotFound;

  /// No description provided for @cannotAddSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot add yourself as an emergency contact.'**
  String get cannotAddSelf;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @includeCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Include country code (e.g. +91)'**
  String get includeCountryCode;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @emergencyContactHint.
  ///
  /// In en, this message translates to:
  /// **'Your emergency contact will receive an alert if you don\'t press ALIVE within 48 hours. They must already have the app installed.'**
  String get emergencyContactHint;

  /// No description provided for @wantsYouAsContact.
  ///
  /// In en, this message translates to:
  /// **'wants you to be their emergency contact. You will receive an alert if they don\'t press ALIVE within 48 hours.'**
  String get wantsYouAsContact;

  /// No description provided for @alertSentToContact.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Alert has been sent to your emergency contact!'**
  String get alertSentToContact;

  /// No description provided for @dobHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get dobHint;

  /// No description provided for @relationshipHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Father, Spouse, Friend'**
  String get relationshipHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+91XXXXXXXXXX'**
  String get phoneHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
