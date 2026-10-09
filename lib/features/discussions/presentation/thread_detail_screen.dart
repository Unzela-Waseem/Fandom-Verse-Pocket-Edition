import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ThreadDetailScreen extends StatefulWidget {
  const ThreadDetailScreen({super.key, required this.document});

  final QueryDocumentSnapshot<Map<String, dynamic>> document;

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    final text = _commentController.text.trim();
    if (user == null || text.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    try {
      await widget.document.reference.collection('comments').add({
        'userId': user.uid,
        'authorName': user.displayName ?? 'Fan',
        'body': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _reportPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this post?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Report'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('reports').add({
          'reporterId': user.uid,
          'reportedDocId': widget.document.id,
          'reportedCollection': 'discussions',
          'reason': reasonController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post reported successfully. Thank you.')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit report.')),
          );
        }
      }
    }
    reasonController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final data = widget.document.data();
    final isOwner = user?.uid == data['userId'];

    final imageUrl = data['imageUrl'] as String?;
    final title = data['title'] as String? ?? 'Untitled';
    final body = data['body'] as String? ?? '';
    final category = data['category'] as String?;
    final rating = data['rating'] as int?;
    final authorName = data['authorName'] as String? ?? 'Fan';
    final createdAt = data['createdAt'] as Timestamp?;

    final commentsStream = widget.document.reference
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
        actions: [
          if (user != null && !isOwner)
            IconButton(
              icon: const Icon(Icons.report_outlined, color: Colors.redAccent),
              tooltip: 'Report this post',
              onPressed: _reportPost,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA855F7),
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
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(
                          '$rating',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                      if (createdAt != null)
                        Text(
                          _fmtDate(createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: commentsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Could not load comments.');
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final comments = snapshot.data!.docs;
                      if (comments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No comments yet. Be the first to share your thoughts!',
                            style: TextStyle(color: Colors.white54),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final cDoc = comments[index];
                          final cData = cDoc.data();
                          final cAuthor = cData['authorName'] as String? ?? 'Fan';
                          final cBody = cData['body'] as String? ?? '';
                          final cTime = cData['createdAt'] as Timestamp?;
                          final cOwned = user?.uid == cData['userId'];

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      cAuthor,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFFA855F7),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (cTime != null)
                                      Text(
                                        _fmtDate(cTime),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    if (cOwned) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () async {
                                          final conf = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Delete comment?'),
                                              content: const Text('This cannot be undone.'),
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
                                          if (conf == true) {
                                            await cDoc.reference.delete();
                                          }
                                        },
                                        child: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(cBody, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (user != null)
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0616),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _submitting ? null : _submitComment,
                    icon: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: Color(0xFFA855F7)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
