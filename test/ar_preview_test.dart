import 'package:fandom_verse_pocket/features/library/application/library_controller.dart';
import 'package:fandom_verse_pocket/features/library/data/demo_catalog.dart';
import 'package:fandom_verse_pocket/features/library/domain/library_models.dart';
import 'package:fandom_verse_pocket/features/merchandise/presentation/ar_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testProduct = Product(
    id: 'nebula-hoodie',
    name: 'Nebula Explorer Hoodie',
    description: 'Original Fandom Verse embroidered hoodie.',
    category: 'Apparel',
    price: 6499,
    stock: 20,
    modelUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
  );

  group('AR Preview Screen Tests', () {
    testWidgets('Renders AR Preview with badges and controls', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ARPreviewScreen(
              productName: 'Nebula Explorer Hoodie',
              product: testProduct,
              catalog: productCatalog,
            ),
          ),
        ),
      );
      await tester.pump();

      // Check header
      expect(find.text('AR & 3D Preview'), findsOneWidget);
      expect(find.text('Nebula Explorer Hoodie'), findsAtLeastNWidgets(1));

      // Check AR badges
      expect(find.text('AR Ready • 1:1 Scale'), findsOneWidget);

      // Check bottom card details
      expect(find.text('APPAREL'), findsOneWidget);
      expect(find.textContaining('PKR'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('AR Instructions'), findsOneWidget);

      // Check interactive toolbar icons
      expect(find.byIcon(Icons.sync), findsOneWidget);
      expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);
    });

    testWidgets('AR Instructions bottom sheet opens and displays guides', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ARPreviewScreen(
              productName: 'Nebula Explorer Hoodie',
              product: testProduct,
              catalog: productCatalog,
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap AR Instructions button
      await tester.tap(find.text('AR Instructions'));
      await tester.pumpAndSettle();

      // Check instructions content
      expect(find.text('How Augmented Reality Works'), findsOneWidget);
      expect(find.textContaining('Mobile AR (Android ARCore'), findsOneWidget);
      expect(find.textContaining('360° Interactive Inspection'), findsOneWidget);
      expect(find.textContaining('True 1:1 Scale Accuracy'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Got it!'));
      await tester.pumpAndSettle();

      expect(find.text('How Augmented Reality Works'), findsNothing);
    });

    testWidgets('Add to cart from AR preview adds item to cart', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ARPreviewScreen(
              productName: 'Nebula Explorer Hoodie',
              product: testProduct,
              catalog: productCatalog,
            ),
          ),
        ),
      );
      await tester.pump();

      // Initially cart is empty
      expect(container.read(libraryProvider).cart.containsKey(testProduct.id), isFalse);

      // Tap Add to Cart
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();

      // Verify item added to cart
      expect(container.read(libraryProvider).cart[testProduct.id], equals(1));
    });

    testWidgets('Toggle auto-rotate and cycle lighting toolbar buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ARPreviewScreen(
              productName: 'Nebula Explorer Hoodie',
              product: testProduct,
              catalog: productCatalog,
            ),
          ),
        ),
      );
      await tester.pump();

      // Check initial lighting mode is Default
      expect(find.text('Default'), findsOneWidget);

      // Toggle auto-rotate
      await tester.tap(find.byTooltip('Pause Rotation'));
      await tester.pump();
      expect(find.byTooltip('Auto Rotate 360°'), findsOneWidget);

      // Cycle lighting
      await tester.tap(find.byTooltip('Cycle Lighting Mode'));
      await tester.pump();
      expect(find.text('Studio Bright'), findsOneWidget);
    });
  });
}
