import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_catalog.dart';
import '../domain/library_models.dart';

class LibraryState {
  const LibraryState({
    this.bookmarkedContent = const {},
    this.savedEvents = const {},
    this.wishlist = const {},
    this.cart = const {},
    this.orders = const [],
    this.restored = false,
  });

  final Set<String> bookmarkedContent;
  final Set<String> savedEvents;
  final Set<String> wishlist;
  final Map<String, int> cart;
  final List<PurchaseOrder> orders;
  final bool restored;

  LibraryState copyWith({
    Set<String>? bookmarkedContent,
    Set<String>? savedEvents,
    Set<String>? wishlist,
    Map<String, int>? cart,
    List<PurchaseOrder>? orders,
    bool? restored,
  }) {
    return LibraryState(
      bookmarkedContent: bookmarkedContent ?? this.bookmarkedContent,
      savedEvents: savedEvents ?? this.savedEvents,
      wishlist: wishlist ?? this.wishlist,
      cart: cart ?? this.cart,
      orders: orders ?? this.orders,
      restored: restored ?? this.restored,
    );
  }
}

final libraryProvider = NotifierProvider<LibraryController, LibraryState>(
  LibraryController.new,
);

class LibraryController extends Notifier<LibraryState> {
  static const _storageKey = 'fandom_verse_library_v1';

  @override
  LibraryState build() {
    Future<void>.microtask(_restore);
    return const LibraryState();
  }

  Future<void> _restore() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_storageKey);
    if (stored == null) {
      state = state.copyWith(restored: true);
      return;
    }
    try {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      state = LibraryState(
        bookmarkedContent: Set<String>.from(
          json['bookmarkedContent'] as List? ?? const [],
        ),
        savedEvents: Set<String>.from(json['savedEvents'] as List? ?? const []),
        wishlist: Set<String>.from(json['wishlist'] as List? ?? const []),
        cart: Map<String, int>.from(json['cart'] as Map? ?? const {}),
        orders: (json['orders'] as List? ?? const [])
            .map(
              (item) => PurchaseOrder.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(growable: false),
        restored: true,
      );
    } catch (_) {
      state = state.copyWith(restored: true);
    }
  }

  Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode({
        'bookmarkedContent': state.bookmarkedContent.toList(),
        'savedEvents': state.savedEvents.toList(),
        'wishlist': state.wishlist.toList(),
        'cart': state.cart,
        'orders': state.orders.map((order) => order.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  void toggleBookmark(String id) {
    final next = {...state.bookmarkedContent};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = state.copyWith(bookmarkedContent: next);
    _persist();
  }

  void toggleEvent(String id) {
    final next = {...state.savedEvents};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = state.copyWith(savedEvents: next);
    _persist();
  }

  void toggleWishlist(String id) {
    final next = {...state.wishlist};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = state.copyWith(wishlist: next);
    _persist();
  }

  void addToCart(String id) => setCartQuantity(id, (state.cart[id] ?? 0) + 1);

  void setCartQuantity(String id, int quantity) {
    final product = productCatalog.firstWhere((item) => item.id == id);
    final next = {...state.cart};
    if (quantity <= 0) {
      next.remove(id);
    } else {
      next[id] = quantity.clamp(1, product.stock);
    }
    state = state.copyWith(cart: next);
    _persist();
  }

  PurchaseOrder checkout() {
    if (state.cart.isEmpty) throw StateError('Your cart is empty.');
    final total = state.cart.entries.fold<double>(0, (sum, line) {
      final product = productCatalog.firstWhere((item) => item.id == line.key);
      return sum + (product.price * line.value);
    });
    final order = PurchaseOrder(
      id: 'FV-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      quantities: {...state.cart},
      total: total,
    );
    state = state.copyWith(cart: {}, orders: [order, ...state.orders]);
    _persist();
    return order;
  }
}
