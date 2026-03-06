// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Alive';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get login => 'लॉगिन';

  @override
  String get register => 'पंजीकरण करें';

  @override
  String get noAccount => 'खाता नहीं है? पंजीकरण करें';

  @override
  String get alreadyAccount => 'पहले से खाता है? लॉगिन करें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get passwordResetSent => 'पासवर्ड रीसेट ईमेल भेजा गया!';

  @override
  String get profileDetails => 'प्रोफ़ाइल विवरण';

  @override
  String get name => 'नाम';

  @override
  String get dateOfBirth => 'जन्म तिथि';

  @override
  String get pincode => 'पिनकोड';

  @override
  String get district => 'जिला';

  @override
  String get state => 'राज्य';

  @override
  String get country => 'देश';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get saveProfile => 'प्रोफ़ाइल सहेजें';

  @override
  String get emergencyContact => 'आपातकालीन संपर्क विवरण';

  @override
  String get contactName => 'संपर्क का नाम';

  @override
  String get relationship => 'संबंध';

  @override
  String get contactEmail => 'संपर्क ईमेल';

  @override
  String get sendRequest => 'अनुरोध भेजें';

  @override
  String get requestSentWaiting => 'अनुरोध भेजा गया – स्वीकृति की प्रतीक्षा है';

  @override
  String get requestRejected => 'अनुरोध अस्वीकृत – संपर्क पुनः दर्ज करें';

  @override
  String get changeContact => 'संपर्क बदलें';

  @override
  String get alive => 'जीवित';

  @override
  String get statusActive => 'स्थिति: सक्रिय';

  @override
  String get timeRemaining => 'शेष समय';

  @override
  String get alivePressed => '✓ आप जीवित हैं!';

  @override
  String get aliveButtonHint => 'हर 48 घंटे में दबाएं कि आप सुरक्षित हैं';

  @override
  String get invitationFrom => 'सुरक्षा निगरानी अनुरोध';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get deny => 'अस्वीकार करें';

  @override
  String get viewRequest => 'अनुरोध देखें';

  @override
  String get receiverDashboard => 'आप किसी की निगरानी कर रहे हैं';

  @override
  String get alertReceived =>
      '⚠️ अलर्ट: आपके संपर्क ने 48 घंटों में चेक-इन नहीं किया!';

  @override
  String get monitoringActive => 'निगरानी सक्रिय';

  @override
  String get lastCheckedIn => 'अंतिम बार चेक-इन';

  @override
  String get noActiveConnections => 'कोई सक्रिय निगरानी कनेक्शन नहीं';

  @override
  String get noActiveConnectionsHint =>
      'जब कोई आपको अपना आपातकालीन संपर्क जोड़ेगा तो आपको सूचना मिलेगी।';

  @override
  String get pendingRequest => 'आपके पास एक लंबित अनुरोध है';

  @override
  String get wantsToMonitor => 'चाहता है कि आप उनकी निगरानी करें';

  @override
  String get minutesAgo => 'मिनट पहले';

  @override
  String get hoursAgo => 'घंटे पहले';

  @override
  String get daysAgo => 'दिन पहले';

  @override
  String get never => 'कभी नहीं';

  @override
  String get safetyAlert => 'सुरक्षा अलर्ट';

  @override
  String get safetyAlertBody =>
      'आपके निगरानी संपर्क ने 48 घंटों में चेक-इन नहीं किया। कृपया उनसे संपर्क करने का प्रयास करें।';

  @override
  String get ok => 'ठीक है';

  @override
  String get monitoredBy => 'निगरानीकर्ता';

  @override
  String get waitingFor => 'प्रतीक्षा में';

  @override
  String get toAccept => 'स्वीकार करने के लिए';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get userNotFound =>
      'उस फ़ोन नंबर से कोई उपयोगकर्ता नहीं मिला। उन्हें पहले पंजीकरण करना होगा।';

  @override
  String get cannotAddSelf =>
      'आप स्वयं को आपातकालीन संपर्क के रूप में नहीं जोड़ सकते।';

  @override
  String get fieldRequired => 'आवश्यक है';

  @override
  String get includeCountryCode => 'देश कोड शामिल करें (जैसे +91)';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया';

  @override
  String get emergencyContactHint =>
      'अगर आप 48 घंटों में ALIVE नहीं दबाते हैं तो आपके आपातकालीन संपर्क को अलर्ट मिलेगा। उनके पास ऐप पहले से इंस्टॉल होना चाहिए।';

  @override
  String get wantsYouAsContact =>
      'चाहता है कि आप उनके आपातकालीन संपर्क बनें। अगर वे 48 घंटों में ALIVE नहीं दबाते हैं तो आपको अलर्ट मिलेगा।';

  @override
  String get alertSentToContact =>
      '⚠️ आपके आपातकालीन संपर्क को अलर्ट भेजा गया है!';

  @override
  String get dobHint => 'DD/MM/YYYY';

  @override
  String get relationshipHint => 'जैसे पिता, पति/पत्नी, दोस्त';

  @override
  String get phoneHint => '+91XXXXXXXXXX';
}
