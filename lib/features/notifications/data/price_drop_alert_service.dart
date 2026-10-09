import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app.dart';
import '../../library/domain/library_models.dart';

@immutable
class PriceDrop {
  const PriceDrop({
    required this.product,
    required this.previousPrice,
  });

  final Product product;
  final double previousPrice;
}

/// Finds genuine price reductions for products the fan has saved.
///
/// A bundled [Product.previousPrice] is also respected the first time a fan
/// sees a product. Later checks use the locally saved catalogue price, which
/// allows an admin price edit in Firestore to trigger an alert without a
/// Cloud Function or a paid Firebase plan.
@visibleForTesting
List<PriceDrop> findPriceDrops({
  required Iterable<Product> products,
  required Set<String> wishlist,
  required Map<String, double> knownPrices,
}) {
  final drops = <PriceDrop>[];
  for (final product in products) {
    if (!wishlist.contains(product.id)) continue;
    final previousPrice = knownPrices[product.id] ?? product.previousPrice;
    if (previousPrice != null && product.price < previousPrice) {
      drops.add(PriceDrop(product: product, previousPrice: previousPrice));
    }
  }
  return drops;
}

/// Spark-plan-safe price-drop alerts.
///
/// The app saves the most recently observed catalogue price per fan. Whenever
/// Firestore sends a lower merchandise price while the app is running, it
/// presents an in-app alert and, on supported mobile devices, a local system
/// notification. It deliberately does not use FCM, Cloud Functions, or any
/// server-side secret.
class PriceDropAlertService {
  static const _pricesKeyPrefix = 'fandom_verse_catalogue_prices_';
  static const _notifiedKeyPrefix = 'fandom_verse_price_drop_notified_';
  static const _channel = AndroidNotificationDetails(
    'fandomverse_channel',
    'FandomVerse Notifications',
    channelDescription: 'Wishlist price-drop alerts',
    importance: Importance.max,
    priority: Priority.high,
  );

  static Future<void> checkForDrops({
    required String userId,
    required Set<String> wishlist,
    required Iterable<Product> products,
  }) async {
    if (userId.isEmpty || wishlist.isEmpty) return;

    final catalogue = products.toList(growable: false);
    if (catalogue.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    final knownPrices = _readPrices(
      preferences.getString('$_pricesKeyPrefix$userId'),
    );
    final notified =
        preferences.getStringList('$_notifiedKeyPrefix$userId')?.toSet() ??
            <String>{};
    final drops = findPriceDrops(
      products: catalogue,
      wishlist: wishlist,
      knownPrices: knownPrices,
    ).where((drop) => notified.add(_dropKey(drop))).toList(growable: false);

    final latestPrices = <String, double>{
      for (final product in catalogue) product.id: product.price,
    };
    await preferences.setString(
      '$_pricesKeyPrefix$userId',
      jsonEncode(latestPrices),
    );
    await preferences.setStringList(
      '$_notifiedKeyPrefix$userId',
      notified.take(200).toList(growable: false),
    );

    if (drops.isEmpty) return;
    _showInAppAlert(drops);
    for (final drop in drops) {
      await _showLocalAlert(drop);
    }
  }

  static Map<String, double> _readPrices(String? raw) {
    if (raw == null || raw.isEmpty) return <String, double>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, double>{};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is num)
            entry.key as String: (entry.value as num).toDouble(),
      };
    } on FormatException {
      return <String, double>{};
    }
  }

  static String _dropKey(PriceDrop drop) =>
      '${drop.product.id}:${drop.product.price.toStringAsFixed(2)}';

  static void _showInAppAlert(List<PriceDrop> drops) {
    final first = drops.first.product.name;
    final message = drops.length == 1
        ? '$first is now cheaper. Check your wishlist.'
        : '${drops.length} wishlisted items are now cheaper. Check your wishlist.';
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Price drop: $message'),
        duration: const Duration(seconds: 6),
        backgroundColor: const Color(0xFF26123D),
      ),
    );
  }

  static Future<void> _showLocalAlert(PriceDrop drop) async {
    if (kIsWeb) return;
    try {
      await FlutterLocalNotificationsPlugin().show(
        _dropKey(drop).hashCode,
        'Price drop: ${drop.product.name}',
        'Now ${drop.product.price.toStringAsFixed(0)} (was ${drop.previousPrice.toStringAsFixed(0)}).',
        const NotificationDetails(
          android: _channel,
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (_) {
      // The in-app snackbar is still available if the device blocks alerts.
    }
  }
}
