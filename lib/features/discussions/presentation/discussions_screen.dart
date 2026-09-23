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
    final stream = FirebaseFirestore.instance
        .collection('discussions')
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
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  title: Text(
                    data['title'] as String? ?? 'Untitled',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data['body'] as String? ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
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
}

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
      });
    } else {
      await widget.document!.reference.update(data);
    }
    if (mounted) Navigator.of(context).pop();
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}
