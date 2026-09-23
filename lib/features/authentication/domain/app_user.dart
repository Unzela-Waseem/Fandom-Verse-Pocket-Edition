import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { fan, admin }

class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    required this.selectedFandoms,
    required this.badge,
    this.bio = '',
    this.avatarUrl,
  });

  final String uid;
  final String displayName;
  final String email;
  final UserRole role;
  final List<String> selectedFandoms;
  final String badge;
  final String bio;
  final String? avatarUrl;

  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) throw const FormatException('User profile is missing.');
    final roleValue = data['role'];
    final role = switch (roleValue) {
      'fan' => UserRole.fan,
      'admin' => UserRole.admin,
      _ => throw const FormatException('The account role is invalid.'),
    };
    return AppUser(
      uid: snapshot.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: role,
      selectedFandoms: List<String>.from(
        data['selectedFandoms'] as List? ?? const [],
      ),
      badge: data['badge'] as String? ?? 'New Explorer',
      bio: data['bio'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
    );
  }
}
