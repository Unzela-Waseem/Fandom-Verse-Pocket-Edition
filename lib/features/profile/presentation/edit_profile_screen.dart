import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/validation/input_validators.dart';
import '../../authentication/domain/app_user.dart';
import '../data/avatar_upload_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final AppUser profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _avatarUploadEnabled = bool.fromEnvironment(
    'ENABLE_AVATAR_UPLOAD',
  );
  static const _availableFandoms = [
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
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late Set<String> _fandoms;
  late String _badge;
  bool _saving = false;
  bool _uploading = false;
  double _uploadProgress = 0;
  String? _avatarUrl;
  final _avatarService = AvatarUploadService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _fandoms = widget.profile.selectedFandoms.toSet();
    _badge = _badges.contains(widget.profile.badge)
        ? widget.profile.badge
        : _badges.first;
    _avatarUrl = widget.profile.avatarUrl;
  }

  @override
  void dispose() {
    _avatarService.cancel();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_fandoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one fandom.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.profile.uid)
          .update({
            'displayName': _nameController.text.trim(),
            'bio': _bioController.text.trim(),
            'selectedFandoms': _fandoms.toList(growable: false),
            'badge': _badge,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Profile update failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _uploadAvatar() async {
    if (_uploading) return;
    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });
    try {
      final previousUrl = _avatarUrl;
      final newUrl = await _avatarService.pickAndUpload(
        uid: widget.profile.uid,
        onProgress: (progress) {
          if (mounted) setState(() => _uploadProgress = progress);
        },
      );
      if (newUrl == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.profile.uid)
          .update({
            'avatarUrl': newUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) setState(() => _avatarUrl = newUrl);
      await _avatarService.deletePrevious(
        uid: widget.profile.uid,
        url: previousUrl,
      );
    } catch (error) {
      if (mounted) {
        final message = error is AvatarUploadException
            ? error.message
            : error is FirebaseException
            ? error.code == 'canceled'
                  ? 'Avatar upload canceled.'
                  : 'Avatar upload is unavailable. Check Storage setup and try again.'
            : 'Avatar upload failed. Please try again.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validAvatarUrl =
        _avatarUrl != null && Uri.tryParse(_avatarUrl!)?.scheme == 'https';
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundImage: validAvatarUrl
                    ? NetworkImage(_avatarUrl!)
                    : null,
                child: !validAvatarUrl
                    ? const Icon(Icons.person, size: 42)
                    : null,
              ),
            ),
            if (_avatarUploadEnabled &&
                !kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS)) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _uploading ? null : _uploadAvatar,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Choose profile image'),
              ),
              if (_uploading) ...[
                LinearProgressIndicator(value: _uploadProgress),
                TextButton(
                  onPressed: _avatarService.cancel,
                  child: const Text('Cancel upload'),
                ),
              ],
            ] else ...[
              const SizedBox(height: 8),
              const Text(
                'Image uploads will be available after project Storage setup.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              validator: (value) =>
                  InputValidators.required(value, label: 'Display name'),
              maxLength: 60,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bioController,
              minLines: 3,
              maxLines: 5,
              maxLength: 300,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            const SizedBox(height: 18),
            const Text(
              'Favorite fandoms',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableFandoms.map((fandom) {
                return FilterChip(
                  label: Text(fandom),
                  selected: _fandoms.contains(fandom),
                  onSelected: (selected) => setState(
                    () => selected
                        ? _fandoms.add(fandom)
                        : _fandoms.remove(fandom),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _saving || _uploading ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
