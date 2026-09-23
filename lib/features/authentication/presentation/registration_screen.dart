import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/validation/input_validators.dart';
import '../application/auth_providers.dart';
import '../data/auth_service.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const _fandoms = [
    'Anime',
    'Gaming',
    'Movies & TV',
    'Sci-Fi',
    'Comics',
    'Music',
  ];
  static const _badges = [
    'New Explorer',
    'Lore Keeper',
    'Collector',
    'Cosplayer',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final Set<String> _selectedFandoms = {};
  String _badge = _badges.first;
  bool _acceptedTerms = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    if (_selectedFandoms.isEmpty || !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedFandoms.isEmpty
                ? 'Select at least one fandom.'
                : 'Accept the Terms and Privacy notice to continue.',
          ),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(authServiceProvider)
          .registerFan(
            displayName: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            fandoms: _selectedFandoms.toList(growable: false),
            badge: _badge,
          );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyAuthError(error))));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create fan account')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    InputValidators.required(value, label: 'Display name'),
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: InputValidators.email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: InputValidators.password,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match.';
                  }
                  return InputValidators.password(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Choose your fandoms',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _fandoms.map((fandom) {
                  return FilterChip(
                    label: Text(fandom),
                    selected: _selectedFandoms.contains(fandom),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selectedFandoms.add(fandom);
                      } else {
                        _selectedFandoms.remove(fandom);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _badge,
                decoration: const InputDecoration(labelText: 'Profile badge'),
                items: _badges
                    .map(
                      (badge) =>
                          DropdownMenuItem(value: badge, child: Text(badge)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _badge = value ?? _badge),
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _acceptedTerms,
                onChanged: (value) =>
                    setState(() => _acceptedTerms = value ?? false),
                title: const Text('I accept the Terms and Privacy notice.'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _register,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
