import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/connectivity_provider.dart';
import '../features/authentication/presentation/auth_gate.dart';
import 'theme/app_theme.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class FandomVerseApp extends ConsumerWidget {
  const FandomVerseApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Fandom Verse',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        Widget current = child!;
        if (!kIsWeb) {
          current = LayoutBuilder(
            builder: (context, constraints) => ColoredBox(
              color: const Color(0xFF09040E),
              child: Center(
                child: SizedBox(
                  width: constraints.maxWidth > 1100
                      ? 1100
                      : constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: child,
                ),
              ),
            ),
          );
        }
        return Column(
          children: [
            Expanded(child: current),
            if (!isOnline)
              Material(
                color: Colors.red,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    width: double.infinity,
                    child: const Text(
                      'No Internet Connection - Offline Mode',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: home ?? const AuthGate(),
    );
  }
}
