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
  ConsumerState<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  static const _googleEnabled =
      bool.fromEnvironment('ENABLE_GOOGLE_SIGN_IN', defaultValue: true);
  static const _appleEnabled =
      bool.fromEnvironment('ENABLE_APPLE_SIGN_IN', defaultValue: true);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final Set<String> _selectedFandoms = {};
  String _badge = fanBadgeChoices.first;
  bool _acceptedTerms = false;
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    if (!_validateExtras()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(authServiceProvider).registerFan(
            displayName: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            fandoms: _selectedFandoms.toList(growable: false),
            badge: _badge,
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

  bool _validateExtras() {
    if (_selectedFandoms.isEmpty || !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedFandoms.isEmpty
              ? 'Select at least one fandom.'
              : 'Accept the Terms and Privacy notice to continue.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _registerWithProvider({required bool google}) async {
    if (_submitting) return;
    final nameErr = InputValidators.required(_nameController.text,
        label: 'Display name');
    if (nameErr != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(nameErr)));
      return;
    }
    if (!_validateExtras()) return;
    setState(() => _submitting = true);
    try {
      final auth = ref.read(authServiceProvider);
      final fandoms = _selectedFandoms.toList(growable: false);
      if (google) {
        await auth.signInWithGoogle(
            displayName: _nameController.text,
            fandoms: fandoms,
            badge: _badge);
      } else {
        await auth.signInWithApple(
            displayName: _nameController.text,
            fandoms: fandoms,
            badge: _badge);
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
          Image.asset('assets/auth_bg.jpg', fit: BoxFit.cover),
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
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white70, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
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
                                  'JOIN FANDOM VERSE',
                                  style: TextStyle(
                                    color: Color(0xFFC77DFF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Start your fandom adventure today',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 14),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _RegField(
                                    controller: _nameController,
                                    label: 'Display Name',
                                    hint: 'Your fan name',
                                    icon: Icons.person_outline_rounded,
                                    validator: (v) => InputValidators.required(
                                        v,
                                        label: 'Display name'),
                                  ),
                                  const SizedBox(height: 14),
                                  _RegField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'your@email.com',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: InputValidators.email,
                                  ),
                                  const SizedBox(height: 14),
                                  _RegField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: 'Create password',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    validator: InputValidators.password,
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white38,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _RegField(
                                    controller: _confirmController,
                                    label: 'Confirm Password',
                                    hint: 'Repeat password',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscureConfirm,
                                    validator: (v) {
                                      if (v != _passwordController.text) {
                                        return 'Passwords do not match.';
                                      }
                                      return InputValidators.password(v);
                                    },
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() =>
                                          _obscureConfirm = !_obscureConfirm),
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white38,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.favorite_outline,
                                        color: Color(0xFFA855F7), size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Choose Your Fandoms',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: fanFandomChoices.map((fandom) {
                                    final selected =
                                        _selectedFandoms.contains(fandom);
                                    return GestureDetector(
                                      onTap: () => setState(() {
                                        if (selected) {
                                          _selectedFandoms.remove(fandom);
                                        } else {
                                          _selectedFandoms.add(fandom);
                                        }
                                      }),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? const Color(0xFFA855F7)
                                                  .withValues(alpha: 0.25)
                                              : Colors.white
                                                  .withValues(alpha: 0.06),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                          border: Border.all(
                                            color: selected
                                                ? const Color(0xFFA855F7)
                                                : Colors.white
                                                    .withValues(alpha: 0.15),
                                            width: selected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          fandom,
                                          style: TextStyle(
                                            color: selected
                                                ? const Color(0xFFC77DFF)
                                                : Colors.white60,
                                            fontSize: 13,
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.12)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _badge,
                                      isExpanded: true,
                                      dropdownColor:
                                          const Color(0xFF1A1030),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white38),
                                      items: fanBadgeChoices
                                          .map((b) => DropdownMenuItem(
                                              value: b, child: Text(b)))
                                          .toList(),
                                      onChanged: (v) => setState(
                                          () => _badge = v ?? _badge),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  activeColor: const Color(0xFFA855F7),
                                  side: const BorderSide(
                                      color: Colors.white38),
                                  onChanged: (v) => setState(
                                      () => _acceptedTerms = v ?? false),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'I accept the Terms and Privacy notice.',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _RegPrimaryButton(
                            label: 'Create Account',
                            loading: _submitting,
                            onTap: _register,
                          ),
                          if (_googleEnabled || _appleEnabled) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: Colors.white
                                            .withValues(alpha: 0.12))),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('or register with',
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
                            const SizedBox(height: 14),
                          ],
                          if (_googleEnabled)
                            _RegSocialButton(
                              label: 'Continue with Google',
                              icon: Icons.account_circle_outlined,
                              onTap: _submitting
                                  ? null
                                  : () => _registerWithProvider(google: true),
                            ),
                          if (_appleEnabled &&
                              (kIsWeb ||
                                  defaultTargetPlatform == TargetPlatform.iOS ||
                                  defaultTargetPlatform ==
                                      TargetPlatform.android)) ...[
                            const SizedBox(height: 10),
                            kIsWeb
                                ? _RegSocialButton(
                                    label: 'Continue with Apple',
                                    icon: Icons.apple,
                                    onTap: _submitting
                                        ? null
                                        : () =>
                                            _registerWithProvider(google: false),
                                  )
                                : SignInWithAppleButton(
                                    onPressed: () {
                                      if (!_submitting) {
                                        _registerWithProvider(google: false);
                                      }
                                    },
                                  ),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFFA855F7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
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

// ── Local widgets ──────────────────────────────────────────────────────────

class _RegField extends StatelessWidget {
  const _RegField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFA855F7), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFA855F7), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF5350)),
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

class _RegPrimaryButton extends StatefulWidget {
  const _RegPrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  State<_RegPrimaryButton> createState() => _RegPrimaryButtonState();
}

class _RegPrimaryButtonState extends State<_RegPrimaryButton> {
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
          width: double.infinity,
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

class _RegSocialButton extends StatelessWidget {
  const _RegSocialButton({
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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