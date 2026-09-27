import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse_pocket/features/library/domain/library_models.dart';
import 'package:fandom_verse_pocket/features/notifications/data/price_drop_alert_service.dart';

Product product({
  required String id,
  required double price,
  double? previousPrice,
}) =>
    Product(
      id: id,
      name: id,
      description: 'Test product',
      category: 'Test',
      price: price,
      previousPrice: previousPrice,
      stock: 1,
    );

void main() {
  test('findPriceDrops reports only wishlisted lower prices', () {
    final drops = findPriceDrops(
      products: [
        product(id: 'lower', price: 850),
        product(id: 'same', price: 1000),
        product(id: 'not-saved', price: 500),
      ],
      wishlist: {'lower', 'same'},
      knownPrices: {'lower': 1000, 'same': 1000, 'not-saved': 900},
    );

    expect(drops, hasLength(1));
    expect(drops.single.product.id, 'lower');
    expect(drops.single.previousPrice, 1000);
  });

  test('findPriceDrops uses the product previous price on first check', () {
    final drops = findPriceDrops(
      products: [product(id: 'sale', price: 750, previousPrice: 1000)],
      wishlist: {'sale'},
      knownPrices: const {},
    );

    expect(drops.single.previousPrice, 1000);
  });
}
