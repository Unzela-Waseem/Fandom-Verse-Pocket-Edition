import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/application/auth_providers.dart';
import '../../authentication/domain/app_user.dart';
import 'admin_collection_screen.dart';
import 'admin_records_screen.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key, required this.profile});
  final AppUser profile;

  static const bg = Color(0xFF07040D);
  static const surface = Color(0xFF130D20);
  static const border = Color(0xFF332053);
  static const textDark = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF9E8DB8);
  
  static const cardPurple = Color(0xFF6D28D9);
  static const cardBlue = Color(0xFF3B82F6);
  static const cardYellow = Color(0xFFFACC15);
  static const cardPink = Color(0xFFF43F5E);
  static const cardMint = Color(0xFF10B981);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(
                          profile: profile,
                          onSignOut: () =>
                              ref.read(authServiceProvider).signOut(),
                        ),
                        const SizedBox(height: 32),
                        _WelcomePanel(profile: profile),
                        const SizedBox(height: 40),
                        const _Heading(
                          title: 'Workspace Overview',
                          action: Text('See All', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        const _MetricGrid(),
                        const SizedBox(height: 40),
                        const _Heading(
                          title: 'Content & Commerce',
                          action: Text('See All', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        const _ModuleSectionContent(),
                        const SizedBox(height: 40),
                        const _Heading(title: 'Community Care'),
                        const SizedBox(height: 16),
                        const _ModuleSectionCommunity(),
                        const SizedBox(height: 40),
                        const _Heading(title: 'Administration'),
                        const SizedBox(height: 16),
                        const _ModuleSectionAdmin(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6D28D9),
        onPressed: () {},
        child: const Icon(Icons.dashboard_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AdminDashboard.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5)),
          if (action != null) action!,
        ],
      );
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.profile});
  final AppUser profile;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D28D9).withValues(alpha: 0.3),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0x22FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0x11FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fandom Verse', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5)),
                      const Text('Management Hub', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                      const Text('Smart administration built for\nfaster community success.', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const AdminUsersScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF312E81),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      )
                    ],
                  ),
                ),
                if (MediaQuery.of(context).size.width > 600)
                  const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.emoji_events_rounded, size: 100, color: Color(0xFFFFD700)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.profile, required this.onSignOut});
  final AppUser profile;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName.trim().isEmpty
        ? 'Admin'
        : profile.displayName.trim().split(RegExp(r'\s+')).first;
        
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFF6D28D9),
              child: Icon(Icons.face_retouching_natural_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hey, $name', style: const TextStyle(color: AdminDashboard.textDark, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const Text('Administrator', style: TextStyle(color: AdminDashboard.textMuted, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AdminDashboard.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AdminDashboard.border)
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AdminDashboard.textDark),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<int>(
              color: AdminDashboard.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              onSelected: (value) {
                if (value == 1) onSignOut();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 1,
                    child: Row(children: [
                      Icon(Icons.logout_rounded, color: Color(0xFFFF5252)),
                      SizedBox(width: 10),
                      Text('Sign out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    ]))
              ],
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AdminDashboard.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AdminDashboard.border)
                ),
                child: const Icon(Icons.more_vert_rounded, color: AdminDashboard.textDark),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid();
  @override
  Widget build(BuildContext context) {
    const metrics = [
      _Metric('Members', 'users', Icons.school_rounded, AdminDashboard.cardPurple),
      _Metric('Content', 'content', Icons.menu_book_rounded, AdminDashboard.cardBlue),
      _Metric('Events', 'events', Icons.event_rounded, AdminDashboard.cardYellow),
      _Metric('Products', 'merchandise', Icons.shopping_bag_rounded, AdminDashboard.cardPink),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 800 ? 4 : 2;
      const gap = 16.0;
      final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
      return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map((metric) => SizedBox(width: width, child: _MetricCard(metric: metric)))
              .toList());
    });
  }
}

class _Metric {
  const _Metric(this.label, this.collection, this.icon, this.color);
  final String label, collection;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final _Metric metric;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminDashboard.surface,
        border: Border.all(color: AdminDashboard.border),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(40),
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: metric.color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(metric.icon, color: metric.color, size: 24),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_outward_rounded, color: metric.color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(metric.label, style: const TextStyle(color: AdminDashboard.textDark, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 4),
          FutureBuilder<AggregateQuerySnapshot>(
            future: Firebase.apps.isEmpty
                ? null
                : FirebaseFirestore.instance.collection(metric.collection).count().get(),
            builder: (context, snapshot) {
              final count = snapshot.data?.count;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(count == null ? '—' : _count(count), style: const TextStyle(color: AdminDashboard.textDark, fontSize: 34, fontWeight: FontWeight.w900, height: 1, letterSpacing: -1)),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('Total', style: TextStyle(color: AdminDashboard.textMuted, fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
  
  String _count(int value) => value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value';
}


class _Module {
  const _Module(this.title, this.subtitle, this.icon, this.color, this.iconColor, this.screen);
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Widget Function() screen;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});
  final _Module module;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => module.screen())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AdminDashboard.surface,
          border: Border.all(color: AdminDashboard.border),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: module.color.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Center(
                child: Icon(module.icon, size: 36, color: module.color),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(module.title, style: const TextStyle(color: AdminDashboard.textDark, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const _AvatarStack(),
                      const SizedBox(width: 8),
                      Expanded(child: Text(module.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AdminDashboard.textMuted, fontSize: 12, fontWeight: FontWeight.w800))),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: module.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_outward_rounded, color: module.color),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 22,
      child: Stack(
        children: const [
          Positioned(left: 0, child: _Av(Color(0xFFFFA7A7))),
          Positioned(left: 14, child: _Av(Color(0xFF8C9EFF))),
          Positioned(left: 28, child: _Av(Color(0xFF69F0AE))),
        ],
      ),
    );
  }
}

class _Av extends StatelessWidget {
  const _Av(this.color);
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 22, height: 22,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: AdminDashboard.surface, width: 2)),
    child: const Icon(Icons.person, size: 12, color: Colors.white),
  );
}

class _ModuleList extends StatelessWidget {
  const _ModuleList({required this.modules});
  final List<_Module> modules;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 800 ? 2 : 1;
      const gap = 16.0;
      final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
      return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: modules
              .map((module) => SizedBox(width: width, child: _ModuleCard(module: module)))
              .toList());
    });
  }
}

class _ModuleSectionContent extends StatelessWidget {
  const _ModuleSectionContent();
  @override
  Widget build(BuildContext context) {
    final modules = [
      _Module('Members', 'Manage access', Icons.groups_rounded, AdminDashboard.cardPurple, AdminDashboard.cardPurple, () => const AdminUsersScreen()),
      _Module('Categories', 'Organize spaces', Icons.category_rounded, AdminDashboard.cardYellow, AdminDashboard.cardYellow, () => const AdminCollectionScreen(config: AdminCollectionConfig.categories)),
      _Module('Content', 'Stories & media', Icons.article_rounded, AdminDashboard.cardBlue, AdminDashboard.cardBlue, () => const AdminCollectionScreen(config: AdminCollectionConfig.content)),
      _Module('Events', 'Meetups', Icons.event_rounded, AdminDashboard.cardPink, AdminDashboard.cardPink, () => const AdminCollectionScreen(config: AdminCollectionConfig.events)),
      _Module('Merchandise', 'Store stock', Icons.shopping_bag_rounded, AdminDashboard.cardMint, AdminDashboard.cardMint, () => const AdminCollectionScreen(config: AdminCollectionConfig.merchandise)),
    ];
    return _ModuleList(modules: modules);
  }
}

class _ModuleSectionCommunity extends StatelessWidget {
  const _ModuleSectionCommunity();
  @override
  Widget build(BuildContext context) {
    final modules = [
      _Module('Moderation', 'Keep it healthy', Icons.shield_rounded, AdminDashboard.cardBlue, AdminDashboard.cardBlue, () => const AdminModerationScreen()),
      _Module('Inquiries', 'Fan requests', Icons.mark_email_unread_rounded, AdminDashboard.cardMint, AdminDashboard.cardMint, () => const AdminInquiriesScreen()),
      _Module('Announcements', 'Publish updates', Icons.campaign_rounded, AdminDashboard.cardYellow, AdminDashboard.cardYellow, () => const AdminCollectionScreen(config: AdminCollectionConfig.announcements)),
    ];
    return _ModuleList(modules: modules);
  }
}

class _ModuleSectionAdmin extends StatelessWidget {
  const _ModuleSectionAdmin();
  @override
  Widget build(BuildContext context) {
    final modules = [
      _Module('Provisioning', 'Create users', Icons.person_add_rounded, AdminDashboard.cardPurple, AdminDashboard.cardPurple, () => const AdminUserProvisioningScreen()),
      _Module('Audit Logs', 'Review actions', Icons.history_rounded, AdminDashboard.cardPink, AdminDashboard.cardPink, () => const AdminAuditLogsScreen()),
    ];
    return _ModuleList(modules: modules);
  }
}
