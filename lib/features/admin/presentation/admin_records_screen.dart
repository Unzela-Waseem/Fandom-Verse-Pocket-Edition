import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'admin_collection_screen.dart';

// ── Users Screen ──────────────────────────────────────────────────────────────

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _query = '';
  String _roleFilter = 'all'; // 'all' | 'fan' | 'admin'
  String? _busyId;

  static const _pageSize = 30;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _users = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _loading = false;
  bool _hasMore = true;

  FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      final snapshot = await query.get();
      final docs = snapshot.docs;
      if (docs.length < _pageSize) _hasMore = false;
      if (docs.isNotEmpty) _lastDocument = docs.last;
      _users.addAll(docs);
    } catch (_) {
      // handled visually
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    _users.clear();
    _lastDocument = null;
    _hasMore = true;
    await _loadPage();
  }

  Future<void> _setStatus(
    QueryDocumentSnapshot<Map<String, dynamic>> user,
    bool active,
  ) async {
    if (!active) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disable this account?'),
          content: const Text(
            'The user will lose access to protected features until re-enabled.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Disable'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() => _busyId = user.id);
    try {
      await _functions.httpsCallable('setUserStatus').call(<String, dynamic>{
        'uid': user.id,
        'enabled': active,
      });
      await _refresh();
    } on FirebaseFunctionsException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Status update failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _deleteUser(
    QueryDocumentSnapshot<Map<String, dynamic>> user,
  ) async {
    final data = user.data();
    final name = data['displayName'] as String? ?? 'this user';
    final email = data['email'] as String? ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently delete user?'),
        content: Text(
          'This will permanently remove $name ($email) from Firebase '
          'Authentication and Firestore. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busyId = user.id);
    try {
      await _functions.httpsCallable('deleteAuthUser').call(<String, dynamic>{
        'uid': user.id,
      });
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name was permanently deleted.')),
        );
      }
    } on FirebaseFunctionsException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Deletion failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final queryLower = _query.toLowerCase().trim();
    final filtered = _users.where((doc) {
      final data = doc.data();
      final haystack = '${data['displayName'] ?? ''} ${data['email'] ?? ''}'
          .toLowerCase();
      final matchesQuery = queryLower.isEmpty || haystack.contains(queryLower);
      final matchesRole =
          _roleFilter == 'all' ||
          (data['role'] as String? ?? 'fan') == _roleFilter;
      return matchesQuery && matchesRole;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog<void>(
            context: context,
            builder: (_) => const _AdminUserProvisioningDialog(),
          );
          await _refresh();
        },
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add User'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  labelText: 'Search name or email',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text('Role:'),
                  const SizedBox(width: 8),
                  ..._buildRoleChips(),
                ],
              ),
            ),
            Expanded(
              child: _loading && _users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? const Center(child: Text('No matching users.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextButton.icon(
                              onPressed: _loading ? null : _loadPage,
                              icon: _loading
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.expand_more),
                              label: const Text('Load more'),
                            ),
                          );
                        }
                        final user = filtered[index];
                        final data = user.data();
                        final active =
                            (data['accountStatus'] ?? 'active') == 'active';
                        final role = data['role'] as String? ?? 'fan';
                        final isAdmin = role == 'admin';
                        final avatarUrl = data['avatarUrl'] as String?;
                        final fandoms = List<String>.from(
                          data['selectedFandoms'] as List? ?? const [],
                        );
                        final createdAt = data['createdAt'] as Timestamp?;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? Text(
                                      (data['displayName'] as String? ?? 'U')
                                              .isNotEmpty
                                          ? (data['displayName'] as String)[0]
                                                .toUpperCase()
                                          : 'U',
                                    )
                                  : null,
                            ),
                            title: Text(
                              data['displayName'] as String? ?? 'Unnamed',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${data['email'] ?? ''}  ·  $role'
                              '${active ? '' : '  ·  DISABLED'}',
                              style: TextStyle(
                                color: active
                                    ? null
                                    : Theme.of(context).colorScheme.error,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (data['bio'] != null &&
                                        (data['bio'] as String).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Text(
                                          data['bio'] as String,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    if (fandoms.isNotEmpty)
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: fandoms
                                            .map(
                                              (f) => Chip(
                                                label: Text(
                                                  f,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                padding: EdgeInsets.zero,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'UID: ${user.id}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    if (createdAt != null)
                                      Text(
                                        'Joined: ${_fmt(createdAt)}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    const Divider(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                            ),
                                            label: const Text('Edit profile'),
                                            onPressed: () => showDialog<void>(
                                              context: context,
                                              builder: (_) =>
                                                  _AdminUserEditor(user: user),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (!isAdmin)
                                          Expanded(
                                            child: SwitchListTile(
                                              title: const Text('Active'),
                                              value: active,
                                              onChanged: _busyId != null
                                                  ? null
                                                  : (value) =>
                                                        _setStatus(user, value),
                                              contentPadding: EdgeInsets.zero,
                                              dense: true,
                                            ),
                                          ),
                                        IconButton(
                                          tooltip: 'Delete user',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          onPressed: _busyId != null
                                              ? null
                                              : () => _deleteUser(user),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoleChips() {
    return ['all', 'fan', 'admin'].map((role) {
      final selected = _roleFilter == role;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(role == 'all' ? 'All' : role.capitalize()),
          selected: selected,
          onSelected: (_) => setState(() => _roleFilter = role),
        ),
      );
    }).toList();
  }

  String _fmt(Timestamp ts) {
    final dt = ts.toDate().toLocal();
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

// ── User Editor Dialog ────────────────────────────────────────────────────────

class _AdminUserEditor extends StatefulWidget {
  const _AdminUserEditor({required this.user});

  final QueryDocumentSnapshot<Map<String, dynamic>> user;

  @override
  State<_AdminUserEditor> createState() => _AdminUserEditorState();
}

class _AdminUserEditorState extends State<_AdminUserEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _badge;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.user.data();
    _name = TextEditingController(text: data['displayName'] as String? ?? '');
    _bio = TextEditingController(text: data['bio'] as String? ?? '');
    _badge = TextEditingController(text: data['badge'] as String? ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _badge.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.update(widget.user.reference, {
        'displayName': _name.text.trim(),
        'bio': _bio.text.trim(),
        'badge': _badge.text.trim().isEmpty
            ? 'New Explorer'
            : _badge.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser!.uid,
      });
      addAdminAudit(
        batch,
        action: 'edit-profile',
        collection: 'users',
        recordId: widget.user.id,
      );
      await batch.commit();
      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'User update failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit user profile'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Display name'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Display name is required.'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bio,
                minLines: 2,
                maxLines: 4,
                maxLength: 300,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _badge,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Badge (e.g. New Explorer, Lore Master)',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
      ),
    ],
  );
}

// ── User Provisioning Dialog ──────────────────────────────────────────────────
// User provisioning is intentionally performed by a trusted Cloud Function.
// Firebase Auth administration and admin custom claims must never be created
// by an untrusted Flutter client.

class _AdminUserProvisioningDialog extends StatefulWidget {
  const _AdminUserProvisioningDialog();

  @override
  State<_AdminUserProvisioningDialog> createState() =>
      _AdminUserProvisioningDialogState();
}

class _AdminUserProvisioningDialogState
    extends State<_AdminUserProvisioningDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'fan';
  bool _saving = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await FirebaseFunctions.instanceFor(
        region: 'asia-south1',
      ).httpsCallable('provisionUser').call(<String, dynamic>{
        'displayName': _name.text.trim(),
        'email': _email.text.trim().toLowerCase(),
        'password': _password.text,
        'role': _role,
      });
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_role.capitalize()} account created.')),
      );
    } on FirebaseFunctionsException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message ?? 'Provisioning failed.');
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              'Secure provisioning is unavailable. Deploy the trusted Firebase Functions first.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create New User'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withAlpha(120),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Creates a real Firebase Auth account + Firestore profile. '
                        'User can log in immediately.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Required.' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return 'Email is required.';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v!.trim())) {
                    return 'Invalid email format.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: _role == 'admin'
                      ? 'Password (min 12 chars)'
                      : 'Password (min 8 chars)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  final min = _role == 'admin' ? 12 : 8;
                  if ((v?.length ?? 0) < min) {
                    return 'Password must be at least $min characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'fan', child: Text('Fan')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'fan'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _saving ? null : _submit,
        icon: _saving
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.person_add_outlined, size: 18),
        label: Text(_saving ? 'Creating…' : 'Create Account'),
      ),
    ],
  );
}

// ── Discussion Moderation ─────────────────────────────────────────────────────

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  String _query = '';

  static const _pageSize = 30;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('discussions')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      final snapshot = await query.get();
      final list = snapshot.docs;
      if (list.length < _pageSize) _hasMore = false;
      if (list.isNotEmpty) _lastDocument = list.last;
      _docs.addAll(list);
    } catch (_) {
      // show existing
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    _docs.clear();
    _lastDocument = null;
    _hasMore = true;
    await _loadPage();
  }

  Future<void> _delete(
    QueryDocumentSnapshot<Map<String, dynamic>> record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this discussion?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.delete(record.reference);
      addAdminAudit(
        batch,
        action: 'moderate:delete',
        collection: 'discussions',
        recordId: record.id,
      );
      await batch.commit();
      await _refresh();
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Removal failed.')),
        );
      }
    }
  }

  Future<void> _toggleHide(
    QueryDocumentSnapshot<Map<String, dynamic>> record,
    bool hidden,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.update(record.reference, {
        'hidden': hidden,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      addAdminAudit(
        batch,
        action: hidden ? 'moderate:hide' : 'moderate:unhide',
        collection: 'discussions',
        recordId: record.id,
      );
      await batch.commit();
      await _refresh();
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Update failed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final queryLower = _query.toLowerCase().trim();
    final filtered = queryLower.isEmpty
        ? _docs
        : _docs.where((doc) {
            final data = doc.data();
            final text =
                '${data['title'] ?? ''} ${data['body'] ?? ''} ${data['authorName'] ?? ''}'
                    .toLowerCase();
            return text.contains(queryLower);
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Discussion moderation')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search title, body or author',
                ),
              ),
            ),
            Expanded(
              child: _loading && _docs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? const Center(child: Text('No discussions to moderate.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filtered.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextButton.icon(
                              onPressed: _loading ? null : _loadPage,
                              icon: _loading
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.expand_more),
                              label: const Text('Load more'),
                            ),
                          );
                        }
                        final record = filtered[index];
                        final data = record.data();
                        final isHidden = data['hidden'] == true;
                        final createdAt = data['createdAt'] as Timestamp?;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: Icon(
                              isHidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.forum_outlined,
                              color: isHidden
                                  ? Theme.of(context).colorScheme.error
                                  : null,
                            ),
                            title: Text(
                              data['title'] as String? ?? 'Untitled',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${data['authorName'] ?? 'Unknown'}'
                              '${createdAt != null ? '  ·  ${_fmtDate(createdAt)}' : ''}'
                              '${isHidden ? '  ·  HIDDEN' : ''}',
                              style: TextStyle(
                                color: isHidden
                                    ? Theme.of(context).colorScheme.error
                                    : null,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['body'] as String? ?? '',
                                      style: const TextStyle(height: 1.5),
                                    ),
                                    if (data['rating'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.star_outlined,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text('Rating: ${data['rating']}'),
                                          ],
                                        ),
                                      ),
                                    Text(
                                      'User ID: ${data['userId'] ?? 'unknown'}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            icon: Icon(
                                              isHidden
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              size: 16,
                                            ),
                                            label: Text(
                                              isHidden ? 'Unhide' : 'Hide',
                                            ),
                                            onPressed: () =>
                                                _toggleHide(record, !isHidden),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: FilledButton.icon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                              foregroundColor: Theme.of(
                                                context,
                                              ).colorScheme.onError,
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                            ),
                                            label: const Text('Delete'),
                                            onPressed: () => _delete(record),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(Timestamp ts) {
    final dt = ts.toDate().toLocal();
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

// ── Inquiries Screen ──────────────────────────────────────────────────────────

class AdminInquiriesScreen extends StatefulWidget {
  const AdminInquiriesScreen({super.key});

  @override
  State<AdminInquiriesScreen> createState() => _AdminInquiriesScreenState();
}

class _AdminInquiriesScreenState extends State<AdminInquiriesScreen> {
  String _query = '';
  String _statusFilter = 'all'; // 'all' | 'open' | 'resolved'

  static const _pageSize = 30;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collectionGroup('inquiries')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      final snapshot = await query.get();
      final list = snapshot.docs;
      if (list.length < _pageSize) _hasMore = false;
      if (list.isNotEmpty) _lastDocument = list.last;
      _docs.addAll(list);
    } catch (_) {
      // show existing
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    _docs.clear();
    _lastDocument = null;
    _hasMore = true;
    await _loadPage();
  }

  Future<void> _updateStatus(
    QueryDocumentSnapshot<Map<String, dynamic>> inquiry,
    String status,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.update(inquiry.reference, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      addAdminAudit(
        batch,
        action: 'status:$status',
        collection: 'inquiries',
        recordId: inquiry.id,
      );
      await batch.commit();
      await _refresh();
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Update failed.')),
        );
      }
    }
  }

  Future<void> _delete(
    QueryDocumentSnapshot<Map<String, dynamic>> inquiry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this inquiry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.delete(inquiry.reference);
      addAdminAudit(
        batch,
        action: 'delete',
        collection: 'inquiries',
        recordId: inquiry.id,
      );
      await batch.commit();
      await _refresh();
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Delete failed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final queryLower = _query.toLowerCase().trim();
    final filtered = _docs.where((doc) {
      final data = doc.data();
      final matchesQuery =
          queryLower.isEmpty ||
          '${data['subject'] ?? ''} ${data['email'] ?? ''} ${data['message'] ?? ''}'
              .toLowerCase()
              .contains(queryLower);
      final status = data['status'] as String? ?? 'open';
      final matchesStatus = _statusFilter == 'all' || status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Inquiries')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search subject, email or message',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text('Status:'),
                  const SizedBox(width: 8),
                  ..._buildStatusChips(),
                ],
              ),
            ),
            Expanded(
              child: _loading && _docs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? const Center(child: Text('No inquiries found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextButton.icon(
                              onPressed: _loading ? null : _loadPage,
                              icon: _loading
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.expand_more),
                              label: const Text('Load more'),
                            ),
                          );
                        }
                        final inquiry = filtered[index];
                        final data = inquiry.data();
                        final status = data['status'] as String? ?? 'open';
                        final createdAt = data['createdAt'] as Timestamp?;
                        final isResolved = status == 'resolved';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: Icon(
                              isResolved
                                  ? Icons.check_circle_outline
                                  : Icons.mail_outline,
                              color: isResolved
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              data['subject'] as String? ?? 'No subject',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${data['email'] ?? 'Unknown email'}'
                              '${createdAt != null ? '  ·  ${_fmtDateTime(createdAt)}' : ''}'
                              '  ·  $status',
                              style: TextStyle(
                                color: isResolved ? Colors.green : null,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['message'] as String? ?? '',
                                      style: const TextStyle(height: 1.5),
                                    ),
                                    // Admin note section
                                    if (data['adminNote'] != null &&
                                        (data['adminNote'] as String)
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiaryContainer
                                              .withAlpha(180),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.note_outlined,
                                                  size: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onTertiaryContainer,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Admin Note',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onTertiaryContainer,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              data['adminNote'] as String,
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.4,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onTertiaryContainer,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const Divider(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: isResolved
                                                ? () => _updateStatus(
                                                    inquiry,
                                                    'open',
                                                  )
                                                : () => _updateStatus(
                                                    inquiry,
                                                    'resolved',
                                                  ),
                                            child: Text(
                                              isResolved
                                                  ? 'Reopen'
                                                  : 'Mark resolved',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          tooltip: 'Add / edit admin note',
                                          icon: const Icon(
                                            Icons.note_add_outlined,
                                          ),
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                          onPressed: () async {
                                            await showDialog<void>(
                                              context: context,
                                              builder: (_) =>
                                                  _AdminInquiryNoteDialog(
                                                    inquiry: inquiry,
                                                    existing:
                                                        data['adminNote']
                                                            as String? ??
                                                        '',
                                                  ),
                                            );
                                            await _refresh();
                                          },
                                        ),
                                        IconButton(
                                          tooltip: 'Delete inquiry',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          onPressed: () => _delete(inquiry),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusChips() {
    return ['all', 'open', 'resolved'].map((s) {
      final selected = _statusFilter == s;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          label: Text(s == 'all' ? 'All' : _capitalize(s)),
          selected: selected,
          onSelected: (_) => setState(() => _statusFilter = s),
        ),
      );
    }).toList();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _fmtDateTime(Timestamp ts) {
    final dt = ts.toDate().toLocal();
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

// ── Admin Inquiry Note Dialog ───────────────────────────────────────────────────────────────

class _AdminInquiryNoteDialog extends StatefulWidget {
  const _AdminInquiryNoteDialog({
    required this.inquiry,
    required this.existing,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> inquiry;
  final String existing;

  @override
  State<_AdminInquiryNoteDialog> createState() =>
      _AdminInquiryNoteDialogState();
}

class _AdminInquiryNoteDialogState extends State<_AdminInquiryNoteDialog> {
  late final TextEditingController _noteCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.existing);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.update(widget.inquiry.reference, {
        'adminNote': _noteCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      addAdminAudit(
        batch,
        action: 'note:update',
        collection: 'inquiries',
        recordId: widget.inquiry.id,
      );
      await batch.commit();
      if (mounted) Navigator.pop(context);
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Save failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Admin note'),
    content: SizedBox(
      width: 480,
      child: TextField(
        controller: _noteCtrl,
        minLines: 3,
        maxLines: 6,
        maxLength: 500,
        decoration: const InputDecoration(
          labelText: 'Internal note (not visible to user)',
          hintText: 'Add context, follow-up actions…',
          border: OutlineInputBorder(),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save note'),
      ),
    ],
  );
}

// ── Audit Logs Screen ─────────────────────────────────────────────────────────

class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  String _query = '';

  static const _pageSize = 40;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('audit_logs')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      final snapshot = await query.get();
      final list = snapshot.docs;
      if (list.length < _pageSize) _hasMore = false;
      if (list.isNotEmpty) _lastDocument = list.last;
      _docs.addAll(list);
    } catch (_) {
      // show existing
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    _docs.clear();
    _lastDocument = null;
    _hasMore = true;
    await _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    final queryLower = _query.toLowerCase().trim();
    final filtered = queryLower.isEmpty
        ? _docs
        : _docs.where((doc) {
            final data = doc.data();
            final text =
                '${data['action'] ?? ''} ${data['collection'] ?? ''} ${data['actorEmail'] ?? ''}'
                    .toLowerCase();
            return text.contains(queryLower);
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Audit logs')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search action, collection or actor',
                ),
              ),
            ),
            Expanded(
              child: _loading && _docs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? const Center(child: Text('No audit logs found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filtered.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextButton.icon(
                              onPressed: _loading ? null : _loadPage,
                              icon: _loading
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.expand_more),
                              label: const Text('Load more'),
                            ),
                          );
                        }
                        final log = filtered[index];
                        final data = log.data();
                        final createdAt = data['createdAt'] as Timestamp?;
                        final action = data['action'] as String? ?? '';
                        final isDelete =
                            action.startsWith('delete') ||
                            action.startsWith('moderate:delete') ||
                            action.startsWith('disable');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            leading: Icon(
                              isDelete
                                  ? Icons.delete_outline
                                  : action.startsWith('create')
                                  ? Icons.add_circle_outline
                                  : Icons.edit_outlined,
                              color: isDelete
                                  ? Theme.of(context).colorScheme.error
                                  : action.startsWith('create')
                                  ? Colors.green
                                  : null,
                              size: 20,
                            ),
                            title: Text(
                              action,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              '${data['collection'] ?? ''}  ·  ${data['actorEmail'] ?? ''}'
                              '${createdAt != null ? '\n${_fmtDateTime(createdAt)}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            isThreeLine: createdAt != null,
                            trailing: Text(
                              data['recordId'] != null
                                  ? (data['recordId'] as String).length > 8
                                        ? '…${(data['recordId'] as String).substring((data['recordId'] as String).length - 6)}'
                                        : data['recordId'] as String
                                  : '',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDateTime(Timestamp ts) {
    final dt = ts.toDate().toLocal();
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}:${_p(dt.second)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

// ── User Provisioning Screen ──────────────────────────────────────────────────
// New users (fan or admin) must be created via the trusted server-side CLI tool
// (admin-tools/manage-users.mjs) because Firebase Auth user creation requires
// the Admin SDK, which must never run inside an untrusted mobile client.
// This screen surfaces the exact commands needed and shows existing users so
// the admin can copy UIDs for the disable/enable/delete commands.

class AdminUserProvisioningScreen extends StatelessWidget {
  const AdminUserProvisioningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User provisioning')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Why CLI? ──────────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Why is this done via CLI?',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Creating or permanently deleting Firebase Auth accounts '
                      'requires the Admin SDK, which holds privileged credentials '
                      'that must never be embedded in a mobile app. '
                      'The manage-users.mjs script runs on a trusted machine '
                      'with application-default credentials and performs both '
                      'Firebase Auth + Firestore operations atomically, '
                      'with rollback on failure and an audit log entry.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Commands ──────────────────────────────────────────────────────
            _SectionTitle('Available commands'),
            const SizedBox(height: 10),
            _CommandCard(
              icon: Icons.person_add_outlined,
              title: 'Create a Fan account',
              command:
                  'node manage-users.mjs create-fan \\\n'
                  '  --email=fan@example.com \\\n'
                  '  --password=SecurePass1 \\\n'
                  '  --name="Fan Name"',
              description:
                  'Creates a Firebase Auth user + Firestore profile with role=fan.',
            ),
            const SizedBox(height: 10),
            _CommandCard(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Create an Admin account',
              command:
                  'node manage-users.mjs create-admin \\\n'
                  '  --email=admin@example.com \\\n'
                  '  --password=StrongPass12! \\\n'
                  '  --name="Admin Name"',
              description:
                  'Creates Auth user, sets admin custom claim, and writes Firestore profile with role=admin.',
            ),
            const SizedBox(height: 10),
            _CommandCard(
              icon: Icons.delete_outline,
              title: 'Permanently delete a user',
              command:
                  'node manage-users.mjs delete-user \\\n'
                  '  --uid=<user-uid>',
              description:
                  'Writes an audit log, removes Firestore profile, then deletes the Auth account. Requires typing DELETE to confirm.',
            ),
            const SizedBox(height: 10),
            _CommandCard(
              icon: Icons.block_outlined,
              title: 'Disable a user (Auth + Firestore)',
              command:
                  'node manage-users.mjs disable-user \\\n'
                  '  --uid=<user-uid>',
              description:
                  'Disables Firebase Auth login AND sets accountStatus=disabled in Firestore. Use for hard lockout.',
            ),
            const SizedBox(height: 10),
            _CommandCard(
              icon: Icons.check_circle_outline,
              title: 'Re-enable a user',
              command:
                  'node manage-users.mjs enable-user \\\n'
                  '  --uid=<user-uid>',
              description: 'Re-enables both Auth login and Firestore status.',
            ),
            const SizedBox(height: 10),
            _CommandCard(
              icon: Icons.list_outlined,
              title: 'List all users',
              command: 'node manage-users.mjs list-users --limit=100',
              description:
                  'Lists Auth users with their Firestore role and account status.',
            ),

            const SizedBox(height: 24),
            _SectionTitle('Setup (run once in admin-tools/)'),
            const SizedBox(height: 10),
            _CommandCard(
              icon: Icons.terminal_outlined,
              title: 'Install dependencies',
              command:
                  'cd admin-tools\n'
                  'npm install\n'
                  'gcloud auth application-default login',
              description:
                  'Installs firebase-admin and authenticates your machine with Google Cloud credentials.',
            ),

            const SizedBox(height: 24),
            // ── In-app soft disable note ──────────────────────────────────────
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'In-app account status toggle',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The Users screen already provides a soft disable toggle '
                      'that sets accountStatus=disabled in Firestore. '
                      'This prevents app access via Firestore rules immediately. '
                      'To also block Firebase Auth token refresh (hard lockout), '
                      'use the disable-user CLI command above.',
                      style: TextStyle(
                        height: 1.5,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({
    required this.icon,
    required this.title,
    required this.command,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String command;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(description, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: SelectableText(
                command,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
