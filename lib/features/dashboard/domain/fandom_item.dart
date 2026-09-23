import 'package:flutter/material.dart';

class FandomItem {
  const FandomItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.alignment,
  });

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final Alignment alignment;
}

const demoFandoms = [
  FandomItem(
    title: 'Arcane Realms',
    subtitle: 'Enter a world of ancient magic and hidden kingdoms.',
    category: 'Fantasy',
    icon: Icons.auto_awesome,
    color: Color(0xFF9B6DFF),
    alignment: Alignment.center,
  ),
  FandomItem(
    title: 'Neon Frontier',
    subtitle: 'Explore tomorrow’s cities, heroes, and technology.',
    category: 'Sci-Fi',
    icon: Icons.rocket_launch_outlined,
    color: Color(0xFF33C8FF),
    alignment: Alignment.centerLeft,
  ),
  FandomItem(
    title: 'Arena Pulse',
    subtitle: 'Follow competitive gaming stories and events.',
    category: 'Gaming',
    icon: Icons.sports_esports_outlined,
    color: Color(0xFFFFD740),
    alignment: Alignment.centerRight,
  ),
  FandomItem(
    title: 'Sakura Stories',
    subtitle: 'Discover anime culture, creators, and fan lore.',
    category: 'Anime',
    icon: Icons.local_florist_outlined,
    color: Color(0xFFFF6FAE),
    alignment: Alignment.bottomRight,
  ),
];
