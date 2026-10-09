import 'dart:ui';

import 'package:flutter/material.dart';

/// Shared page chrome. Content stays readable on desktop without restricting
/// full-bleed media or forcing a phone-sized viewport on larger devices.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    this.body,
    this.backgroundColor,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.fullBleed = false,
    this.maxContentWidth = 1200,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body, drawer, bottomNavigationBar, floatingActionButton;
  final Color? backgroundColor;
  final bool fullBleed;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: appBar,
        backgroundColor: backgroundColor,
        drawer: drawer,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        body: body == null
            ? null
            : PremiumBackdrop(
                child: fullBleed
                    ? body!
                    : ResponsiveContent(
                        maxWidth: maxContentWidth, child: body!),
              ),
      );
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent(
      {super.key, required this.child, this.maxWidth = 1200});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(
              width: double.infinity, height: double.infinity, child: child),
        ),
      );
}

class PremiumBackdrop extends StatelessWidget {
  const PremiumBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: .12),
              Colors.transparent,
            ],
          ),
        ),
        child: child,
      );
}

/// Blur is clipped to the panel, so full-screen video stays inexpensive.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 28,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              const Color(0xFF30213E).withValues(alpha: .64),
              const Color(0xFF120B20).withValues(alpha: .78),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: .18)),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

/// Content-sized tiles avoid the clipping caused by fixed aspect-ratio grids
/// when translations, long titles, or accessibility text sizes are used.
class AdaptiveCardGrid extends StatelessWidget {
  const AdaptiveCardGrid({
    super.key,
    required this.children,
    this.minCardWidth = 280,
    this.spacing = 16,
    this.maxColumns = 4,
  });
  final List<Widget> children;
  final double minCardWidth, spacing;
  final int maxColumns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final columns = ((constraints.maxWidth + spacing) /
                  (minCardWidth * scale.clamp(1, 1.5) + spacing))
              .floor()
              .clamp(1, maxColumns);
          final width =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final child in children) SizedBox(width: width, child: child)
            ],
          );
        },
      );
}

/// Stack action groups on phones instead of squeezing controls into a row.
class AdaptiveActions extends StatelessWidget {
  const AdaptiveActions({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= 520) return Row(children: children);
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final child in children)
                if (child is Flexible)
                  child.child
                else if (child is SizedBox && child.width != null)
                  const SizedBox(height: 8)
                else
                  child,
            ]);
      });
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
            ],
          ],
        ),
      );
}
