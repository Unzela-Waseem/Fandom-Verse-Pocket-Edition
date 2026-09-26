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
      backgroundColor: const Color(0xFF09040E),
      body: Stack(
        children: [
          // Background ambient radial light glow effects
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            height: 300,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.9,
                    colors: [Color(0x55A855F7), Color(0x0009040E)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -80,
            width: 260,
            height: 260,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [Color(0x35D946EF), Color(0x0009040E)],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AdminTopBar(),
                    const SizedBox(height: 24),
                    const _AdminStatsRow(),
                    const SizedBox(height: 32),
                    const Text(
                      'Manage Modules',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AdminModuleGrid(profile: profile),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTopBar extends ConsumerWidget {
  const _AdminTopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'StarVerse',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            Text(
              'Admin panel',
              style: TextStyle(color: Color(0xFFC084FC), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C0D38),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.3)),
          ),
          child: PopupMenuButton<int>(
            icon: const Icon(Icons.notifications_none, color: Color(0xFFFACC15)),
            color: const Color(0xFF1C0D38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: const Color(0xFFA855F7).withOpacity(0.3)),
            ),
            offset: const Offset(0, 48),
            onSelected: (value) {
              if (value == 0) {
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AdminAuditLogsScreen()));
              } else if (value == 1) {
                ref.read(authServiceProvider).signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Row(children: [Icon(Icons.history_outlined, color: Color(0xFFE9D5FF)), SizedBox(width: 12), Text('Audit logs', style: TextStyle(color: Colors.white))]),
              ),
              const PopupMenuItem(
                value: 1,
                child: Row(children: [Icon(Icons.logout, color: Colors.redAccent), SizedBox(width: 12), Text('Sign out', style: TextStyle(color: Colors.white))]),
              ),
            ],
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(
            label: 'Users',
            collectionPath: 'users',
            icon: Icons.people_outline,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Content',
            collectionPath: 'content',
            icon: Icons.article_outlined,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Events',
            collectionPath: 'events',
            icon: Icons.event_outlined,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Products',
            collectionPath: 'merchandise',
            icon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Discussions',
            collectionPath: 'discussions',
            icon: Icons.forum_outlined,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Inquiries',
            collectionPath: 'inquiries',
            icon: Icons.mail_outline,
            useCollectionGroup: true,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.collectionPath,
    required this.icon,
    this.useCollectionGroup = false,
  });

  final String label;
  final String collectionPath;
  final IconData icon;
  final bool useCollectionGroup;

  @override
  Widget build(BuildContext context) {
    final future = useCollectionGroup
        ? FirebaseFirestore.instance
              .collectionGroup(collectionPath)
              .count()
              .get()
        : FirebaseFirestore.instance.collection(collectionPath).count().get();
    return FutureBuilder<AggregateQuerySnapshot>(
      future: future,
      builder: (context, snapshot) {
        final count = snapshot.data?.count ?? 0;
        return Container(
          width: 130,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1154).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: const Color(0xFFC084FC)),
                  const Spacer(),
                  Icon(Icons.arrow_drop_up, size: 20, color: const Color(0xFFE879F9)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFD8B4FE),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
        Icons.person_add_outlined,
        'Provisioning',
        'Create & delete users',
        () => const AdminUserProvisioningScreen(),
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
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF180A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.15)),
          ),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      module.icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    module.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.subtitle,
                    style: const TextStyle(
                      color: Color(0xFFC084FC),
                      fontSize: 12,
                    ),
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
