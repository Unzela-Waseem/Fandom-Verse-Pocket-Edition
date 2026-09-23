import 'package:flutter/material.dart';
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
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
          const SizedBox(height: 14),
          Text(
            profile?.displayName ?? 'Preview Explorer',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(
            profile == null ? 'Preview mode' : profile!.badge,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFFFD740)),
          ),
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
      subtitle: const Text('Only for merchandise on your wishlist'),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About Us')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Icon(Icons.auto_awesome, size: 64, color: Color(0xFFFFD740)),
        SizedBox(height: 18),
        Text(
          'Fandom Verse Pocket Edition',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 14),
        Text(
          'A unified mobile experience for discovering fandom stories, community events, original merchandise concepts, and helpful beginner resources.',
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.55, color: Colors.white70),
        ),
        SizedBox(height: 28),
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text('Unzela Waseem'),
          subtitle: Text('Project developer and application owner'),
        ),
        SizedBox(height: 16),
        Text(
          'All demonstration content and artwork in this application is original and created for the Fandom Verse project.',
          style: TextStyle(color: Colors.white60),
        ),
      ],
    ),
  );
}
