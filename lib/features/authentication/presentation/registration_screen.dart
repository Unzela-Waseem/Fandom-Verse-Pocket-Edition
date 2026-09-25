import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/validation/input_validators.dart';
import '../application/auth_providers.dart';
import '../data/auth_service.dart';
import '../domain/registration_options.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const _googleEnabled = bool.fromEnvironment(
    'ENABLE_GOOGLE_SIGN_IN',
    defaultValue: true,
  );
  static const _appleEnabled = bool.fromEnvironment(
    'ENABLE_APPLE_SIGN_IN',
    defaultValue: true,
  );
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final Set<String> _selectedFandoms = {};
  String _badge = fanBadgeChoices.first;
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
    if (!_validateInterestsAndTerms()) return;
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

  bool _validateInterestsAndTerms() {
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
      return false;
    }
    return true;
  }

  Future<void> _registerWithProvider({required bool google}) async {
    if (_submitting) return;
    final nameError = InputValidators.required(
      _nameController.text,
      label: 'Display name',
    );
    if (nameError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(nameError)));
      return;
    }
    if (!_validateInterestsAndTerms()) return;
    setState(() => _submitting = true);
    try {
      final auth = ref.read(authServiceProvider);
      final fandoms = _selectedFandoms.toList(growable: false);
      if (google) {
        await auth.signInWithGoogle(
          displayName: _nameController.text,
          fandoms: fandoms,
          badge: _badge,
        );
      } else {
        await auth.signInWithApple(
          displayName: _nameController.text,
          fandoms: fandoms,
          badge: _badge,
        );
      }
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
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
                    children: fanFandomChoices.map((fandom) {
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
                    decoration: const InputDecoration(
                      labelText: 'Profile badge',
                    ),
                    items: fanBadgeChoices
                        .map(
                          (badge) => DropdownMenuItem(
                            value: badge,
                            child: Text(badge),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _badge = value ?? _badge),
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
                  if (_googleEnabled || _appleEnabled) ...[
                    const SizedBox(height: 20),
                    const Center(child: Text('Or register with')),
                    const SizedBox(height: 12),
                  ],
                  if (_googleEnabled)
                    OutlinedButton.icon(
                      onPressed: _submitting
                          ? null
                          : () => _registerWithProvider(google: true),
                      icon: const Icon(Icons.account_circle_outlined),
                      label: const Text('Continue with Google'),
                    ),
                  if (_appleEnabled &&
                      (kIsWeb ||
                          defaultTargetPlatform == TargetPlatform.iOS ||
                          defaultTargetPlatform == TargetPlatform.android)) ...[
                    const SizedBox(height: 10),
                    kIsWeb
                        ? OutlinedButton.icon(
                            onPressed: _submitting
                                ? null
                                : () => _registerWithProvider(google: false),
                            icon: const Icon(Icons.apple),
                            label: const Text('Continue with Apple'),
                          )
                        : SignInWithAppleButton(
                            onPressed: () {
                              if (!_submitting) {
                                _registerWithProvider(google: false);
                              }
                            },
                          ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
