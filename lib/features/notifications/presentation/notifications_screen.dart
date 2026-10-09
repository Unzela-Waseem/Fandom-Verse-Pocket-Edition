import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Firebase.apps.isEmpty
        ? null
        : FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('Sign in to view announcements.')),
        ),
      );
    }
    final announcements = FirebaseFirestore.instance
        .collection('announcements')
        .where('published', isEqualTo: true)
        .limit(50)
        .snapshots();
    final personal = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Announcements',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: announcements,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const ListTile(
                  title: Text('Announcements are unavailable.'),
                );
              }
              if (!snapshot.hasData) {
                return const ListTile(title: Text('Loading announcements…'));
              }
              final records = snapshot.data!.docs.toList()
                ..sort((a, b) {
                  final aDate = a.data()['updatedAt'] as Timestamp?;
                  final bDate = b.data()['updatedAt'] as Timestamp?;
                  return (bDate?.millisecondsSinceEpoch ?? 0).compareTo(
                    aDate?.millisecondsSinceEpoch ?? 0,
                  );
                });
              if (records.isEmpty) {
                return const ListTile(title: Text('No announcements yet.'));
              }
              return Column(
                children: records.map((record) {
                  final data = record.data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.campaign_outlined),
                      title: Text(data['title'] as String? ?? 'Announcement'),
                      subtitle: Text(data['message'] as String? ?? ''),
                      isThreeLine: true,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'For you',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: personal,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const ListTile(
                  title: Text('Personal notifications are unavailable.'),
                );
              }
              if (!snapshot.hasData) {
                return const ListTile(title: Text('Loading notifications…'));
              }
              final records = snapshot.data!.docs;
              if (records.isEmpty) {
                return const ListTile(
                  title: Text('No personal notifications yet.'),
                );
              }
              return Column(
                children: records.map((record) {
                  final data = record.data();
                  final createdAt = data['createdAt'] as Timestamp?;
                  final read = data['read'] == true;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        read
                            ? Icons.notifications_none
                            : Icons.notifications_active_outlined,
                      ),
                      title: Text(
                        data['title'] as String? ?? 'Notification',
                        style: TextStyle(
                          fontWeight: read
                              ? FontWeight.normal
                              : FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${data['message'] ?? ''}${createdAt == null ? '' : '\n${DateFormat.yMMMd().add_jm().format(createdAt.toDate())}'}',
                      ),
                      isThreeLine: true,
                      onTap: read
                          ? null
                          : () async {
                              try {
                                await record.reference.update({'read': true});
                              } on FirebaseException catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        error.message ??
                                            'Could not mark this notification as read.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
