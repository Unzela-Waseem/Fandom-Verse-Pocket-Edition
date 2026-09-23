import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/auth_providers.dart';
import '../../authentication/domain/app_user.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key, required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const modules = [
      (Icons.people_outline, 'Users'),
      (Icons.category_outlined, 'Categories'),
      (Icons.article_outlined, 'Content'),
      (Icons.event_outlined, 'Events'),
      (Icons.shopping_bag_outlined, 'Merchandise'),
      (Icons.forum_outlined, 'Moderation'),
      (Icons.mail_outline, 'Inquiries'),
      (Icons.notifications_outlined, 'Notifications'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authServiceProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: modules.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          final module = modules[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${module.$2} management is being implemented.',
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(module.$1, size: 34),
                    const Spacer(),
                    Text(
                      module.$2,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
