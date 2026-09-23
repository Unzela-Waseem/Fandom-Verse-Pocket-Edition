import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../library/application/library_controller.dart';
import '../../library/data/demo_catalog.dart';
import '../../library/domain/library_models.dart';

final _currency = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  String _query = '';
  String _category = 'All';
  bool _lowestFirst = true;

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      ...{for (final product in productCatalog) product.category},
    ];
    final products =
        productCatalog.where((product) {
          return (_category == 'All' || product.category == _category) &&
              (product.name.toLowerCase().contains(_query.toLowerCase()) ||
                  product.description.toLowerCase().contains(
                    _query.toLowerCase(),
                  ));
        }).toList()..sort(
          (a, b) => _lowestFirst
              ? a.price.compareTo(b.price)
              : b.price.compareTo(a.price),
        );
    final library = ref.watch(libraryProvider);
    final cartCount = library.cart.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Fan store',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
              ),
              Badge(
                label: Text('$cartCount'),
                isLabelVisible: cartCount > 0,
                child: IconButton.filledTonal(
                  tooltip: 'Open cart',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CartScreen()),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
            ],
          ),
          const Text(
            'Simulated checkout only. No card or payment details are collected.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search merchandise',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _category = value ?? _category),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: _lowestFirst
                    ? 'Lowest price first'
                    : 'Highest price first',
                onPressed: () => setState(() => _lowestFirst = !_lowestFirst),
                icon: Icon(
                  _lowestFirst ? Icons.arrow_upward : Icons.arrow_downward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...products.map(
            (product) => _ProductCard(
              product: product,
              wishlisted: library.wishlist.contains(product.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product, required this.wishlisted});
  final Product product;
  final bool wishlisted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFF302A48),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFFD740),
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        _currency.format(product.price),
                        style: const TextStyle(
                          color: Color(0xFFFFD740),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (product.previousPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _currency.format(product.previousPrice),
                          style: const TextStyle(
                            color: Colors.white38,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: product.stock == 0
                        ? null
                        : () => ref
                              .read(libraryProvider.notifier)
                              .addToCart(product.id),
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Add to cart'),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: wishlisted ? 'Remove from wishlist' : 'Add to wishlist',
              onPressed: () =>
                  ref.read(libraryProvider.notifier).toggleWishlist(product.id),
              icon: Icon(
                wishlisted ? Icons.favorite : Icons.favorite_border,
                color: wishlisted ? Colors.pinkAccent : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final total = library.cart.entries.fold<double>(0, (sum, line) {
      return sum +
          productCatalog.firstWhere((product) => product.id == line.key).price *
              line.value;
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: library.cart.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...library.cart.entries.map((line) {
                  final product = productCatalog.firstWhere(
                    (item) => item.id == line.key,
                  );
                  return Card(
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        '${_currency.format(product.price)} × ${line.value}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => ref
                                .read(libraryProvider.notifier)
                                .setCartQuantity(product.id, line.value - 1),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${line.value}'),
                          IconButton(
                            onPressed: () => ref
                                .read(libraryProvider.notifier)
                                .setCartQuantity(product.id, line.value + 1),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text(
                    'Simulated total',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  trailing: Text(
                    _currency.format(total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    final order = ref.read(libraryProvider.notifier).checkout();
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Demo order complete'),
                        content: Text(
                          'Order ${order.id}\nTotal: ${_currency.format(order.total)}\n\nNo payment was collected.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Complete simulated checkout'),
                ),
              ],
            ),
    );
  }
}
