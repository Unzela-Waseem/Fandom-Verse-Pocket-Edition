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

  static const canvas = Color(0xFF0B1020);
  static const surface = Color(0xFF141B31);
  static const border = Color(0xFF293555);
  static const ink = Color(0xFFF7F9FF);
  static const muted = Color(0xFFA7B3D1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(
                          profile: profile,
                          onSignOut: () =>
                              ref.read(authServiceProvider).signOut(),
                        ),
                        const SizedBox(height: 24),
                        _WelcomePanel(profile: profile),
                        const SizedBox(height: 30),
                        const _Heading(
                          title: 'Workspace overview',
                          subtitle: 'Live counts from your Fandom Verse data',
                        ),
                        const SizedBox(height: 14),
                        const _MetricGrid(),
                        const SizedBox(height: 32),
                        _Heading(
                          title: 'Management workspace',
                          subtitle:
                              'Content, community safety, and administrator tools',
                          action: TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const AdminAuditLogsScreen()),
                            ),
                            icon: const Icon(Icons.history_outlined, size: 18),
                            label: const Text('View audit logs'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _ModuleGrid(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        ? 'Administrator'
        : profile.displayName.trim();
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 16,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BrandMark(),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fandom Verse',
                    style: TextStyle(
                        color: AdminDashboard.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                SizedBox(height: 2),
                Text('ADMIN CONSOLE',
                    style: TextStyle(
                        color: Color(0xFF4ED7D0),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1.4)),
              ],
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: AdminDashboard.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminDashboard.border)),
              child: const Icon(Icons.notifications_none_rounded,
                  color: AdminDashboard.muted, size: 20),
            ),
            const SizedBox(width: 10),
            PopupMenuButton<int>(
              tooltip: 'Administrator menu',
              color: AdminDashboard.surface,
              onSelected: (value) {
                if (value == 1) onSignOut();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 1,
                    child: Row(children: [
                      Icon(Icons.logout_rounded, color: Color(0xFFFFA7A7)),
                      SizedBox(width: 10),
                      Text('Sign out')
                    ]))
              ],
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
                decoration: BoxDecoration(
                    color: AdminDashboard.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AdminDashboard.border)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFF6C8CFF),
                      child: Text(name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800))),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AdminDashboard.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700))),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AdminDashboard.muted),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF6C8CFF), Color(0xFF8F61FF)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x556C8CFF), blurRadius: 18, offset: Offset(0, 8))
          ],
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
      );
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.profile});
  final AppUser profile;
  @override
  Widget build(BuildContext context) {
    final name = profile.displayName.trim().isEmpty
        ? 'Administrator'
        : profile.displayName.trim().split(RegExp(r'\\s+')).first;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StatusPill(),
        const SizedBox(height: 14),
        Text(
          'Welcome back, $name',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Review activity, publish content, and keep your community safe.',
          style: TextStyle(color: Color(0xFFC9D5FF), fontSize: 14),
        ),
      ],
    );
    final artwork = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/fandom_multiverse.png',
        width: 128,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 128,
          height: 80,
          color: const Color(0x332F4F9B),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white54,
            size: 38,
          ),
        ),
      ),
    );
    final action = FilledButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AdminUsersScreen()),
      ),
      icon: const Icon(Icons.groups_rounded, size: 18),
      label: const Text('Manage members'),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17234A),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      ),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF213A78), Color(0xFF17234A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3D5EAF)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 20),
                artwork,
                const SizedBox(height: 18),
                action,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [artwork, const SizedBox(height: 12), action],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0x2939D6AA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x7757E6BD))),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.verified_rounded, color: Color(0xFF83F1CD), size: 15),
          SizedBox(width: 6),
          Text('ADMIN ACCESS',
              style: TextStyle(
                  color: Color(0xFFC9FFEC),
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800)),
        ]),
      );
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.subtitle, this.action});
  final String title;
  final String subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        runSpacing: 6,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: AdminDashboard.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                    const TextStyle(color: AdminDashboard.muted, fontSize: 13)),
          ]),
          if (action != null) action!,
        ],
      );
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid();
  @override
  Widget build(BuildContext context) {
    const metrics = [
      _Metric('Members', 'users', Icons.groups_rounded, Color(0xFF6C8CFF),
          'Registered community'),
      _Metric('Published content', 'content', Icons.article_rounded,
          Color(0xFFBA8CFF), 'Stories and guides'),
      _Metric('Events', 'events', Icons.event_available_rounded,
          Color(0xFF4ED7D0), 'Meetups and conventions'),
      _Metric('Products', 'merchandise', Icons.inventory_2_rounded,
          Color(0xFFFFB86B), 'Store catalog items'),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1000
          ? 4
          : constraints.maxWidth >= 620
              ? 2
              : 1;
      const gap = 12.0;
      final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
      return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map((metric) =>
                  SizedBox(width: width, child: _MetricCard(metric: metric)))
              .toList());
    });
  }
}

class _Metric {
  const _Metric(
      this.label, this.collection, this.icon, this.color, this.detail);
  final String label, collection, detail;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final _Metric metric;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AdminDashboard.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AdminDashboard.border)),
        child: FutureBuilder<AggregateQuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection(metric.collection)
              .count()
              .get(),
          builder: (context, snapshot) {
            final count = snapshot.data?.count;
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                                color: metric.color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(11)),
                            child: Icon(metric.icon,
                                color: metric.color, size: 20)),
                        const Icon(Icons.more_horiz_rounded,
                            color: AdminDashboard.muted),
                      ]),
                  const SizedBox(height: 20),
                  Text(count == null ? '—' : _count(count),
                      style: const TextStyle(
                          color: AdminDashboard.ink,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(metric.label,
                      style: const TextStyle(
                          color: AdminDashboard.ink,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(metric.detail,
                      style: const TextStyle(
                          color: AdminDashboard.muted, fontSize: 12)),
                ]);
          },
        ),
      );
  String _count(int value) =>
      value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value';
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid();
  @override
  Widget build(BuildContext context) {
    final contentModules = <_Module>[
      _Module('Members', 'Review accounts and access', Icons.groups_rounded,
          const Color(0xFF6C8CFF), () => const AdminUsersScreen()),
      _Module(
          'Categories',
          'Organize fandom spaces',
          Icons.category_rounded,
          const Color(0xFFBA8CFF),
          () =>
              AdminCollectionScreen(config: AdminCollectionConfig.categories)),
      _Module(
          'Content',
          'Stories, news and media',
          Icons.article_rounded,
          const Color(0xFF4ED7D0),
          () => AdminCollectionScreen(config: AdminCollectionConfig.content)),
      _Module(
          'Events',
          'Conventions and meetups',
          Icons.event_rounded,
          const Color(0xFFFFB86B),
          () => AdminCollectionScreen(config: AdminCollectionConfig.events)),
      _Module(
          'Merchandise',
          'Products, prices and stock',
          Icons.shopping_bag_rounded,
          const Color(0xFFFF7D9B),
          () =>
              AdminCollectionScreen(config: AdminCollectionConfig.merchandise)),
    ];
    final communityModules = <_Module>[
      _Module('Moderation', 'Keep discussions healthy', Icons.shield_outlined,
          const Color(0xFF75A7FF), () => const AdminModerationScreen()),
      _Module(
          'Inquiries',
          'Respond to fan requests',
          Icons.mark_email_unread_outlined,
          const Color(0xFF66D49A),
          () => const AdminInquiriesScreen()),
      _Module(
          'Announcements',
          'Publish updates',
          Icons.campaign_outlined,
          const Color(0xFFFFB86B),
          () => AdminCollectionScreen(
              config: AdminCollectionConfig.announcements)),
    ];
    final administrationModules = <_Module>[
      _Module(
          'Provisioning',
          'Create and manage users',
          Icons.person_add_alt_1_rounded,
          const Color(0xFFC48BFF),
          () => const AdminUserProvisioningScreen()),
      _Module(
          'Audit logs',
          'Review administrator actions',
          Icons.history_rounded,
          const Color(0xFF8DA5D9),
          () => const AdminAuditLogsScreen()),
    ];
    return Column(
      children: [
        _ModuleSection(
          title: 'Content & commerce',
          subtitle: 'The main places fans see and use',
          modules: contentModules,
        ),
        const SizedBox(height: 24),
        _ModuleSection(
          title: 'Community care',
          subtitle: 'Keep conversations helpful and respond to fans',
          modules: communityModules,
        ),
        const SizedBox(height: 24),
        _ModuleSection(
          title: 'Administration',
          subtitle: 'Control access and review important changes',
          modules: administrationModules,
        ),
      ],
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.title,
    required this.subtitle,
    required this.modules,
  });

  final String title;
  final String subtitle;
  final List<_Module> modules;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1040
              ? 3
              : constraints.maxWidth >= 650
                  ? 2
                  : 1;
          const gap = 12.0;
          final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AdminDashboard.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style:
                    const TextStyle(color: AdminDashboard.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: modules
                    .map(
                      (module) => SizedBox(
                        width: width,
                        child: _ModuleCard(module: module),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          );
        },
      );
}

class _Module {
  const _Module(this.title, this.subtitle, this.icon, this.color, this.screen);
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final Widget Function() screen;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});
  final _Module module;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => module.screen())),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AdminDashboard.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AdminDashboard.border),
            ),
            child: Row(children: [
              Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: module.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(13)),
                  child: Icon(module.icon, color: module.color)),
              const SizedBox(width: 13),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(module.title,
                        style: const TextStyle(
                            color: AdminDashboard.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(module.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AdminDashboard.muted, fontSize: 12)),
                  ])),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded,
                  color: AdminDashboard.muted, size: 19),
            ]),
          ),
        ),
      );
}
