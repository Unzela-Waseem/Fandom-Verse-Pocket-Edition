import 'package:flutter/material.dart';

import '../features/authentication/presentation/landing_screen.dart';
import 'theme/app_theme.dart';

class FandomVerseApp extends StatelessWidget {
  const FandomVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fandom Verse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const LandingScreen(),
    );
  }
}
