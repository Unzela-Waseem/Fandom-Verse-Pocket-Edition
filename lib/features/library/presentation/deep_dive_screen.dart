import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/deep_dive_models.dart';

class DeepDiveScreen extends ConsumerStatefulWidget {
  const DeepDiveScreen({super.key, this.initialFandom = 'All'});

  final String initialFandom;

  @override
  ConsumerState<DeepDiveScreen> createState() => _DeepDiveScreenState();
}

class _DeepDiveScreenState extends ConsumerState<DeepDiveScreen>
    with SingleTickerProviderStateMixin {
  static const _fandoms = ['All', 'Anime', 'Gaming', 'Sci-Fi', 'Comics'];
  late String _selectedFandom;
  late TabController _tabController;
  final Set<String> _revealedTrivia = {};

  @override
  void initState() {
    super.initState();
    _selectedFandom = widget.initialFandom;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter trivia
    final trivia = deepDiveTriviaList.where((item) {
      return _selectedFandom == 'All' || item.fandom == _selectedFandom;
    }).toList();

    // Filter lore
    final lore = deepDiveLoreList.where((item) {
      return _selectedFandom == 'All' || item.fandom == _selectedFandom;
    }).toList();

    // Filter behind the scenes
    final bts = deepDiveBehindTheScenesList.where((item) {
      return _selectedFandom == 'All' || item.fandom == _selectedFandom;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deep Dive 🧠'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD740),
          tabs: [
            Tab(
              icon: const Icon(Icons.psychology, size: 20),
              text: 'Hidden Trivia (${trivia.length})',
            ),
            Tab(
              icon: const Icon(Icons.account_tree, size: 20),
              text: 'Advanced Lore (${lore.length})',
            ),
            Tab(
              icon: const Icon(Icons.movie_filter, size: 20),
              text: 'Behind-the-Scenes (${bts.length})',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expert Analysis & Production Secrets',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _fandoms.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final fandom = _fandoms[index];
                        final selected = fandom == _selectedFandom;
                        return ChoiceChip(
                          label: Text(fandom),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedFandom = fandom),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Hidden Trivia (Did you know?)
                  trivia.isEmpty
                      ? const _EmptyState(
                          title: 'No trivia found for this filter',
                          subtitle: 'Select another universe or view All.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: trivia.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = trivia[index];
                            final isRevealed = _revealedTrivia.contains(item.id);
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFD740),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.fandom.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item.tag,
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.help_outline,
                                          size: 18,
                                          color: Color(0xFFFFD740),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      item.question,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (isRevealed) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(12),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFFFD740).withAlpha(80),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: const [
                                                Icon(
                                                  Icons.lightbulb,
                                                  size: 16,
                                                  color: Color(0xFFFFD740),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'SECRET REVEALED',
                                                  style: TextStyle(
                                                    color: Color(0xFFFFD740),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item.fact,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Source: ${item.source}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white54,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ] else ...[
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _revealedTrivia.add(item.id);
                                            });
                                          },
                                          icon: const Icon(Icons.visibility),
                                          label: const Text('Tap to Reveal Trivia Fact'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                  // Tab 2: Advanced Lore
                  lore.isEmpty
                      ? const _EmptyState(
                          title: 'No lore records found',
                          subtitle: 'Select another universe or view All.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: lore.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = lore[index];
                            return Card(
                              child: ExpansionTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF24232B),
                                  child: Icon(Icons.history_edu, color: Color(0xFFFFD740)),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(
                                  '${item.fandom} · ${item.timelineEra}',
                                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Divider(),
                                        Text(
                                          item.summary,
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          item.fullChronicle,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.6,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Connected Canon Elements:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFD740),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: item.connections
                                              .map(
                                                (conn) => Chip(
                                                  label: Text(conn, style: const TextStyle(fontSize: 11)),
                                                  padding: EdgeInsets.zero,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  // Tab 3: Behind-the-Scenes
                  bts.isEmpty
                      ? const _EmptyState(
                          title: 'No behind-the-scenes interviews found',
                          subtitle: 'Select another universe or view All.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: bts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = bts[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFD740),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.fandom.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.movie_creation_outlined,
                                          size: 18,
                                          color: Colors.white54,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Interview with ${item.interviewee} (${item.role})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFFD740),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item.summary,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: Text(
                                        item.insights,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.psychology_alt, size: 48, color: Colors.white38),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
}

