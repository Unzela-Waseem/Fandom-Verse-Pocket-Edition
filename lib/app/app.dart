import 'package:flutter/material.dart';

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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: home ?? const AuthGate(),
    );
  }
}
