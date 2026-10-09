import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'thread_detail_screen.dart';

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
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Community discussions')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'discussions_fab',
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
          // Filter out hidden posts locally to avoid requiring a composite index in Firestore
          final documents = snapshot.data!.docs.where((doc) {
            final hidden = doc.data()['hidden'] as bool?;
            return hidden != true;
          }).toList();

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
              final imageUrl = data['imageUrl'] as String?;
              final category = data['category'] as String?;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ThreadDetailScreen(document: document),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ListTile(
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
                            const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                data['authorName'] as String? ?? 'Fan',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (category != null && category != 'General')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(fontSize: 10, color: Colors.purpleAccent),
                                  ),
                                ),
                              if (rating != null) ...[
                                const Icon(Icons.star, size: 12, color: Colors.amber),
                                Text(
                                  '$rating',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                              if (createdAt != null)
                                Text(
                                  _fmtDate(createdAt),
                                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                                ),
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
  late final TextEditingController _imageUrlController;
  String _category = 'General';
  int _rating = 5;
  bool _saving = false;

  final _categories = ['General', 'Anime', 'Gaming', 'Sci-Fi', 'Comics', 'Fantasy', 'Art'];

  @override
  void initState() {
    super.initState();
    final data = widget.document?.data();
    _titleController = TextEditingController(text: data?['title'] as String?);
    _bodyController = TextEditingController(text: data?['body'] as String?);
    _imageUrlController = TextEditingController(text: data?['imageUrl'] as String?);
    _category = data?['category'] as String? ?? 'General';
    if (!_categories.contains(_category)) _category = 'General';
    _rating = data?['rating'] as int? ?? 5;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
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
        'imageUrl': _imageUrlController.text.trim(),
        'category': _category,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Fandom Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              minLines: 4,
              maxLines: 7,
              maxLength: 1500,
              decoration: const InputDecoration(labelText: 'Discussion Body'),
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
