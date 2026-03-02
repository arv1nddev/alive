import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'otp_screen.dart';

class LanguageScreen extends StatelessWidget {
  LanguageScreen({super.key});

  Future<void> _selectLanguage(BuildContext context, String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    if (!context.mounted) return;
    AliveApp.setLocale(context, Locale(langCode));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OtpScreen()));
  }

  static const _languages = {
    'en': 'English',
    'hi': 'हिंदी',
  };

  final languageOptions = _languages.entries.map((e) => DropdownMenuItem(
    value: e.key,
    child: Text(
      e.value,
      style: const TextStyle(fontSize: 18, color: Color(0xFF1A1A2E)),
    ),
  )).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ALIVE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D6EEA),
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '48-Hour Safety Monitor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 64),
              const Text(
                'Select Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 32),
              
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3D6EEA), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3D6EEA), width: 2),
                  ),
                ),
                hint: const Text(
                  'Choose a language...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D6EEA),
                  ),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF3D6EEA)),
                items: languageOptions,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _selectLanguage(context, newValue);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
