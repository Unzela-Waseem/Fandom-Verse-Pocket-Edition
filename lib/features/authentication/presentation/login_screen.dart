import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _googleEnabled =
      bool.fromEnvironment('ENABLE_GOOGLE_SIGN_IN', defaultValue: true);
  static const _appleEnabled =
      bool.fromEnvironment('ENABLE_APPLE_SIGN_IN', defaultValue: true);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  bool _acceptedFederatedTerms = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(authServiceProvider).signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyAuthError(e))));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_submitting) return;
    final err = InputValidators.email(_emailController.text);
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordReset(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset instructions sent.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyAuthError(e))));
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
            content: Text('Accept the Terms and Privacy notice to continue.')),
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
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyAuthError(e))));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06040F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Anime character background
          Image.asset('assets/auth_bg.jpg', fit: BoxFit.cover),
          // Dark gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x2206040F),
                  Color(0xAA06040F),
                  Color(0xFF06040F),
                ],
                stops: [0.0, 0.45, 0.75],
              ),
            ),
          ),
          // Scrollable content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Logo / badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                  color: const Color(0xFFA855F7)
                                      .withValues(alpha: 0.5)),
                              color: const Color(0xFFA855F7)
                                  .withValues(alpha: 0.12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome,
                                    color: Color(0xFFC77DFF), size: 13),
                                SizedBox(width: 6),
                                Text(
                                  'FANDOM VERSE',
                                  style: TextStyle(
                                    color: Color(0xFFC77DFF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.adminMode ? 'Admin Sign In' : 'Welcome Back',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sign in to continue your fandom journey',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 14),
                          ),
                          const SizedBox(height: 32),
                          // Glass card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  _AuthField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'your@email.com',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    autofillHints: const [
                                      AutofillHints.email
                                    ],
                                    validator: InputValidators.email,
                                  ),
                                  const SizedBox(height: 16),
                                  _AuthField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: 'Enter password',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    validator:
                                        InputValidators.loginPassword,
                                    onFieldSubmitted: (_) => _submit(),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() =>
                                          _obscurePassword =
                                              !_obscurePassword),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white38,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  if (!widget.adminMode)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _submitting
                                            ? null
                                            : _resetPassword,
                                        child: const Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                              color: Color(0xFFA855F7),
                                              fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  // Sign in button
                                  _PrimaryButton(
                                    label: 'Sign In',
                                    loading: _submitting,
                                    onTap: _submit,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!widget.adminMode) ...[
                            const SizedBox(height: 20),
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: Colors.white
                                            .withValues(alpha: 0.12))),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('or continue with',
                                      style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12)),
                                ),
                                Expanded(
                                    child: Divider(
                                        color: Colors.white
                                            .withValues(alpha: 0.12))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Terms checkbox
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _acceptedFederatedTerms,
                                    activeColor:
                                        const Color(0xFFA855F7),
                                    side: const BorderSide(
                                        color: Colors.white38),
                                    onChanged: _submitting
                                        ? null
                                        : (v) => setState(() =>
                                            _acceptedFederatedTerms =
                                                v ?? false),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'I accept the Terms and Privacy notice.',
                                    style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_googleEnabled)
                              _SocialButton(
                                label: 'Continue with Google',
                                icon: Icons.account_circle_outlined,
                                onTap: _submitting
                                    ? null
                                    : () => _signInWithProvider(
                                        google: true),
                              ),
                            if (_appleEnabled &&
                                (kIsWeb ||
                                    defaultTargetPlatform ==
                                        TargetPlatform.iOS ||
                                    defaultTargetPlatform ==
                                        TargetPlatform.android)) ...[
                              const SizedBox(height: 10),
                              kIsWeb
                                  ? _SocialButton(
                                      label: 'Continue with Apple',
                                      icon: Icons.apple,
                                      onTap: _submitting
                                          ? null
                                          : () => _signInWithProvider(
                                              google: false),
                                    )
                                  : SignInWithAppleButton(
                                      onPressed: () {
                                        if (!_submitting) {
                                          _signInWithProvider(
                                              google: false);
                                        }
                                      },
                                    ),
                            ],
                            const SizedBox(height: 24),
                            // Create account link
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: _submitting
                                      ? null
                                      : () => Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  const RegistrationScreen(),
                                            ),
                                          ),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Color(0xFFA855F7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                'Admin accounts must be provisioned through the trusted project process.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.white24, fontSize: 14),
        labelStyle:
            const TextStyle(color: Colors.white54, fontSize: 14),
        prefixIcon:
            Icon(icon, color: const Color(0xFFA855F7), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: Color(0xFFA855F7), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFEF5350)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFEF5350), width: 1.5),
        ),
        errorStyle:
            const TextStyle(color: Color(0xFFEF9A9A), fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.loading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}