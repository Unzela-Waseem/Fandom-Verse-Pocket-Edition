import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../core/media/remote_media.dart';
import '../../library/application/library_controller.dart';
import '../../library/domain/library_models.dart';
import 'store_screen.dart';

final _currency = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

/// Curated fallback 3D GLB models hosted on official Google & Khronos CDNs.
const Map<String, String> _fandom3DModels = {
  'Apparel': 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
  'Collectibles':
      'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/DamagedHelmet/glTF-Binary/DamagedHelmet.glb',
  'Sci-Fi Artifact':
      'https://modelviewer.dev/shared-assets/models/NeilArmstrong.glb',
  'Companion Robot':
      'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb',
  'Cyber Relic':
      'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/BoomBox/glTF-Binary/BoomBox.glb',
};

/// Selects a safe remote 3D model for the currently selected merchandise.
///
/// Store data can be edited remotely, so an empty or malformed model URL must
/// not leave the AR screen blank. In that case, a verified category fallback
/// keeps the 3D/AR preview usable.
@visibleForTesting
String? resolveArModelUrl(Product? product, {required bool useTryOn}) {
  final preferredUrl = useTryOn ? product?.tryOnModelUrl : product?.modelUrl;
  if (_isUsableRemoteModelUrl(preferredUrl)) {
    return preferredUrl!.trim();
  }

  final fallbackUrl =
      product == null ? null : _fandom3DModels[product.category];
  return _isUsableRemoteModelUrl(fallbackUrl) ? fallbackUrl!.trim() : null;
}

bool _isUsableRemoteModelUrl(String? value) {
  final url = value?.trim();
  if (url == null || url.isEmpty) return false;
  final uri = Uri.tryParse(url);
  return uri != null &&
      uri.hasScheme &&
      (uri.scheme == 'https' || uri.scheme == 'http');
}

class ARPreviewScreen extends ConsumerStatefulWidget {
  final String productName;
  final Product? product;
  final List<Product>? catalog;

  /// Lets widget tests exercise the desktop-safe UI without a native WebView.
  @visibleForTesting
  final bool forceFallbackViewer;

  const ARPreviewScreen({
    super.key,
    required this.productName,
    this.product,
    this.catalog,
    @visibleForTesting this.forceFallbackViewer = false,
  });

  @override
  ConsumerState<ARPreviewScreen> createState() => _ARPreviewScreenState();
}

class _ARPreviewScreenState extends ConsumerState<ARPreviewScreen> {
  bool _autoRotate = true;
  double _exposure = 1.0;
  int _environmentIndex = 0; // 0: Default, 1: Studio Bright, 2: Cyber Glow
  String? _activeModelUrl;
  late String _activeProductName;
  Product? _activeProduct;
  int _viewerKeyCounter = 0;
  bool _isTryOnMode = false;

  /// Starts Google's native Scene Viewer.  The embedded 3D controls are for
  /// rotating/lighting the model; this explicit action is the real camera AR
  /// entry point on Android.
  Future<void> _openAndroidAR() async {
    final modelUrl = _activeModelUrl;
    if (modelUrl == null ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final sceneViewerUri = Uri(
        scheme: 'https',
        host: 'arvr.google.com',
        path: '/scene-viewer/1.0',
        queryParameters: {
          'file': modelUrl,
          'mode': 'ar_preferred',
          'title': _activeProductName,
        },
      );
      await AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: sceneViewerUri.toString(),
        package: 'com.google.android.googlequicksearchbox',
      ).launch();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera AR needs Google Play Services for AR. Install or update it from Play Store, then try again.',
          ),
        ),
      );
    }
  }

  double _orbitX = 0.0;
  double _orbitY = 0.0;

  final List<Map<String, dynamic>> _lightingModes = [
    {'name': 'Default', 'exposure': 1.0, 'icon': Icons.wb_sunny_outlined},
    {'name': 'Studio Bright', 'exposure': 1.4, 'icon': Icons.light_mode},
    {'name': 'Cyber Mood', 'exposure': 0.7, 'icon': Icons.nightlight_round},
  ];

  bool get _canRenderModelViewer {
    if (widget.forceFallbackViewer) return false;
    if (_activeModelUrl == null) return false;
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Widget _buildDesktopFallbackViewer() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _orbitY += details.delta.dx * 0.01;
          _orbitX -= details.delta.dy * 0.01;
        });
      },
      child: Container(
        color: const Color(0xFF09040E),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_orbitX)
                  ..rotateY(_orbitY),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE879F9)
                            .withValues(alpha: 0.25 * _exposure),
                        const Color(0xFF9333EA)
                            .withValues(alpha: 0.15 * _exposure),
                        Colors.black54,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE879F9).withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE879F9)
                            .withValues(alpha: 0.3 * _exposure),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_activeProduct?.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child:
                              RemoteMediaImage(url: _activeProduct!.imageUrl!),
                        )
                      else
                        const Icon(
                          Icons.view_in_ar,
                          size: 72,
                          color: Color(0xFFE879F9),
                        ),
                      Positioned(
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Desktop preview • AR on supported phones',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Drag to rotate 3D view • Use mobile device for camera AR projection',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _activeProduct = widget.product;
    _activeProductName = widget.product?.name ?? widget.productName;
    _activeModelUrl = _resolveModelUrl(_activeProduct);
  }

  String? _resolveModelUrl(Product? product) {
    return resolveArModelUrl(product, useTryOn: _isTryOnMode);
  }

  void _switchProduct(Product product) {
    setState(() {
      _activeProduct = product;
      _activeProductName = product.name;
      if (product.tryOnModelUrl == null || product.tryOnModelUrl!.isEmpty) {
        _isTryOnMode = false;
      }
      _activeModelUrl = _resolveModelUrl(product);
      _viewerKeyCounter++;
    });
  }

  void _toggleTryOnMode() {
    setState(() {
      _isTryOnMode = !_isTryOnMode;
      _activeModelUrl = _resolveModelUrl(_activeProduct);
      _viewerKeyCounter++;
    });
  }

  void _cycleLighting() {
    setState(() {
      _environmentIndex = (_environmentIndex + 1) % _lightingModes.length;
      _exposure = _lightingModes[_environmentIndex]['exposure'] as double;
      _viewerKeyCounter++;
    });
  }

  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
    });
  }

  void _resetCamera() {
    setState(() {
      _viewerKeyCounter++;
    });
  }

  void _showARHelpSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF140924),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE879F9).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.view_in_ar,
                      color: Color(0xFFE879F9),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How Augmented Reality Works',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Interactive 3D & Real-World Projection',
                          style: TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildHelpStep(
                icon: Icons.camera_alt_outlined,
                title: 'Mobile AR (Android ARCore & iOS QuickLook)',
                description:
                    'Tap the glowing AR icon in the bottom-right corner of the 3D viewport. Point your camera at a flat surface (floor or table) and move slowly to place the item in your real room.',
              ),
              const SizedBox(height: 14),
              _buildHelpStep(
                icon: Icons.threed_rotation,
                title: '360° Interactive Inspection',
                description:
                    'Drag with one finger (or mouse left click) to orbit in 3D. Pinch or scroll to zoom. Use two fingers or right-click to pan.',
              ),
              const SizedBox(height: 14),
              _buildHelpStep(
                icon: Icons.aspect_ratio,
                title: 'Product scale depends on its 3D model',
                description:
                    'AR places the supplied 3D model in your space. Its size and resemblance to the product depend on the model provided by the store, so check the product dimensions before ordering.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE879F9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFE879F9), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final wishlisted =
        _activeProduct != null && library.wishlist.contains(_activeProduct!.id);
    final cartCount = library.cart.values.fold<int>(
      0,
      (sum, val) => sum + val,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF09040E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09040E),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AR & 3D Preview',
              style: TextStyle(fontSize: 14, color: Colors.white60),
            ),
            Text(
              _activeProductName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'AR & 3D Help',
            onPressed: _showARHelpSheet,
            icon: const Icon(Icons.help_outline),
          ),
          Badge(
            label: Text('$cartCount'),
            isLabelVisible: cartCount > 0,
            child: IconButton(
              tooltip: 'View Cart',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CartScreen()),
              ),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 3D & AR Model Viewer Viewport
          Positioned.fill(
            child: _canRenderModelViewer
                ? ModelViewer(
                    key: ValueKey('mv_${_activeModelUrl}_$_viewerKeyCounter'),
                    backgroundColor: const Color(0xFF09040E),
                    src: _activeModelUrl!,
                    alt: '3D model of $_activeProductName',
                    ar: true,
                    arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                    autoRotate: _autoRotate,
                    autoRotateDelay: 1000,
                    rotationPerSecond: '30deg',
                    cameraControls: true,
                    arScale: ArScale.auto,
                    arPlacement: ArPlacement.floor,
                    shadowIntensity: 1.0,
                    shadowSoftness: 0.8,
                    exposure: _exposure,
                    loading: Loading.eager,
                  )
                : _buildDesktopFallbackViewer(),
          ),

          // Top Badges Overlay
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE879F9).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4ADE80),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        MediaQuery.textScalerOf(context).textScaleFactor > 1.2
                            ? 'AR ready'
                            : 'AR available - scale may vary',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _lightingModes[_environmentIndex]['name'] as String,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // Floating Tools Toolbar (Right Side)
          Positioned(
            right: 16,
            top: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_activeProduct?.tryOnModelUrl != null &&
                      _activeProduct!.tryOnModelUrl!.isNotEmpty) ...[
                    IconButton(
                      tooltip: _isTryOnMode
                          ? 'View Product Model'
                          : 'View Alternate Model',
                      icon: Icon(
                        _isTryOnMode
                            ? Icons.accessibility_new
                            : Icons.checkroom,
                        color: _isTryOnMode
                            ? const Color(0xFF4ADE80)
                            : Colors.white,
                      ),
                      onPressed: _toggleTryOnMode,
                    ),
                    const SizedBox(height: 4),
                  ],
                  IconButton(
                    tooltip:
                        _autoRotate ? 'Pause Rotation' : 'Auto Rotate 360°',
                    icon: Icon(
                      _autoRotate ? Icons.sync : Icons.sync_disabled,
                      color: _autoRotate
                          ? const Color(0xFFE879F9)
                          : Colors.white54,
                    ),
                    onPressed: _toggleAutoRotate,
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    tooltip: 'Cycle Lighting Mode',
                    icon: Icon(
                      _lightingModes[_environmentIndex]['icon'] as IconData,
                      color: Colors.amberAccent,
                    ),
                    onPressed: _cycleLighting,
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    tooltip: 'Reset Camera View',
                    icon: const Icon(Icons.center_focus_strong,
                        color: Colors.white),
                    onPressed: _resetCamera,
                  ),
                ],
              ),
            ),
          ),

          // Fandom 3D Artifacts Switcher (if catalog provided)
          if (widget.catalog != null && widget.catalog!.length > 1)
            Positioned(
              left: 16,
              right: 16,
              bottom: 120,
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.catalog!.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = widget.catalog![index];
                    final isSelected = item.id == _activeProduct?.id;
                    return ActionChip(
                      avatar: Icon(
                        Icons.view_in_ar,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.white60,
                      ),
                      label: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      backgroundColor: isSelected
                          ? const Color(0xFFE879F9)
                          : Colors.black.withValues(alpha: 0.6),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFE879F9)
                            : Colors.white24,
                      ),
                      onPressed: () => _switchProduct(item),
                    );
                  },
                ),
              ),
            ),

          // Bottom Interactive Product & Purchase Card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF140924).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE879F9).withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (_activeProduct?.imageUrl != null)
                        Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: RemoteMediaImage(
                              url: _activeProduct!.imageUrl!,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _activeProduct?.category.toUpperCase() ??
                                  'COLLECTIBLE',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFE879F9),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _activeProductName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_activeProduct != null)
                              Text(
                                _currency.format(_activeProduct!.price),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4ADE80),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_activeProduct != null)
                        IconButton(
                          tooltip: wishlisted
                              ? 'Remove from wishlist'
                              : 'Add to wishlist',
                          onPressed: () {
                            ref
                                .read(libraryProvider.notifier)
                                .toggleWishlist(_activeProduct!.id);
                          },
                          icon: Icon(
                            wishlisted ? Icons.favorite : Icons.favorite_border,
                            color:
                                wishlisted ? Colors.pinkAccent : Colors.white70,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final helpButton = OutlinedButton.icon(
                        onPressed: _showARHelpSheet,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('AR Instructions'),
                      );
                      final product = _activeProduct;
                      final cartButton = product == null
                          ? null
                          : FilledButton.icon(
                              onPressed: _activeProduct!.stock == 0
                                  ? null
                                  : () {
                                      ref
                                          .read(libraryProvider.notifier)
                                          .addToCart(
                                            _activeProduct!.id,
                                            catalog: widget.catalog ??
                                                [_activeProduct!],
                                          );
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added ${_activeProduct!.name} to cart!',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                          backgroundColor:
                                              const Color(0xFF9333EA),
                                          action: SnackBarAction(
                                            label: 'View Cart',
                                            textColor: Colors.white,
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const CartScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFE879F9),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon:
                                  const Icon(Icons.add_shopping_cart, size: 16),
                              label: Text(
                                _activeProduct!.stock == 0
                                    ? 'Out of Stock'
                                    : 'Add to Cart',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                      final arButton = (!kIsWeb &&
                              defaultTargetPlatform == TargetPlatform.android)
                          ? FilledButton.icon(
                              key: const Key('open_camera_ar_button'),
                              onPressed: _activeModelUrl == null
                                  ? null
                                  : _openAndroidAR,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF6D28D9),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.view_in_ar_outlined),
                              label: const Text('Open Camera AR'),
                            )
                          : null;
                      final stackActions = constraints.maxWidth < 420 ||
                          MediaQuery.textScalerOf(context).textScaleFactor >
                              1.25;
                      if (stackActions) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            helpButton,
                            if (arButton != null) ...[
                              const SizedBox(height: 8),
                              arButton,
                            ],
                            if (cartButton != null) ...[
                              const SizedBox(height: 8),
                              cartButton,
                            ],
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: helpButton),
                          if (arButton != null) ...[
                            const SizedBox(width: 10),
                            Expanded(child: arButton),
                          ],
                          if (cartButton != null) ...[
                            const SizedBox(width: 10),
                            Expanded(flex: 2, child: cartButton),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
