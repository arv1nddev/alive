import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import 'emergency_contact_screen.dart';
import 'package:alive/generated/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _pincodeController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language') ?? 'en';
      await FirebaseService.saveUserProfile(
        name: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        pincode: _pincodeController.text.trim(),
        district: _districtController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        language: language,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const EmergencyContactScreen()));
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        debugPrint('--------err------\n$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.profileDetails,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(l10n.name, _nameController,
                  icon: Icons.person_outline),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildField(l10n.dateOfBirth, _dobController,
                      icon: Icons.calendar_today_outlined,
                      hint: 'DD/MM/YYYY'),
                ),
              ),
              const SizedBox(height: 16),
              _buildField(l10n.pincode, _pincodeController,
                  icon: Icons.pin_drop_outlined,
                  keyboard: TextInputType.number),
              const SizedBox(height: 16),
              _buildField(l10n.district, _districtController,
                  icon: Icons.location_city_outlined),
              const SizedBox(height: 16),
              _buildField(l10n.state, _stateController,
                  icon: Icons.map_outlined),
              const SizedBox(height: 16),
              _buildField(l10n.country, _countryController,
                  icon: Icons.public_outlined),
              const SizedBox(height: 32),
              _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF3D6EEA)))
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text(l10n.saveProfile),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    String? hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF3D6EEA)) : null,
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}