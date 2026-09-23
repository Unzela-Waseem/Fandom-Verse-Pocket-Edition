import 'package:fandom_verse_pocket/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('landing screen exposes fan and admin entry points', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FandomVerseApp()));
    expect(find.text('Continue as a fan'), findsOneWidget);
    expect(find.text('Admin sign in'), findsOneWidget);
  });
}
