import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/auth_providers.dart';
import '../../authentication/domain/app_user.dart';
import 'admin_collection_screen.dart';
import 'admin_records_screen.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key, required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = <_AdminModule>[
      _AdminModule(
        Icons.people_outline,
        'Users',
        () => const AdminUsersScreen(),
      ),
      _AdminModule(
        Icons.category_outlined,
        'Categories',
        () => AdminCollectionScreen(config: AdminCollectionConfig.categories),
      ),
      _AdminModule(
        Icons.article_outlined,
        'Content',
        () => AdminCollectionScreen(config: AdminCollectionConfig.content),
      ),
      _AdminModule(
        Icons.event_outlined,
        'Events',
        () => AdminCollectionScreen(config: AdminCollectionConfig.events),
      ),
      _AdminModule(
        Icons.shopping_bag_outlined,
        'Merchandise',
        () => AdminCollectionScreen(config: AdminCollectionConfig.merchandise),
      ),
      _AdminModule(
        Icons.forum_outlined,
        'Moderation',
        () => const AdminModerationScreen(),
      ),
      _AdminModule(
        Icons.mail_outline,
        'Inquiries',
        () => const AdminInquiriesScreen(),
      ),
      _AdminModule(
        Icons.notifications_outlined,
        'Announcements',
        () =>
            AdminCollectionScreen(config: AdminCollectionConfig.announcements),
      ),
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
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          childAspectRatio: 1.15,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          final module = modules[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => module.screen())),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(module.icon, size: 34),
                    const Spacer(),
                    Text(
                      module.title,
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

class _AdminModule {
  const _AdminModule(this.icon, this.title, this.screen);

  final IconData icon;
  final String title;
  final Widget Function() screen;
}
