import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'screens/startup_screen.dart';
import 'services/notification_service.dart';
import 'services/firebase_service.dart';
import 'package:alive/generated/app_localizations.dart';

// Need a navigator key to navigate without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) { 
    await Firebase.initializeApp(); 
  }
  await NotificationService.initialize();
  _handleIncomingMagicLink();
  runApp(const AliveApp());
}

  Future<void> _handleIncomingMagicLink() async {
    final appLinks = AppLinks();

    try {
      // App opened from cold start
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        await _processMagicLink(initialUri.toString());
      }
    } catch (e) {
      debugPrint('Initial link error: $e');
    }

    // App already running
    appLinks.uriLinkStream.listen((Uri uri) {
      _processMagicLink(uri.toString());
    });
  }

  Future<void> _processMagicLink(String link) async {
    if (!FirebaseService.isValidMagicLink(link)) return;

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('magic_link_email');
    if (email == null) return;

    try {
      await FirebaseService.signInWithMagicLink(
          email: email, emailLink: link);
      await prefs.remove('magic_link_email');

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StartupScreen()),
        (_) => false,
      );
    } catch (e) {
      debugPrint('Magic link sign in failed: $e');
    }
  }

class AliveApp extends StatefulWidget {
  const AliveApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    _AliveAppState? state = context.findAncestorStateOfType<_AliveAppState>();
    state?.setLocale(locale);
  }

  @override
  State<AliveApp> createState() => _AliveAppState();
}

class _AliveAppState extends State<AliveApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language');
    if (lang != null) {
      setState(() => _locale = Locale(lang));
    }
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, 
      title: 'Alive',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('hi')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D6EEA)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Color(0xFF1A1A2E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D6EEA),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF3D6EEA), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const StartupScreen(),
    );
  }
}