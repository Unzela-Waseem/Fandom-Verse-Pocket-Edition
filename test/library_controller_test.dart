import 'package:fandom_verse_pocket/features/library/application/library_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('cart updates and simulated checkout creates purchase history', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(libraryProvider.notifier);

    controller.addToCart('portal-pin');
    controller.addToCart('portal-pin');
    expect(container.read(libraryProvider).cart['portal-pin'], 2);

    final order = controller.checkout();
    expect(order.quantities['portal-pin'], 2);
    expect(container.read(libraryProvider).cart, isEmpty);
    expect(container.read(libraryProvider).orders, hasLength(1));
  });

  test('bookmarks, event agenda, and wishlist toggle safely', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(libraryProvider.notifier);

    controller.toggleBookmark('beginner-multiverse');
    controller.toggleEvent('karachi-cosplay-meet');
    controller.toggleWishlist('nebula-hoodie');

    final state = container.read(libraryProvider);
    expect(state.bookmarkedContent, contains('beginner-multiverse'));
    expect(state.savedEvents, contains('karachi-cosplay-meet'));
    expect(state.wishlist, contains('nebula-hoodie'));
  });
}
