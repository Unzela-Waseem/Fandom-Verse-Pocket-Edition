import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cloud_catalog.dart';
import '../data/demo_catalog.dart';
import '../domain/beginner_hub_models.dart';
import '../domain/library_models.dart';
import 'explore_screen.dart';

class BeginnerHubScreen extends ConsumerStatefulWidget {
  const BeginnerHubScreen({super.key, this.initialFandom = 'Anime'});

  final String initialFandom;

  @override
  ConsumerState<BeginnerHubScreen> createState() => _BeginnerHubScreenState();
}

class _BeginnerHubScreenState extends ConsumerState<BeginnerHubScreen>
    with SingleTickerProviderStateMixin {
  static const _fandoms = ['Anime', 'Gaming', 'Sci-Fi', 'Comics'];
  late String _selectedFandom;
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedFandom = _fandoms.contains(widget.initialFandom)
        ? widget.initialFandom
        : _fandoms.first;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTermDetails(BuildContext context, GlossaryTerm term) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    term.term,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD740),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    term.fandom.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            if (term.pronunciation != null) ...[
              const SizedBox(height: 4),
              Text(
                'Pronounced: ${term.pronunciation}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Definition',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFD740),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              term.definition,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'In Practice / Example',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFD740),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                term.example,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.white70,
                ),
              ),
            ),
            if (term.relatedTerms.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Related Terms',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: term.relatedTerms
                    .map(
                      (rel) => Chip(
                        label: Text(rel, style: const TextStyle(fontSize: 12)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog =
        ref.watch(contentCatalogProvider).asData?.value ?? contentCatalog;
    final query = _searchQuery.toLowerCase().trim();

    // Filter glossary terms
    final glossaryTerms = beginnerGlossaryTerms.where((term) {
      final matchesFandom = term.fandom.toLowerCase() == _selectedFandom.toLowerCase();
      final matchesSearch = query.isEmpty ||
          term.term.toLowerCase().contains(query) ||
          term.definition.toLowerCase().contains(query);
      return matchesFandom && matchesSearch;
    }).toList();

    // Filter profiles for this fandom
    final profiles = catalog.where((item) {
      final matchesFandom = item.category.toLowerCase() == _selectedFandom.toLowerCase();
      final isProfile = item.type == ContentType.profile;
      final matchesSearch = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.summary.toLowerCase().contains(query);
      return matchesFandom && isProfile && matchesSearch;
    }).toList();

    // Filter stories for this fandom
    final stories = catalog.where((item) {
      final matchesFandom = item.category.toLowerCase() == _selectedFandom.toLowerCase() ||
          (item.category == 'Beginner Hub' && _selectedFandom == 'Anime');
      final isStory = item.type == ContentType.story || item.type == ContentType.beginnerGuide;
      final matchesSearch = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.summary.toLowerCase().contains(query);
      return matchesFandom && isStory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beginner Fan Hub 🌱'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD740),
          tabs: [
            Tab(
              icon: const Icon(Icons.menu_book, size: 20),
              text: 'Glossary (${glossaryTerms.length})',
            ),
            Tab(
              icon: const Icon(Icons.person_pin, size: 20),
              text: 'Profiles (${profiles.length})',
            ),
            Tab(
              icon: const Icon(Icons.auto_stories, size: 20),
              text: 'Stories (${stories.length})',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your Universe',
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
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search terms, profiles, or stories...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Glossary
                  glossaryTerms.isEmpty
                      ? _EmptyState(
                          title: 'No glossary terms found',
                          subtitle: 'Try adjusting your search query.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: glossaryTerms.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final term = glossaryTerms[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFFFD740),
                                  foregroundColor: Colors.black,
                                  child: Text(
                                    term.term.substring(0, 1),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  term.term,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(
                                  term.definition,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _showTermDetails(context, term),
                              ),
                            );
                          },
                        ),

                  // Tab 2: Profiles
                  profiles.isEmpty
                      ? _EmptyState(
                          title: 'No beginner profiles found',
                          subtitle: 'Explore all profiles from the main explore screen.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: profiles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = profiles[index];
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF332C4D),
                                  child: Icon(Icons.person, color: Colors.white70),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(item.summary),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ContentDetailScreen(item: item),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  // Tab 3: Stories
                  stories.isEmpty
                      ? _EmptyState(
                          title: 'No beginner stories found',
                          subtitle: 'Stories will be curated for this universe soon.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: stories.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = stories[index];
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF24232B),
                                  child: Icon(
                                    Icons.auto_stories,
                                    color: Color(0xFFFFD740),
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(
                                  item.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ContentDetailScreen(item: item),
                                  ),
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
              const Icon(Icons.search_off, size: 48, color: Colors.white38),
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

