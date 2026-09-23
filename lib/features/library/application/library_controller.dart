import 'dart:convert';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_catalog.dart';
import '../domain/library_models.dart';

class LibraryState {
  const LibraryState({
    this.bookmarkedContent = const {},
    this.savedContent = const {},
    this.savedEvents = const {},
    this.savedEventDetails = const {},
    this.wishlist = const {},
    this.cart = const {},
    this.orders = const [],
    this.restored = false,
  });

  final Set<String> bookmarkedContent;
  final Map<String, ContentItem> savedContent;
  final Set<String> savedEvents;
  final Map<String, FandomEvent> savedEventDetails;
  final Set<String> wishlist;
  final Map<String, int> cart;
  final List<PurchaseOrder> orders;
  final bool restored;

  LibraryState copyWith({
    Set<String>? bookmarkedContent,
    Map<String, ContentItem>? savedContent,
    Set<String>? savedEvents,
    Map<String, FandomEvent>? savedEventDetails,
    Set<String>? wishlist,
    Map<String, int>? cart,
    List<PurchaseOrder>? orders,
    bool? restored,
  }) {
    return LibraryState(
      bookmarkedContent: bookmarkedContent ?? this.bookmarkedContent,
      savedContent: savedContent ?? this.savedContent,
      savedEvents: savedEvents ?? this.savedEvents,
      savedEventDetails: savedEventDetails ?? this.savedEventDetails,
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
  String _scope = 'preview';

  String _storageKey(String scope) => 'fandom_verse_library_v2_$scope';

  @override
  LibraryState build() {
    if (Firebase.apps.isNotEmpty) {
      _scope = FirebaseAuth.instance.currentUser?.uid ?? 'preview';
      final subscription = FirebaseAuth.instance.authStateChanges().listen((
        user,
      ) {
        final nextScope = user?.uid ?? 'preview';
        if (nextScope == _scope) return;
        _scope = nextScope;
        state = const LibraryState();
        _restore(nextScope);
      });
      ref.onDispose(subscription.cancel);
    }
    Future<void>.microtask(() => _restore(_scope));
    return const LibraryState();
  }

  Future<void> _restore(String scope) async {
    final preferences = await SharedPreferences.getInstance();
    if (scope != _scope) return;
    final stored = preferences.getString(_storageKey(scope));
    if (stored == null) {
      state = state.copyWith(restored: true);
      return;
    }
    try {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      if (scope != _scope) return;
      state = LibraryState(
        bookmarkedContent: Set<String>.from(
          json['bookmarkedContent'] as List? ?? const [],
        ),
        savedContent: (json['savedContent'] as Map? ?? const {}).map(
          (key, value) => MapEntry(
            key as String,
            ContentItem.fromJson(Map<String, dynamic>.from(value as Map)),
          ),
        ),
        savedEvents: Set<String>.from(json['savedEvents'] as List? ?? const []),
        savedEventDetails: (json['savedEventDetails'] as Map? ?? const {}).map(
          (key, value) => MapEntry(
            key as String,
            FandomEvent.fromJson(Map<String, dynamic>.from(value as Map)),
          ),
        ),
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
      if (scope == _scope) state = state.copyWith(restored: true);
    }
  }

  Future<void> _persist() async {
    final scope = _scope;
    final snapshot = state;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey(scope),
      jsonEncode({
        'bookmarkedContent': snapshot.bookmarkedContent.toList(),
        'savedContent': snapshot.savedContent.map(
          (id, item) => MapEntry(id, item.toJson()),
        ),
        'savedEvents': snapshot.savedEvents.toList(),
        'savedEventDetails': snapshot.savedEventDetails.map(
          (id, event) => MapEntry(id, event.toJson()),
        ),
        'wishlist': snapshot.wishlist.toList(),
        'cart': snapshot.cart,
        'orders': snapshot.orders.map((order) => order.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  void toggleBookmark(String id, {ContentItem? item}) {
    final next = {...state.bookmarkedContent};
    final details = {...state.savedContent};
    next.contains(id) ? next.remove(id) : next.add(id);
    if (next.contains(id) && item != null) {
      details[id] = item;
    } else if (!next.contains(id)) {
      details.remove(id);
    }
    state = state.copyWith(bookmarkedContent: next, savedContent: details);
    _persist();
  }

  void toggleEvent(String id, {FandomEvent? event}) {
    final next = {...state.savedEvents};
    final details = {...state.savedEventDetails};
    next.contains(id) ? next.remove(id) : next.add(id);
    if (next.contains(id) && event != null) {
      details[id] = event;
    } else if (!next.contains(id)) {
      details.remove(id);
    }
    state = state.copyWith(savedEvents: next, savedEventDetails: details);
    _persist();
  }

  void toggleWishlist(String id) {
    final next = {...state.wishlist};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = state.copyWith(wishlist: next);
    _persist();
  }

  void addToCart(String id, {List<Product> catalog = productCatalog}) =>
      setCartQuantity(id, (state.cart[id] ?? 0) + 1, catalog: catalog);

  void setCartQuantity(
    String id,
    int quantity, {
    List<Product> catalog = productCatalog,
  }) {
    final next = {...state.cart};
    if (quantity <= 0) {
      next.remove(id);
    } else {
      final product = catalog.firstWhere((item) => item.id == id);
      if (product.stock <= 0) return;
      next[id] = quantity.clamp(1, product.stock);
    }
    state = state.copyWith(cart: next);
    _persist();
  }

  PurchaseOrder checkout({List<Product> catalog = productCatalog}) {
    if (state.cart.isEmpty) throw StateError('Your cart is empty.');
    final total = state.cart.entries.fold<double>(0, (sum, line) {
      final product = catalog.firstWhere((item) => item.id == line.key);
      if (product.stock < line.value) {
        throw StateError('${product.name} no longer has enough stock.');
      }
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
