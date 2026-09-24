import 'package:cloud_firestore/cloud_firestore.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            tooltip: 'Audit logs',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdminAuditLogsScreen(),
              ),
            ),
            icon: const Icon(Icons.history_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authServiceProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AdminGreeting(profile: profile),
            const SizedBox(height: 20),
            const _AdminStatsRow(),
            const SizedBox(height: 24),
            Text(
              'Manage',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _AdminModuleGrid(profile: profile),
          ],
        ),
      ),
    );
  }
}

// ── Greeting ─────────────────────────────────────────────────────────────────

class _AdminGreeting extends StatelessWidget {
  const _AdminGreeting({required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundImage: profile.avatarUrl != null
              ? NetworkImage(profile.avatarUrl!)
              : null,
          child: profile.avatarUrl == null
              ? Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName[0].toUpperCase()
                      : 'A',
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${profile.displayName}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Admin',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Live Stats ────────────────────────────────────────────────────────────────

class _AdminStatsRow extends StatelessWidget {
  const _AdminStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Users',
            collectionPath: 'users',
            icon: Icons.people_outline,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Content',
            collectionPath: 'content',
            icon: Icons.article_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Events',
            collectionPath: 'events',
            icon: Icons.event_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Products',
            collectionPath: 'merchandise',
            icon: Icons.shopping_bag_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.collectionPath,
    required this.icon,
  });

  final String label;
  final String collectionPath;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AggregateQuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection(collectionPath)
          .count()
          .get(),
      builder: (context, snapshot) {
        final count = snapshot.data?.count ?? 0;
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 6),
                Text(
                  '$count',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Module Grid ───────────────────────────────────────────────────────────────

class _AdminModuleGrid extends StatelessWidget {
  const _AdminModuleGrid({required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    final modules = <_AdminModule>[
      _AdminModule(
        Icons.people_outline,
        'Users',
        'Manage fan accounts',
        () => const AdminUsersScreen(),
      ),
      _AdminModule(
        Icons.category_outlined,
        'Categories',
        'Fandom categories',
        () => AdminCollectionScreen(config: AdminCollectionConfig.categories),
      ),
      _AdminModule(
        Icons.article_outlined,
        'Content',
        'Stories, news & media',
        () => AdminCollectionScreen(config: AdminCollectionConfig.content),
      ),
      _AdminModule(
        Icons.event_outlined,
        'Events',
        'Conventions & meetups',
        () => AdminCollectionScreen(config: AdminCollectionConfig.events),
      ),
      _AdminModule(
        Icons.shopping_bag_outlined,
        'Merchandise',
        'Products & pricing',
        () => AdminCollectionScreen(config: AdminCollectionConfig.merchandise),
      ),
      _AdminModule(
        Icons.forum_outlined,
        'Moderation',
        'Community discussions',
        () => const AdminModerationScreen(),
      ),
      _AdminModule(
        Icons.mail_outline,
        'Inquiries',
        'Contact submissions',
        () => const AdminInquiriesScreen(),
      ),
      _AdminModule(
        Icons.notifications_outlined,
        'Announcements',
        'Push & in-app notices',
        () =>
            AdminCollectionScreen(config: AdminCollectionConfig.announcements),
      ),
      _AdminModule(
        Icons.history_outlined,
        'Audit Logs',
        'All admin actions',
        () => const AdminAuditLogsScreen(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withAlpha(128),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      module.icon,
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    module.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    module.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AdminModule {
  const _AdminModule(this.icon, this.title, this.subtitle, this.screen);

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget Function() screen;
}
