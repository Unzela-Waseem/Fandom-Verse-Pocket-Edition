enum ContentType {
  beginnerGuide,
  profile,
  story,
  glossary,
  news,
  gallery,
  video,
  podcast,
  deepDive,
}

class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.type,
    required this.creator,
    required this.tags,
    this.trending = false,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String category;
  final ContentType type;
  final String creator;
  final List<String> tags;
  final bool trending;
}

class FandomEvent {
  const FandomEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.venue,
    required this.date,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.ticketUrl,
  });

  final String id;
  final String title;
  final String description;
  final String city;
  final String venue;
  final DateTime date;
  final String category;
  final double latitude;
  final double longitude;
  final String ticketUrl;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    this.previousPrice,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double? previousPrice;
  final int stock;
}

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.createdAt,
    required this.quantities,
    required this.total,
  });

  final String id;
  final DateTime createdAt;
  final Map<String, int> quantities;
  final double total;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'quantities': quantities,
    'total': total,
  };

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    quantities: Map<String, int>.from(json['quantities'] as Map),
    total: (json['total'] as num).toDouble(),
  );
}
