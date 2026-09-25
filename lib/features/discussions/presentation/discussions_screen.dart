import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiscussionsScreen extends StatelessWidget {
  const DiscussionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Community')),
        body: const Center(
          child: Text('Sign in to join community discussions.'),
        ),
      );
    }

    // Only load non-hidden posts for fans. The admin moderation screen
    // queries without this filter so moderators can still see hidden threads.
    final stream = FirebaseFirestore.instance
        .collection('discussions')
        .where('hidden', isNotEqualTo: true)
        .orderBy('hidden') // required composite index field when using !=
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Community discussions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const _DiscussionEditor(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New thread'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Discussions could not be loaded.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!.docs;
          if (documents.isEmpty) {
            return const Center(
              child: Text('Start the first respectful discussion.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data();
              final owned = data['userId'] == user.uid;
              final createdAt = data['createdAt'] as Timestamp?;
              final rating = data['rating'] as int?;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  title: Text(
                    data['title'] as String? ?? 'Untitled',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        data['body'] as String? ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            data['authorName'] as String? ?? 'Fan',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (rating != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star, size: 12),
                            Text(
                              '$rating',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                          if (createdAt != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _fmtDate(createdAt),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: owned
                      ? PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'edit') {
                              await showDialog<void>(
                                context: context,
                                builder: (_) =>
                                    _DiscussionEditor(document: document),
                              );
                            } else if (action == 'delete' && context.mounted) {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete discussion?'),
                                  content: const Text('This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await document.reference.delete();
                              }
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit_outlined, size: 18),
                                title: Text('Edit'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline, size: 18),
                                title: Text('Delete'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        )
                      : const Icon(Icons.forum_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _fmtDate(Timestamp ts) {
    final dt = ts.toDate().toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

// ── Discussion Editor ─────────────────────────────────────────────────────────

class _DiscussionEditor extends StatefulWidget {
  const _DiscussionEditor({this.document});
  final QueryDocumentSnapshot<Map<String, dynamic>>? document;

  @override
  State<_DiscussionEditor> createState() => _DiscussionEditorState();
}

class _DiscussionEditorState extends State<_DiscussionEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  int _rating = 5;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.document?.data();
    _titleController = TextEditingController(text: data?['title'] as String?);
    _bodyController = TextEditingController(text: data?['body'] as String?);
    _rating = data?['rating'] as int? ?? 5;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null ||
        _saving ||
        _titleController.text.trim().length < 4 ||
        _bodyController.text.trim().length < 10) {
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'userId': user.uid,
        'authorName': user.displayName ?? 'Fan',
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'rating': _rating,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (widget.document == null) {
        await FirebaseFirestore.instance.collection('discussions').add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'hidden': false, // explicitly mark as visible on creation
        });
      } else {
        await widget.document!.reference.update(data);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.document == null ? 'New discussion' : 'Edit discussion',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              minLines: 4,
              maxLines: 7,
              maxLength: 1500,
              decoration: const InputDecoration(labelText: 'Discussion'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Rating'),
                Expanded(
                  child: Slider(
                    value: _rating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_rating',
                    onChanged: (value) =>
                        setState(() => _rating = value.round()),
                  ),
                ),
                Text('$_rating / 5'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
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
}
