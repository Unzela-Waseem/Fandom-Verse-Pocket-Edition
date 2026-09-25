import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/validation/input_validators.dart';
import '../application/auth_providers.dart';
import '../data/auth_service.dart';
import 'registration_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.adminMode});

  final bool adminMode;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _googleEnabled = bool.fromEnvironment(
    'ENABLE_GOOGLE_SIGN_IN',
    defaultValue: true,
  );
  static const _appleEnabled = bool.fromEnvironment('ENABLE_APPLE_SIGN_IN');
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  bool _acceptedFederatedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(authServiceProvider)
          .signIn(
            email: _emailController.text,
            password: _passwordController.text,
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

  Future<void> _resetPassword() async {
    if (_submitting) return;
    final emailError = InputValidators.email(_emailController.text);
    if (emailError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordReset(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset instructions were sent.'),
          ),
        );
      }
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

  Future<void> _signInWithProvider({required bool google}) async {
    if (_submitting) return;
    if (!_acceptedFederatedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accept the Terms and Privacy notice to continue.'),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final auth = ref.read(authServiceProvider);
      if (google) {
        await auth.signInWithGoogle();
      } else {
        await auth.signInWithApple();
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
      appBar: AppBar(
        title: Text(widget.adminMode ? 'Admin sign in' : 'Welcome back'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Icon(
                      widget.adminMode
                          ? Icons.shield_outlined
                          : Icons.favorite_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: InputValidators.email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      validator: InputValidators.loginPassword,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                    if (!widget.adminMode) ...[
                      TextButton(
                        onPressed: _submitting ? null : _resetPassword,
                        child: const Text('Forgot password?'),
                      ),
                      const Divider(height: 32),
                      OutlinedButton.icon(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const RegistrationScreen(),
                                ),
                              ),
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: const Text('Create fan account'),
                      ),
                      if (_googleEnabled || _appleEnabled) ...[
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _acceptedFederatedTerms,
                          onChanged: _submitting
                              ? null
                              : (value) => setState(
                                  () =>
                                      _acceptedFederatedTerms = value ?? false,
                                ),
                          title: const Text(
                            'I accept the Terms and Privacy notice.',
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                      if (_googleEnabled) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _submitting
                              ? null
                              : () => _signInWithProvider(google: true),
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Text('Continue with Google'),
                        ),
                      ],
                      if (_appleEnabled &&
                          (kIsWeb ||
                              defaultTargetPlatform == TargetPlatform.iOS ||
                              defaultTargetPlatform ==
                                  TargetPlatform.android)) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _submitting
                              ? null
                              : () => _signInWithProvider(google: false),
                          icon: const Icon(Icons.apple),
                          label: const Text('Continue with Apple'),
                        ),
                      ],
                    ] else
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Admin accounts must be provisioned through the trusted project process.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
