import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'startup_screen.dart';
import 'package:alive/generated/app_localizations.dart';

class EmergencyContactScreen extends StatefulWidget {
  final bool isReEntry;
  const EmergencyContactScreen({super.key, this.isReEntry = false});

  @override
  State<EmergencyContactScreen> createState() =>
      _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final contactPhone = _phoneController.text.trim();

      // Verify the receiver exists
      debugPrint('here1');
      final receiverId = await FirebaseService.findUserByPhone(contactPhone);
      debugPrint('here2');
      if (receiverId == null) {
        setState(() {
          _error = 'No user found with that phone number. They must register first.';
          _loading = false;
        });
        return;
      }

      if (receiverId == FirebaseService.currentUid) {
        setState(() {
          _error = 'You cannot add yourself as an emergency contact.';
          _loading = false;
        });
        return;
      }
      debugPrint('here3');
      if (widget.isReEntry) {
        await FirebaseService.updateConnection(
          receiverId: receiverId,
          contactName: _nameController.text.trim(),
          relationship: _relationshipController.text.trim(),
          contactPhone: contactPhone,
        );
      } else {

        debugPrint('here4');
        await FirebaseService.createConnection(
          receiverId: receiverId,
          contactName: _nameController.text.trim(),
          relationship: _relationshipController.text.trim(),
          contactPhone: contactPhone,
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const StartupScreen()));
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.emergencyContact,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D6EEA).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Your emergency contact will receive an alert if you don\'t press ALIVE within 48 hours. They must already have the app installed.',
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF3D6EEA), height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.contactName,
                  prefixIcon: const Icon(Icons.person_outline,
                      color: Color(0xFF3D6EEA)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationshipController,
                decoration: InputDecoration(
                  labelText: l10n.relationship,
                  hintText: 'e.g. Father, Spouse, Friend',
                  prefixIcon: const Icon(Icons.people_outline,
                      color: Color(0xFF3D6EEA)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.contactNumber,
                  hintText: '+91XXXXXXXXXX',
                  prefixIcon:
                      const Icon(Icons.phone, color: Color(0xFF3D6EEA)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.trim().startsWith('+')){
                    return 'Include country code (e.g. +91)';
                  }
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!,
                      style: TextStyle(
                          color: Colors.red.shade700, fontSize: 14)),
                ),
              ],
              const SizedBox(height: 32),
              _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF3D6EEA)))
                  : ElevatedButton(
                      onPressed: _sendRequest,
                      child: Text(l10n.sendRequest),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}