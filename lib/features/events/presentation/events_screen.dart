import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../library/application/library_controller.dart';
import '../../library/data/demo_catalog.dart';
import '../../library/domain/library_models.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String _city = 'All cities';

  @override
  Widget build(BuildContext context) {
    final cities = [
      'All cities',
      ...{for (final event in eventCatalog) event.city},
    ];
    final events = eventCatalog.where(
      (event) => _city == 'All cities' || event.city == _city,
    );
    final saved = ref.watch(libraryProvider).savedEvents;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const Text(
            'Events',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Browse every event without granting location access.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _city,
            decoration: const InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
            items: cities
                .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
            onChanged: (value) => setState(() => _city = value ?? _city),
          ),
          const SizedBox(height: 18),
          ...events.map(
            (event) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: Container(
                  width: 54,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD740),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(event.date).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${event.date.day}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('${event.city} · ${event.category}'),
                trailing: Icon(
                  saved.contains(event.id)
                      ? Icons.bookmark
                      : Icons.chevron_right,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EventDetailScreen(event: event),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.event});

  final FandomEvent event;

  Future<void> _openMap(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maps is unavailable on this device.')),
      );
    }
  }

  Future<void> _openTicket(BuildContext context) async {
    final uri = Uri.tryParse(event.ticketUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The ticket link is unavailable.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(libraryProvider).savedEvents.contains(event.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Event details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            event.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            DateFormat('EEEE, d MMMM y · h:mm a').format(event.date),
            style: const TextStyle(color: Color(0xFFFFD740)),
          ),
          const SizedBox(height: 18),
          Text(
            event.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.55,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(event.venue),
            subtitle: Text(event.city),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openMap(context),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Open in Google Maps'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openTicket(context),
            icon: const Icon(Icons.confirmation_number_outlined),
            label: const Text('Open ticket link'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(libraryProvider.notifier).toggleEvent(event.id),
            icon: Icon(
              saved ? Icons.offline_pin : Icons.download_for_offline_outlined,
            ),
            label: Text(
              saved ? 'Saved in offline agenda' : 'Save agenda offline',
            ),
          ),
        ],
      ),
    );
  }
}
