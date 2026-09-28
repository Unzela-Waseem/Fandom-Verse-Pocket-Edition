import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/media/remote_media.dart';
import 'ar_preview_screen.dart';
import 'quote_recognizer_sheet.dart';
import 'wishlist_screen.dart';

import '../../library/application/library_controller.dart';
import '../../library/data/cloud_catalog.dart';
import '../../library/data/demo_catalog.dart';
import '../../library/domain/library_models.dart';

final _currency = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _category = 'All';
  bool _lowestFirst = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cloudCatalog = ref.watch(productCatalogProvider);
    final catalog = cloudCatalog.asData?.value ?? productCatalog;
    final categories = [
      'All',
      ...{for (final product in catalog) product.category},
    ];
    final selectedCategory = categories.contains(_category) ? _category : 'All';
    final products = catalog.where((product) {
      return (selectedCategory == 'All' ||
              product.category == selectedCategory) &&
          (product.name.toLowerCase().contains(_query.toLowerCase()) ||
              product.description.toLowerCase().contains(
                    _query.toLowerCase(),
                  ));
    }).toList()
      ..sort(
        (a, b) => _lowestFirst
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price),
      );
    final library = ref.watch(libraryProvider);
    final cartCount = library.cart.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    final content = SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
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
                label: Text('${library.wishlist.length}'),
                isLabelVisible: library.wishlist.isNotEmpty,
                backgroundColor: Colors.redAccent,
                child: IconButton.filledTonal(
                  tooltip: 'Open wishlist',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const WishlistScreen()),
                  ),
                  icon: const Icon(Icons.favorite_outline),
                ),
              ),
              const SizedBox(width: 8),
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
          if (cloudCatalog.hasError)
            const Text(
              'Cloud merchandise is unavailable. Showing bundled products.',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          TextField(
            controller: _searchController,
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
                  initialValue: selectedCategory,
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
                tooltip:
                    _lowestFirst ? 'Lowest price first' : 'Highest price first',
                onPressed: () => setState(() => _lowestFirst = !_lowestFirst),
                icon: Icon(
                  _lowestFirst ? Icons.arrow_upward : Icons.arrow_downward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (products.isEmpty) const Center(child: Text('No products found.')),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 280,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(
                product: product,
                wishlisted: library.wishlist.contains(product.id),
                catalog: catalog,
              );
            },
          ),
        ],
      ),
    );

    return Stack(
      children: [
        content,
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => QuoteRecognizerSheet(
                  onMatchFound: (query) {
                    setState(() {
                      _query = query;
                      _searchController.text = query;
                      _category = 'All';
                    });
                  },
                ),
              );
            },
            icon: const Icon(Icons.mic),
            label: const Text('Quote Match'),
            backgroundColor: const Color(0xFFE879F9),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({
    required this.product,
    required this.wishlisted,
    required this.catalog,
  });
  final Product product;
  final bool wishlisted;
  final List<Product> catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                RemoteMediaImage(url: product.imageUrl, fit: BoxFit.cover),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: wishlisted
                          ? 'Remove from wishlist'
                          : 'Add to wishlist',
                      onPressed: () => ref
                          .read(libraryProvider.notifier)
                          .toggleWishlist(product.id),
                      icon: Icon(
                        wishlisted ? Icons.favorite : Icons.favorite_border,
                        color: wishlisted ? Colors.pinkAccent : Colors.white,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: 'View AR',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ARPreviewScreen(
                            productName: product.name,
                            product: product,
                            catalog: catalog,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.view_in_ar,
                          color: Colors.white, size: 18),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        _currency.format(product.price),
                        style: const TextStyle(
                          color: Color(0xFFE879F9),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (product.previousPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          _currency.format(product.previousPrice),
                          style: const TextStyle(
                            color: Colors.white38,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: product.stock == 0
                        ? null
                        : () => ref
                            .read(libraryProvider.notifier)
                            .addToCart(product.id, catalog: catalog),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Add to cart',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final catalog =
        ref.watch(productCatalogProvider).asData?.value ?? productCatalog;
    final productsById = {for (final product in catalog) product.id: product};
    final invalidIds = library.cart.entries
        .where((line) {
          final product = productsById[line.key];
          return product == null || product.stock < line.value;
        })
        .map((line) => line.key)
        .toList(growable: false);
    final total = library.cart.entries.fold<double>(0, (sum, line) {
      return sum + (productsById[line.key]?.price ?? 0) * line.value;
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: library.cart.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...library.cart.entries.map((line) {
                  final product = productsById[line.key];
                  if (product == null) {
                    return Card(
                      child: ListTile(
                        title: const Text('Product no longer available'),
                        subtitle: Text(line.key),
                        trailing: IconButton(
                          tooltip: 'Remove from cart',
                          onPressed: () => ref
                              .read(libraryProvider.notifier)
                              .setCartQuantity(line.key, 0),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    );
                  }
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
                                .setCartQuantity(
                                  product.id,
                                  line.value - 1,
                                  catalog: catalog,
                                ),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${line.value}'),
                          IconButton(
                            onPressed: () => ref
                                .read(libraryProvider.notifier)
                                .setCartQuantity(
                                  product.id,
                                  line.value + 1,
                                  catalog: catalog,
                                ),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: 'Remove from cart',
                            onPressed: () => ref
                                .read(libraryProvider.notifier)
                                .setCartQuantity(
                                  product.id,
                                  0,
                                  catalog: catalog,
                                ),
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
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
                if (invalidIds.isNotEmpty)
                  const Text(
                    'Remove unavailable products or reduce quantities before checkout.',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                FilledButton(
                  onPressed: invalidIds.isNotEmpty
                      ? null
                      : () async {
                          final details = await showDialog<_CheckoutDetails>(
                            context: context,
                            builder: (_) => const _CheckoutDetailsDialog(),
                          );
                          if (details == null || !context.mounted) return;
                          final order = ref
                              .read(libraryProvider.notifier)
                              .checkout(catalog: catalog);
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
                  child: const Text('Continue to checkout'),
                ),
              ],
            ),
    );
  }
}

class _CheckoutDetails {
  const _CheckoutDetails(this.address, this.payment);
  final String address;
  final String payment;
}

class _CheckoutDetailsDialog extends StatefulWidget {
  const _CheckoutDetailsDialog();

  @override
  State<_CheckoutDetailsDialog> createState() => _CheckoutDetailsDialogState();
}

class _CheckoutDetailsDialogState extends State<_CheckoutDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _card = TextEditingController();
  String _payment = 'Cash on Delivery';

  @override
  void dispose() {
    _address.dispose();
    _card.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardPayment = _payment == 'Credit / Debit Card';
    return AlertDialog(
      title: const Text('Checkout details'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _address,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Delivery address',
                    hintText: 'House, street, city',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) => value!.trim().length < 8
                      ? 'Please enter your complete address.'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _payment,
                  decoration: const InputDecoration(
                    labelText: 'Payment method',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Cash on Delivery',
                        child: Text('Cash on Delivery')),
                    DropdownMenuItem(
                        value: 'Credit / Debit Card',
                        child: Text('Credit / Debit Card')),
                  ],
                  onChanged: (value) => setState(() => _payment = value!),
                ),
                if (cardPayment) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _card,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Card number (demo only)',
                      prefixIcon: Icon(Icons.credit_card_outlined),
                    ),
                    validator: (value) => value!.replaceAll(' ', '').length < 12
                        ? 'Enter a valid demo card number.'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'This is a simulated checkout. No card is charged or stored.',
                        style: TextStyle(fontSize: 11, color: Colors.white60)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                  context, _CheckoutDetails(_address.text.trim(), _payment));
            }
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Place demo order'),
        ),
      ],
    );
  }
}
