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
                    const SizedBox(height: 24),
                    const _MockActivityChart(),
                    const SizedBox(height: 24),
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
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
      clipBehavior: Clip.none,
      child: Row(
        children: const [
          _DoubleStatCard(
            label1: 'Members', path1: 'users', sub1: '3.2% this week', up1: true,
            label2: 'Pending posts', path2: 'content', sub2: '14 today', up2: false,
          ),
          SizedBox(width: 16),
          _DoubleStatCard(
            label1: 'Events', path1: 'events', sub1: '5 this week', up1: true,
            label2: 'Products', path2: 'merchandise', sub2: 'New arrivals', up2: true,
          ),
          SizedBox(width: 16),
          _DoubleStatCard(
            label1: 'Discussions', path1: 'discussions', sub1: 'Active threads', up1: false,
            label2: 'Inquiries', path2: 'inquiries', sub2: 'Pending replies', up2: true, group2: true,
          ),
        ],
      ),
    );
  }
}

class _DoubleStatCard extends StatelessWidget {
  const _DoubleStatCard({
    required this.label1, required this.path1, required this.sub1, required this.up1, this.group1 = false,
    required this.label2, required this.path2, required this.sub2, required this.up2, this.group2 = false,
  });

  final String label1, path1, sub1;
  final bool up1, group1;
  final String label2, path2, sub2;
  final bool up2, group2;

  @override
  Widget build(BuildContext context) {
    // 40 is padding (20 left + 20 right) in parent
    final width = MediaQuery.of(context).size.width - 40;
    return Container(
      width: width > 400 ? 400 : width, // max width 400
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1154).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _SingleStatColumn(label: label1, path: path1, sub: sub1, up: up1, group: group1)),
          Expanded(child: _SingleStatColumn(label: label2, path: path2, sub: sub2, up: up2, group: group2)),
        ],
      ),
    );
  }
}

class _SingleStatColumn extends StatelessWidget {
  const _SingleStatColumn({required this.label, required this.path, required this.sub, required this.up, required this.group});
  
  final String label, path, sub;
  final bool up, group;

  @override
  Widget build(BuildContext context) {
    final future = group
        ? FirebaseFirestore.instance.collectionGroup(path).count().get()
        : FirebaseFirestore.instance.collection(path).count().get();
        
    return FutureBuilder<AggregateQuerySnapshot>(
      future: future,
      builder: (context, snapshot) {
        final count = snapshot.data?.count ?? 0;
        final iconColor = up ? const Color(0xFFD946EF) : Colors.white54;
        final icon = up ? Icons.arrow_drop_up : Icons.arrow_drop_down;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count > 10000 ? '${(count / 1000).toStringAsFixed(1)}K' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFD8B4FE),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    sub,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MockActivityChart extends StatelessWidget {
  const _MockActivityChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF180A2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Activity, last 7 days',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Details',
                style: TextStyle(
                  color: Color(0xFFC084FC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(40),
              _buildBar(60),
              _buildBar(35),
              _buildBar(80),
              _buildBar(50),
              _buildBar(100),
              _buildBar(65),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 32,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF180A2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Modules queue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'See all',
                style: TextStyle(
                  color: Color(0xFFC084FC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
            ),
            itemBuilder: (context, index) {
              final module = modules[index];
              return InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => module.screen())),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(module.icon, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              color: Color(0xFFD8B4FE),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1154),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Open',
                        style: TextStyle(
                          color: Color(0xFFE9D5FF),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
