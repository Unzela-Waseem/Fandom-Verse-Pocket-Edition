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
    this.imageUrl,
    this.videoUrl,
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
  final String? imageUrl;
  final String? videoUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'body': body,
    'category': category,
    'type': type.name,
    'creator': creator,
    'tags': tags,
    'trending': trending,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
  };

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    return ContentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      body: json['body'] as String,
      category: json['category'] as String,
      type: ContentType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => ContentType.story,
      ),
      creator: json['creator'] as String,
      tags: List<String>.from(json['tags'] as List? ?? const []),
      trending: json['trending'] == true,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }
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
    this.isDemo = false,
    this.imageUrl,
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
  final bool isDemo;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'city': city,
    'venue': venue,
    'date': date.toIso8601String(),
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'ticketUrl': ticketUrl,
    'isDemo': isDemo,
    'imageUrl': imageUrl,
  };

  factory FandomEvent.fromJson(Map<String, dynamic> json) {
    final ticketUrl = json['ticketUrl'] as String? ?? '';
    final legacyPreview = Uri.tryParse(ticketUrl)?.host == 'example.com';
    return FandomEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      city: json['city'] as String,
      venue: json['venue'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      ticketUrl: legacyPreview ? '' : ticketUrl,
      isDemo: json['isDemo'] == true || legacyPreview,
      imageUrl: json['imageUrl'] as String?,
    );
  }
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
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double? previousPrice;
  final int stock;
  final String? imageUrl;
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
