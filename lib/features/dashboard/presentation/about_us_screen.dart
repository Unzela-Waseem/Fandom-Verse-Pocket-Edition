import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09040E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF180A2E),
        title: const Text('About Us', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFFD946EF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.rocket_launch, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'FandomVerse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Color(0xFFA855F7), fontSize: 14),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Our Mission',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'FandomVerse is the ultimate destination for fans across all universes. Whether you are into Anime, Gaming, Sci-Fi, or Comics, we provide a unified platform to explore deep lore, connect with other fans, and experience your favorite franchises like never before using cutting-edge AR technology.',
              style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text(
              'What We Offer',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(Icons.view_in_ar, 'Interactive AR Previews'),
            _buildFeatureRow(Icons.auto_stories, 'Deep Dive Lore & Stories'),
            _buildFeatureRow(Icons.group, 'Thriving Fan Communities'),
            _buildFeatureRow(Icons.shopping_bag, 'Exclusive Merchandise'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFA855F7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE9D5FF), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
