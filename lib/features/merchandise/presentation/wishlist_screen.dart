import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../library/application/library_controller.dart';
import '../../library/data/cloud_catalog.dart';
import '../../library/data/demo_catalog.dart';

final _currency = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final catalog = ref.watch(productCatalogProvider).asData?.value ?? productCatalog;
    final wishlistProducts = catalog.where((p) => library.wishlist.contains(p.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: const Color(0xFF050B14),
        actions: [
          if (wishlistProducts.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                for (final p in wishlistProducts) {
                  final current = library.cart[p.id] ?? 0;
                  ref.read(libraryProvider.notifier).setCartQuantity(
                        p.id,
                        current + 1,
                        catalog: catalog,
                      );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All wishlist items added to cart!')),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text('Add All to Cart'),
            ),
        ],
      ),
      body: wishlistProducts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap ❤️ on any product to save it here.',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = wishlistProducts[index];
                final inCart = (library.cart[product.id] ?? 0) > 0;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          _currency.format(product.price),
                          style: const TextStyle(
                            color: Color(0xFFA855F7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (inCart)
                          const Text(
                            '✓ In cart',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 11),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Add to cart',
                          onPressed: () {
                            final current = library.cart[product.id] ?? 0;
                            ref.read(libraryProvider.notifier).setCartQuantity(
                                  product.id,
                                  current + 1,
                                  catalog: catalog,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart_outlined, color: Color(0xFFA855F7)),
                        ),
                        IconButton(
                          tooltip: 'Remove from wishlist',
                          onPressed: () {
                            ref.read(libraryProvider.notifier).toggleWishlist(product.id);
                          },
                          icon: const Icon(Icons.favorite, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
