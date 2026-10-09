import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/validation/input_validators.dart';
import '../application/auth_providers.dart';
import '../domain/app_user.dart';
import '../domain/registration_options.dart';

class CompleteFanProfileScreen extends ConsumerStatefulWidget {
  const CompleteFanProfileScreen({super.key, required this.profile});

  final AppUser profile;

  @override
  ConsumerState<CompleteFanProfileScreen> createState() =>
      _CompleteFanProfileScreenState();
}

class _CompleteFanProfileScreenState
    extends ConsumerState<CompleteFanProfileScreen> {
  late final TextEditingController _nameController;
  final Set<String> _fandoms = {};
  String _badge = fanBadgeChoices.first;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile.displayName == 'New Explorer'
          ? ''
          : widget.profile.displayName,
    );
    _badge = fanBadgeChoices.contains(widget.profile.badge)
        ? widget.profile.badge
        : fanBadgeChoices.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_submitting) return;
    final nameError = InputValidators.required(
      _nameController.text,
      label: 'Display name',
    );
    if (nameError != null || _fandoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nameError ?? 'Select at least one fandom.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.profile.uid)
          .update({
            'displayName': _nameController.text.trim(),
            'selectedFandoms': _fandoms.toList(growable: false),
            'badge': _badge,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      // AuthGate switches to the Fan dashboard when the profile stream updates.
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your profile. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Complete your fan profile')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Choose your interests before entering Fandom Verse.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 20),
              const Text('Choose your fandoms'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fanFandomChoices.map((fandom) {
                  return FilterChip(
                    label: Text(fandom),
                    selected: _fandoms.contains(fandom),
                    onSelected: _submitting
                        ? null
                        : (selected) => setState(() {
                            if (selected) {
                              _fandoms.add(fandom);
                            } else {
                              _fandoms.remove(fandom);
                            }
                          }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _badge,
                decoration: const InputDecoration(labelText: 'Profile badge'),
                items: fanBadgeChoices
                    .map(
                      (badge) =>
                          DropdownMenuItem(value: badge, child: Text(badge)),
                    )
                    .toList(),
                onChanged: _submitting
                    ? null
                    : (value) => setState(() => _badge = value ?? _badge),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _save,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              ),
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => ref.read(authServiceProvider).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
