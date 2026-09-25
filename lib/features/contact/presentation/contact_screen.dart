import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/validation/input_validators.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to submit an inquiry.')),
      );
      return;
    }
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('inquiries')
          .add({
            'userId': user.uid,
            'email': user.email,
            'subject': _subjectController.text.trim(),
            'message': _messageController.text.trim(),
            'status': 'open',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      _subjectController.clear();
      _messageController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your inquiry was submitted.')),
        );
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Submission failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.mail_outline),
              title: Text('Project support'),
              subtitle: Text(
                'Use this secure form for questions and feedback.',
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.phone_outlined),
              title: Text('Phone Support'),
              subtitle: Text('+1 (555) 019-2023'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on_outlined),
              title: Text('Global Headquarters'),
              subtitle: Text('123 Multiverse Way, Nexus City, NY 10001'),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => launchUrl(Uri.parse('https://maps.google.com/?q=123+Multiverse+Way+New+York')),
              borderRadius: BorderRadius.circular(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E26),
                    image: DecorationImage(
                      image: AssetImage(AppAssets.multiverse),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 40, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'Open in Google Maps',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Send us an inquiry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              validator: (value) =>
                  InputValidators.required(value, label: 'Subject'),
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              validator: (value) {
                final requiredError = InputValidators.required(
                  value,
                  label: 'Message',
                );
                if (requiredError != null) return requiredError;
                return value!.trim().length < 10
                    ? 'Add a little more detail.'
                    : null;
              },
              minLines: 5,
              maxLines: 8,
              maxLength: 2000,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit inquiry'),
            ),
          ],
        ),
      ),
    );
  }
}
