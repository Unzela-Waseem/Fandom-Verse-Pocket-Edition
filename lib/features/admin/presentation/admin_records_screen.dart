import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_collection_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _query = '';
  String? _busyId;

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
            'The user will lose access to protected app features until re-enabled.',
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
      final batch = FirebaseFirestore.instance.batch();
      batch.update(user.reference, {
        'accountStatus': active ? 'active' : 'disabled',
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser!.uid,
      });
      addAdminAudit(
        batch,
        action: active ? 'enable' : 'disable',
        collection: 'users',
        recordId: user.id,
      );
      await batch.commit();
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Status update failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _query = value.toLowerCase()),
              decoration: const InputDecoration(
                labelText: 'Search name or email',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Users could not be loaded.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final haystack =
                      '${data['displayName'] ?? ''} ${data['email'] ?? ''}'
                          .toLowerCase();
                  return haystack.contains(_query.trim());
                }).toList();
                if (users.isEmpty) {
                  return const Center(child: Text('No matching users.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final data = user.data();
                    final active =
                        (data['accountStatus'] ?? 'active') == 'active';
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              data['displayName'] as String? ?? 'Unnamed',
                            ),
                            subtitle: Text(
                              '${data['email'] ?? ''} · ${data['role'] ?? 'unknown'}',
                            ),
                            trailing: IconButton(
                              tooltip: 'Edit profile fields',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (_) => _AdminUserEditor(user: user),
                              ),
                            ),
                          ),
                          SwitchListTile(
                            title: const Text('Account active'),
                            value: active,
                            onChanged:
                                data['role'] == 'admin' || _busyId != null
                                ? null
                                : (value) => _setStatus(user, value),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.user.data();
    _name = TextEditingController(text: data['displayName'] as String? ?? '');
    _bio = TextEditingController(text: data['bio'] as String? ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
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
              TextFormField(
                controller: _bio,
                minLines: 2,
                maxLines: 4,
                maxLength: 300,
                decoration: const InputDecoration(labelText: 'Bio'),
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

class AdminModerationScreen extends StatelessWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context) => _AdminDeleteList(
    title: 'Discussion moderation',
    stream: FirebaseFirestore.instance
        .collection('discussions')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots(),
    titleField: 'title',
    subtitleField: 'body',
    emptyMessage: 'There are no discussions to moderate.',
  );
}

class AdminInquiriesScreen extends StatelessWidget {
  const AdminInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collectionGroup('inquiries')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Inquiries')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Inquiries could not be loaded.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final inquiries = snapshot.data!.docs;
          if (inquiries.isEmpty) {
            return const Center(child: Text('There are no inquiries.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inquiries.length,
            itemBuilder: (context, index) {
              final inquiry = inquiries[index];
              final data = inquiry.data();
              final status = data['status'] as String? ?? 'open';
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  title: Text(data['subject'] as String? ?? 'No subject'),
                  subtitle: Text(
                    '${data['email'] ?? ''}\n${data['message'] ?? ''}',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    initialValue: status,
                    onSelected: (value) async {
                      try {
                        final batch = FirebaseFirestore.instance.batch();
                        batch.update(inquiry.reference, {
                          'status': value,
                          'updatedAt': FieldValue.serverTimestamp(),
                        });
                        addAdminAudit(
                          batch,
                          action: 'status:$value',
                          collection: 'inquiries',
                          recordId: inquiry.id,
                        );
                        await batch.commit();
                      } on FirebaseException catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.message ?? 'Update failed.'),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'open', child: Text('Open')),
                      PopupMenuItem(value: 'resolved', child: Text('Resolved')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminDeleteList extends StatelessWidget {
  const _AdminDeleteList({
    required this.title,
    required this.stream,
    required this.titleField,
    required this.subtitleField,
    required this.emptyMessage,
  });

  final String title;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final String titleField;
  final String subtitleField;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Records could not be loaded.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data!.docs;
          if (records.isEmpty) return Center(child: Text(emptyMessage));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final data = record.data();
              return Card(
                child: ListTile(
                  title: Text(data[titleField] as String? ?? 'Untitled'),
                  subtitle: Text(
                    data[subtitleField] as String? ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
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
                      if (confirmed != true) return;
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
                      } on FirebaseException catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.message ?? 'Removal failed.'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
