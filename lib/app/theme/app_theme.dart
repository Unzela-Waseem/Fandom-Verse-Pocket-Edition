import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFFA855F7);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      primary: const Color(0xFFA855F7),
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? const Color(0xFF2E1052)
          : const Color(0xFFE9D5FF),
      secondary: const Color(0xFFD946EF),
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? const Color(0xFF3C1245)
          : const Color(0xFFFCE7F3),
      surface: isDark ? const Color(0xFF130924) : const Color(0xFFF4F0FF),
      onSurface: isDark ? Colors.white : Colors.black87,
      surfaceContainerHigh: isDark
          ? const Color(0xFF1E0F38)
          : const Color(0xFFEBE3FF),
    );

    const scaffoldBg = Color(0xFF09040E);
    const cardBg = Color(0xFF160B28);
    const borderViolet = Color(0xFFA855F7);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? scaffoldBg : const Color(0xFFF8F5FF),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? scaffoldBg : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF180C30) : const Color(0xFFF0E6FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? borderViolet.withValues(alpha: 0.25)
                : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFA855F7), width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        color: isDark ? cardBg : Colors.white,
        shadowColor: isDark
            ? const Color(0xFFA855F7).withValues(alpha: 0.25)
            : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? borderViolet.withValues(alpha: 0.3)
                : borderViolet.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1B0E35)
            : const Color(0xFFEDE5FF),
        selectedColor: const Color(0xFFA855F7),
        labelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
          side: BorderSide(
            color: borderViolet.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected))
              return const Color(0xFFA855F7);
            return isDark ? const Color(0xFF1A0C30) : const Color(0xFFEBE0FF);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return isDark ? Colors.white70 : Colors.black87;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: borderViolet.withValues(alpha: 0.3)),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: const Color(0xFFA855F7),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFFA855F7).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(
            color: borderViolet.withValues(alpha: 0.8),
            width: 1.5,
          ),
          foregroundColor: isDark
              ? const Color(0xFFD8B4FE)
              : const Color(0xFF7E22CE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF0C0616) : Colors.white,
        indicatorColor: const Color(0xFFA855F7),
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Color(0xFFE9D5FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            );
          }
          return TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 11,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white, size: 24);
          }
          return IconThemeData(
            color: isDark ? Colors.white54 : Colors.black54,
            size: 22,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? const Color(0xFF0C0616) : Colors.white,
        indicatorColor: const Color(0xFFA855F7),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 24),
        unselectedIconTheme: IconThemeData(
          color: isDark ? Colors.white54 : Colors.black54,
          size: 22,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: Color(0xFFE9D5FF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.black54,
          fontSize: 11,
        ),
      ),
    );
  }
}
