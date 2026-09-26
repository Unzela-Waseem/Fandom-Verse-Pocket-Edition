import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../ai_helper/presentation/ai_helper_screen.dart';
import '../../authentication/application/auth_providers.dart';
import '../../authentication/domain/app_user.dart';
import '../../contact/presentation/contact_screen.dart';
import '../../discussions/presentation/discussions_screen.dart';
import '../../events/presentation/events_screen.dart';
import '../../library/application/library_controller.dart';
import '../../library/data/cloud_catalog.dart';
import '../../library/data/demo_catalog.dart';
import '../../library/domain/library_models.dart';
import '../../library/presentation/explore_screen.dart';
import '../../notifications/data/notification_device_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.profile});

  final AppUser? profile;

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final avatarUrl = profile?.avatarUrl;
    final validAvatarUrl =
        avatarUrl != null && Uri.tryParse(avatarUrl)?.scheme == 'https';
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFF160B28),
                backgroundImage: validAvatarUrl
                    ? NetworkImage(avatarUrl)
                    : null,
                child: !validAvatarUrl
                    ? const Icon(
                        Icons.person,
                        size: 42,
                        color: Color(0xFFE9D5FF),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile?.displayName ?? 'Preview Explorer',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            profile == null ? 'Preview mode' : profile!.badge,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFE879F9),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (profile?.bio.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                profile!.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (profile?.selectedFandoms.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Center(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: profile!.selectedFandoms
                    .map(
                      (fandom) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B0E35),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: const Color(0xFFA855F7).withAlpha(140),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 12,
                              color: Color(0xFFD946EF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              fandom,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              _CountCard(
                label: 'Offline',
                value: library.bookmarkedContent.length,
              ),
              _CountCard(label: 'Wishlist', value: library.wishlist.length),
              _CountCard(label: 'Orders', value: library.orders.length),
            ],
          ),
          const SizedBox(height: 20),
          if (library.syncFailed)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Some saved changes could not sync. They remain on this device; reconnect and try again.',
                style: TextStyle(color: Colors.orangeAccent),
              ),
            ),
          if (profile != null)
            _ProfileTile(
              icon: Icons.edit_outlined,
              title: 'Edit profile',
              subtitle: 'Update bio, badge, and favorite fandoms',
              onTap: () => _open(context, EditProfileScreen(profile: profile!)),
            ),
          if (profile != null) _NotificationPreferenceTile(profile: profile!),
          _ProfileTile(
            icon: Icons.smart_toy_outlined,
            title: 'AI Fan Helper',
            subtitle: 'Offline curated fandom answers',
            onTap: () => _open(context, const AiHelperScreen()),
          ),
          _ProfileTile(
            icon: Icons.forum_outlined,
            title: 'Community',
            subtitle: 'Create and manage discussions',
            onTap: () => _open(context, const DiscussionsScreen()),
          ),
          _ProfileTile(
            icon: Icons.bookmarks_outlined,
            title: 'Saved & offline',
            subtitle:
                '${library.bookmarkedContent.length} content items · ${library.savedEvents.length} events',
            onTap: () => _open(context, const _SavedScreen()),
          ),
          _ProfileTile(
            icon: Icons.receipt_long_outlined,
            title: 'Purchase history',
            subtitle: '${library.orders.length} simulated orders',
            onTap: () => _open(context, const _PurchaseHistoryScreen()),
          ),
          _ProfileTile(
            icon: Icons.contact_support_outlined,
            title: 'Contact Us',
            subtitle: 'Submit a secure inquiry',
            onTap: () => _open(context, const ContactScreen()),
          ),
          _ProfileTile(
            icon: Icons.info_outline,
            title: 'About Us',
            subtitle: 'Project purpose and team',
            onTap: () => _open(context, const _AboutScreen()),
          ),
          if (profile != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.read(authServiceProvider).signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _NotificationPreferenceTile extends StatefulWidget {
  const _NotificationPreferenceTile({required this.profile});

  final AppUser profile;

  @override
  State<_NotificationPreferenceTile> createState() =>
      _NotificationPreferenceTileState();
}

class _NotificationPreferenceTileState
    extends State<_NotificationPreferenceTile> {
  bool _busy = false;

  Future<void> _change(bool enabled) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (enabled) {
        final granted = await NotificationDeviceService.enable(
          widget.profile.uid,
        );
        if (!granted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notification permission was not granted. You can enable it later in device settings.',
              ),
            ),
          );
        }
      } else {
        await NotificationDeviceService.disable(widget.profile.uid);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification settings could not be saved.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: SwitchListTile(
      secondary: const Icon(Icons.notifications_outlined),
      title: const Text('Price-drop alerts'),
      subtitle: Text(
        kIsWeb
            ? 'In-app alerts only; browser push is not configured'
            : 'Only for merchandise on your wishlist',
      ),
      value: widget.profile.priceDropNotifications,
      onChanged: _busy ? null : _change,
    ),
  );
}

class _SavedScreen extends ConsumerWidget {
  const _SavedScreen();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryProvider);
    final availableContent =
        ref.watch(contentCatalogProvider).asData?.value ?? contentCatalog;
    final availableEvents =
        ref.watch(eventCatalogProvider).asData?.value ?? eventCatalog;
    final contentById = {
      for (final item in state.savedContent.values) item.id: item,
      for (final item in availableContent) item.id: item,
    };
    final eventsById = {
      for (final event in state.savedEventDetails.values) event.id: event,
      for (final event in availableEvents) event.id: event,
    };
    final content = state.bookmarkedContent
        .map((id) => contentById[id])
        .whereType<ContentItem>();
    final events = state.savedEvents
        .map((id) => eventsById[id])
        .whereType<FandomEvent>();
    return Scaffold(
      appBar: AppBar(title: const Text('Saved & offline')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Content',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          if (content.isEmpty)
            const ListTile(title: Text('No offline content saved.')),
          ...content.map(
            (item) => ListTile(
              title: Text(item.title),
              subtitle: Text(item.category),
              leading: const Icon(Icons.offline_pin),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ContentDetailScreen(item: item),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Event agenda',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          if (events.isEmpty) const ListTile(title: Text('No events saved.')),
          ...events.map(
            (event) => ListTile(
              title: Text(event.title),
              subtitle: Text(
                '${event.city} · ${DateFormat.yMMMd().format(event.date)}',
              ),
              leading: const Icon(Icons.event_available),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EventDetailScreen(event: event),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseHistoryScreen extends ConsumerWidget {
  const _PurchaseHistoryScreen();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(libraryProvider).orders;
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase history')),
      body: orders.isEmpty
          ? const Center(child: Text('No simulated purchases yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (_, index) {
                final order = orders[index];
                return Card(
                  child: ListTile(
                    title: Text(order.id),
                    subtitle: Text(
                      '${DateFormat.yMMMd().add_jm().format(order.createdAt)} · ${order.quantities.length} products',
                    ),
                    trailing: Text('PKR ${order.total.toStringAsFixed(0)}'),
                  ),
                );
              },
            ),
    );
  }
}

class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF050B14),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // ── Header ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A0533), Color(0xFF0A1628)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FBE), Color(0xFF2979FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B2FBE).withValues(alpha: 0.4),
                        blurRadius: 20, spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, size: 34, color: Colors.white),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Fandom Verse',
                  style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900,
                    color: Colors.white, letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'POCKET EDITION',
                  style: TextStyle(
                    fontSize: 12, letterSpacing: 4,
                    color: Color(0xFF00E5FF), fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                    border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'TechWiz World Tech Championship',
                    style: TextStyle(fontSize: 11, color: Color(0xFF90CAF9)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── About the App ──────────────────────────────────
          const Text(
            '📱 About the App',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Text(
              'Fandom Verse Pocket Edition is a cross-platform mobile app that connects fans from Anime, Gaming, Comics, Sci-Fi, K-Pop, and Cosplay communities. It provides fandom stories, lore exploration, nearby events, fan merchandise, and an AI-powered helper — all in one app.',
              style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 13.5),
            ),
          ),
          const SizedBox(height: 24),

          // ── Developer ──────────────────────────────────────
          const Text(
            '👩‍💻 Developer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7B2FBE).withValues(alpha: 0.15),
                  const Color(0xFF7B2FBE).withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: const Color(0xFF7B2FBE).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF7B2FBE), Color(0xFF9C4DCC)],
                    ),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unzela Waseem', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    SizedBox(height: 3),
                    Text('Lead Developer & Project Owner', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('Aptech North Karachi', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Key Features ───────────────────────────────────
          const Text(
            '✨ Key Features',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 10),
          _featureItem('⛩️ Fandom Lore & Glossary', 'Explore stories, glossary terms, and deep dive trivia across multiple fandoms.'),
          _featureItem('📍 Events & Conventions', 'Discover nearby fan events with GPS-based location sorting and offline agenda.'),
          _featureItem('🛍️ Fan Merchandise Store', 'Browse, wishlist, and checkout official fandom merchandise.'),
          _featureItem('🤖 AI Fan Helper', 'Get instant answers about fandoms, app features, and cosplay tips.'),
          _featureItem('🔔 Price Drop Alerts', 'Get notified when a wishlisted product goes on sale.'),
          _featureItem('📶 Offline Mode', 'Save articles, events, and stories for offline reading.'),
          const SizedBox(height: 24),

          // ── Contact ────────────────────────────────────────
          const Text(
            '📬 Contact',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Column(
              children: [
                _ContactRow(icon: Icons.email_outlined, label: 'unzelawaseem3@gmail.com'),
                SizedBox(height: 8),
                _ContactRow(icon: Icons.phone_outlined, label: '+92 316 2705226'),
                SizedBox(height: 8),
                _ContactRow(icon: Icons.location_on_outlined, label: 'North Karachi, Pakistan'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Footer ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF00E5FF), size: 24),
                const SizedBox(height: 6),
                const Text('Version 1.0.0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '© 2024 Fandom Verse Pocket Edition\nAll content is original and created for this project.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _featureItem(String title, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.substring(0, 2), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.substring(3), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: const Color(0xFF00E5FF)),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
    ],
  );
}

