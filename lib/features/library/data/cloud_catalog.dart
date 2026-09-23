import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/library_models.dart';
import 'demo_catalog.dart';

final contentCatalogProvider = StreamProvider<List<ContentItem>>((ref) {
  if (Firebase.apps.isEmpty) return Stream.value(contentCatalog);
  return FirebaseFirestore.instance
      .collection('content')
      .where('published', isEqualTo: true)
      .limit(100)
      .snapshots()
      .map(
        (snapshot) => _mergeCatalog(
          contentCatalog,
          snapshot.docs.map(contentFromDocument).whereType<ContentItem>(),
          (item) => item.id,
        ),
      );
});

final eventCatalogProvider = StreamProvider<List<FandomEvent>>((ref) {
  if (Firebase.apps.isEmpty) return Stream.value(eventCatalog);
  return FirebaseFirestore.instance
      .collection('events')
      .limit(100)
      .snapshots()
      .map(
        (snapshot) => _mergeCatalog(
          eventCatalog,
          snapshot.docs.map(eventFromDocument).whereType<FandomEvent>(),
          (item) => item.id,
        ),
      );
});

final productCatalogProvider = StreamProvider<List<Product>>((ref) {
  if (Firebase.apps.isEmpty) return Stream.value(productCatalog);
  return FirebaseFirestore.instance
      .collection('merchandise')
      .limit(100)
      .snapshots()
      .map(
        (snapshot) => _mergeCatalog(
          productCatalog,
          snapshot.docs.map(productFromDocument).whereType<Product>(),
          (item) => item.id,
        ),
      );
});

List<T> _mergeCatalog<T>(
  List<T> bundled,
  Iterable<T> cloud,
  String Function(T) id,
) {
  final merged = {for (final item in bundled) id(item): item};
  for (final item in cloud) {
    merged[id(item)] = item;
  }
  return merged.values.toList(growable: false);
}

ContentItem? contentFromDocument(
  QueryDocumentSnapshot<Map<String, dynamic>> document,
) {
  final data = document.data();
  final title = data['title'] as String?;
  final body = data['body'] as String?;
  if (title == null || title.isEmpty || body == null || body.isEmpty) {
    return null;
  }
  final contentType = data['contentType'] as String?;
  final type = ContentType.values.where((item) => item.name == contentType);
  return ContentItem(
    id: document.id,
    title: title,
    summary: data['summary'] as String? ?? body,
    body: body,
    category: data['categoryId'] as String? ?? 'General',
    type: type.isEmpty ? ContentType.story : type.first,
    creator: data['creator'] as String? ?? 'Fandom Verse',
    tags: (data['tags'] as List? ?? const []).whereType<String>().toList(
      growable: false,
    ),
    trending: data['trending'] == true,
    imageUrl: data['imageUrl'] as String?,
    videoUrl: data['videoUrl'] as String?,
  );
}

FandomEvent? eventFromDocument(
  QueryDocumentSnapshot<Map<String, dynamic>> document,
) {
  final data = document.data();
  final date = data['eventDate'];
  final latitude = data['latitude'];
  final longitude = data['longitude'];
  if (data['title'] is! String ||
      date is! Timestamp ||
      latitude is! num ||
      longitude is! num) {
    return null;
  }
  return FandomEvent(
    id: document.id,
    title: data['title'] as String,
    description: data['description'] as String? ?? '',
    city: data['city'] as String? ?? 'Unknown city',
    venue: data['venue'] as String? ?? '',
    date: date.toDate(),
    category: data['categoryId'] as String? ?? 'Event',
    latitude: latitude.toDouble(),
    longitude: longitude.toDouble(),
    ticketUrl: data['ticketLink'] as String? ?? '',
    imageUrl: data['imageUrl'] as String?,
  );
}

Product? productFromDocument(
  QueryDocumentSnapshot<Map<String, dynamic>> document,
) {
  final data = document.data();
  final price = data['price'];
  if (data['active'] == false ||
      data['name'] is! String ||
      price is! num ||
      price < 0) {
    return null;
  }
  final previousPrice = data['previousPrice'];
  final stock = data['stock'];
  return Product(
    id: document.id,
    name: data['name'] as String,
    description: data['description'] as String? ?? '',
    category: data['categoryId'] as String? ?? 'General',
    price: price.toDouble(),
    previousPrice: previousPrice is num ? previousPrice.toDouble() : null,
    stock: stock is num ? stock.toInt() : 0,
    imageUrl: data['imageUrl'] as String?,
  );
}
