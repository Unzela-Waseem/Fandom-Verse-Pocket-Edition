import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../features/authentication/presentation/auth_gate.dart';
import 'theme/app_theme.dart';

class FandomVerseApp extends StatelessWidget {
  const FandomVerseApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fandom Verse',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (!kIsWeb) return child!;
        return LayoutBuilder(
          builder: (context, constraints) => ColoredBox(
            color: const Color(0xFF101014),
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
      },
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: home ?? const AuthGate(),
    );
  }
}
