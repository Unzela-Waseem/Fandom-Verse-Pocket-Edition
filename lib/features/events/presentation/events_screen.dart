import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/media/remote_media.dart';

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
  bool _showMapView = false;
  FandomEvent? _selectedMapEvent;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Events',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('List'),
                    icon: Icon(Icons.format_list_bulleted, size: 16),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Map'),
                    icon: Icon(Icons.map_outlined, size: 16),
                  ),
                ],
                selected: {_showMapView},
                onSelectionChanged: (set) {
                  setState(() => _showMapView = set.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Browse convention schedules, meetups, and venue locations.',
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
            label: Text(_position == null ? 'Sort events near me (GPS)' : 'GPS Active: Refresh Nearby'),
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
              labelText: 'City Filter',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
            items: cities
                .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
            onChanged: (value) => setState(() => _city = value ?? _city),
          ),
          const SizedBox(height: 18),

          if (_showMapView) ...[
            _InteractiveEventMapContainer(
              events: events,
              userPosition: _position,
              selectedEvent: _selectedMapEvent,
              onSelectEvent: (event) {
                setState(() => _selectedMapEvent = event);
                _showEventBottomSheet(context, event);
              },
            ),
            const SizedBox(height: 20),
          ],

          Text(
            _showMapView ? 'Upcoming Venues on Map (${events.length})' : 'All Upcoming Events (${events.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
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
                  _position == null
                      ? '${event.city} · ${event.venue}'
                      : '${event.city} · ${(_distance(event) / 1000).toStringAsFixed(0)} km away',
                ),
                trailing: Icon(
                  saved.contains(event.id)
                      ? Icons.bookmark
                      : Icons.chevron_right,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EventDetailScreen(event: event, userPosition: _position),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventBottomSheet(BuildContext context, FandomEvent event) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place, color: Color(0xFFFFD740)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${event.venue}, ${event.city}'),
            const SizedBox(height: 4),
            Text(
              'Coordinates: ${event.latitude.toStringAsFixed(4)}°, ${event.longitude.toStringAsFixed(4)}°',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EventDetailScreen(event: event, userPosition: _position),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Event Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _distance(FandomEvent event) {
    final position = _position;
    if (position == null) return double.infinity;
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      event.latitude,
      event.longitude,
    );
  }
}

/// Interactive Stylized GPS Event Map Container
class _InteractiveEventMapContainer extends StatelessWidget {
  const _InteractiveEventMapContainer({
    required this.events,
    this.userPosition,
    this.selectedEvent,
    required this.onSelectEvent,
  });

  final List<FandomEvent> events;
  final Position? userPosition;
  final FandomEvent? selectedEvent;
  final ValueChanged<FandomEvent> onSelectEvent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD740).withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Map Background Grid Graphic
          Positioned.fill(
            child: CustomPaint(
              painter: _FandomMapGridPainter(),
            ),
          ),

          // Map Title Header
          Positioned(
            top: 12,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_sharp, color: Color(0xFFFFD740), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    userPosition != null
                        ? 'GPS Radar Active · ${events.length} Venues Pinned'
                        : 'Interactive Fandom Venue Map (${events.length})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Interactive Pins layout
          Positioned.fill(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                if (events.isEmpty) {
                  return const Center(
                    child: Text('No event venues in this city', style: TextStyle(color: Colors.white54)),
                  );
                }
                return Stack(
                  children: events.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final event = entry.value;

                    // Compute relative X/Y coordinate positions on screen based on index/location
                    final posX = (constraints.maxWidth * 0.18) + ((idx % 3) * (constraints.maxWidth * 0.30));
                    final posY = (constraints.maxHeight * 0.28) + ((idx ~/ 3) * 60.0);
                    final isSelected = selectedEvent?.id == event.id;

                    return Positioned(
                      left: posX.clamp(10.0, constraints.maxWidth - 70.0),
                      top: posY.clamp(40.0, constraints.maxHeight - 70.0),
                      child: GestureDetector(
                        onTap: () => onSelectEvent(event),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFD740) : const Color(0xFF6C5CE7),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isSelected ? const Color(0xFFFFD740) : const Color(0xFF6C5CE7)).withValues(alpha: 0.6),
                                    blurRadius: isSelected ? 14 : 6,
                                    spreadRadius: isSelected ? 3 : 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.place,
                                color: isSelected ? Colors.black : Colors.white,
                                size: isSelected ? 20 : 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isSelected ? const Color(0xFFFFD740) : Colors.white24),
                              ),
                              child: Text(
                                event.city,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? const Color(0xFFFFD740) : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FandomMapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.0;

    const step = 25.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final ringPaint = Paint()
      ..color = const Color(0xFFFFD740).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 60, ringPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 110, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.event, this.userPosition});

  final FandomEvent event;
  final Position? userPosition;

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

  Future<void> _openOpenStreetMap(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=${event.latitude}&mlon=${event.longitude}#map=15/${event.latitude}/${event.longitude}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OpenStreetMap link could not be launched.')),
      );
    }
  }

  Future<void> _openTicket(BuildContext context) async {
    final uri = Uri.tryParse(event.ticketUrl);
    if (event.ticketUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sample event preview. Ticket links open live external bookings when added via Admin Panel.',
            ),
          ),
        );
      }
      return;
    }
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
    double? distKm;
    if (userPosition != null) {
      distKm = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        event.latitude,
        event.longitude,
      ) / 1000;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Event details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (isHttpsMediaUrl(event.imageUrl)) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: RemoteMediaImage(url: event.imageUrl),
              ),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            event.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          if (event.isDemo) ...[
            const SizedBox(height: 8),
            const Text(
              'Sample event preview. Tap below to navigate to venue coordinates.',
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

          // Interactive Venue Location & Map Card
          Card(
            color: const Color(0xFF1E1E28),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_drop, color: Color(0xFFFFD740)),
                      const SizedBox(width: 8),
                      const Text(
                        'Venue Location & Coordinates',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (distKm != null) ...[
                        const Spacer(),
                        Chip(
                          backgroundColor: const Color(0xFF6C5CE7),
                          labelStyle: const TextStyle(fontSize: 11, color: Colors.white),
                          label: Text('📍 ${distKm.toStringAsFixed(0)} km away'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${event.venue} — ${event.city}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'GPS: ${event.latitude.toStringAsFixed(4)}° N, ${event.longitude.toStringAsFixed(4)}° E',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '${event.latitude},${event.longitude}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coordinates copied to clipboard!')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy GPS'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openOpenStreetMap(context),
                          icon: const Icon(Icons.map, size: 16),
                          label: const Text('OpenStreet'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
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
