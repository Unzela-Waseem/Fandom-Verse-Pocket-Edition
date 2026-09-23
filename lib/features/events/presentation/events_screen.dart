import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../library/application/library_controller.dart';
import '../../library/data/cloud_catalog.dart';
import '../../library/data/demo_catalog.dart';
import '../../library/domain/library_models.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String _city = 'All cities';
  Position? _position;
  bool _locating = false;
  String? _locationMessage;

  Future<void> _findNearby() async {
    if (_locating) return;
    setState(() {
      _locating = true;
      _locationMessage = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(
          () => _locationMessage =
              'Location services are turned off. You can still browse by city.',
        );
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        setState(
          () => _locationMessage =
              'Location permission was denied. You can still browse every event.',
        );
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        setState(
          () => _locationMessage =
              'Location permission is permanently denied. Enable it in system settings to sort nearby events.',
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      setState(() {
        _position = position;
        _city = 'All cities';
        _locationMessage =
            'Events are sorted by distance from your current location.';
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _locationMessage = 'Your location is unavailable right now.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cloudCatalog = ref.watch(eventCatalogProvider);
    final catalog = cloudCatalog.asData?.value ?? eventCatalog;
    final cities = [
      'All cities',
      ...{for (final event in catalog) event.city},
    ];
    final events = catalog
        .where((event) => _city == 'All cities' || event.city == _city)
        .toList(growable: false);
    if (_position != null) {
      events.sort((a, b) => _distance(a).compareTo(_distance(b)));
    }
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
          const SizedBox(height: 6),
          const Text(
            'Bundled sample events are previews, not confirmed listings.',
            style: TextStyle(color: Colors.amberAccent),
          ),
          const SizedBox(height: 12),
          if (cloudCatalog.hasError)
            const Text(
              'Cloud events are unavailable. Showing bundled events.',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          OutlinedButton.icon(
            onPressed: _locating ? null : _findNearby,
            icon: _locating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.near_me_outlined),
            label: const Text('Sort events near me'),
          ),
          if (_locationMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _locationMessage!,
                style: const TextStyle(color: Colors.white60),
              ),
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
                subtitle: Text(
                  event.isDemo
                      ? '${event.city} · Sample event'
                      : _position == null
                      ? '${event.city} · ${event.category}'
                      : '${event.city} · ${(_distance(event) / 1000).toStringAsFixed(0)} km away',
                ),
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

  double _distance(FandomEvent event) {
    final position = _position;
    if (position == null || event.isDemo) return double.infinity;
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      event.latitude,
      event.longitude,
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
          if (event.isDemo) ...[
            const SizedBox(height: 8),
            const Text(
              'Sample event only. The venue and date are illustrative; no tickets are available.',
              style: TextStyle(color: Colors.amberAccent),
            ),
          ],
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
            onPressed: event.isDemo ? null : () => _openMap(context),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Open in Google Maps'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: event.isDemo || event.ticketUrl.isEmpty
                ? null
                : () => _openTicket(context),
            icon: const Icon(Icons.confirmation_number_outlined),
            label: const Text('Open ticket link'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => ref
                .read(libraryProvider.notifier)
                .toggleEvent(event.id, event: event),
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
