import 'package:flutter/material.dart';

class AiHelperScreen extends StatefulWidget {
  const AiHelperScreen({super.key});

  @override
  State<AiHelperScreen> createState() => _AiHelperScreenState();
}

class _Message {
  const _Message(this.text, {required this.fromUser, this.time});
  final String text;
  final bool fromUser;
  final String? time;
}

class _AiHelperScreenState extends State<AiHelperScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _messages = <_Message>[
    const _Message(
      'Welcome to Fandom AI Assistant v2.0! 🚀\n\nI can answer questions about Anime lore, Gaming speedruns, Cosplay tips, Conventions, Merchandise, App features, and Community guidelines. What would you like to explore today?',
      fromUser: false,
    ),
  ];
  bool _thinking = false;

  final List<String> _suggestedPrompts = [
    '⚡ What is Speedrunning?',
    '📍 How to find nearby events?',
    '🛍️ Merch & Checkout help',
    '🎭 Cosplay Etiquette & Tips',
    '🐉 Tell me about Anime Fandoms',
    '📜 Fandom Lore & Glossary',
    '🛡️ Community Safety Rules',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? customText]) async {
    final question = (customText ?? _controller.text).trim();
    if (question.isEmpty || _thinking) return;
    final timeStr = TimeOfDay.now().format(context);

    setState(() {
      _messages.add(_Message(question, fromUser: true, time: timeStr));
      if (customText == null) _controller.clear();
      _thinking = true;
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final botAnswer = _answer(question);
    setState(() {
      _messages.add(
        _Message(
          botAnswer,
          fromUser: false,
          time: TimeOfDay.now().format(context),
        ),
      );
      _thinking = false;
    });
    _scrollToBottom();
  }

  String _answer(String question) {
    final query = question.toLowerCase();

    // 1. Anime & Manga
    if (query.contains('anime') ||
        query.contains('manga') ||
        query.contains('naruto') ||
        query.contains('dragon ball') ||
        query.contains('one piece') ||
        query.contains('shonen')) {
      return '⛩️ **Anime & Manga Universe**\nAnime represents Japanese animation while manga refers to graphic literature. Shonen focuses on friendship, training, and overcoming challenges (e.g., Naruto, Dragon Ball, One Piece).\n\n💡 *Tip: Check out our Beginner Hub to explore character profiles and glossary terms like Sakuga, OVA, and Mangaka!*';
    }

    // 2. Speedrunning & Gaming
    if (query.contains('speedrun') ||
        query.contains('game') ||
        query.contains('esport') ||
        query.contains('rpg') ||
        query.contains('retro')) {
      return '🎮 **Gaming & Community Speedrunning**\nCommunity speedrunning refers to fans working together to complete games or master mechanics as fast as possible, sharing glitches, routes, and records.\n\n💡 *Tip: Check out the Gaming tab in Explore to read news on community arena seasons!*';
    }

    // 3. Cosplay & Props
    if (query.contains('cosplay') ||
        query.contains('costume') ||
        query.contains('prop')) {
      return '🎭 **Cosplay Essentials & Etiquette**\nCosplay (costume play) is the art of crafting and wearing outfits inspired by characters. Always ask for permission before taking photos of cosplayers. Cosplay is for everyone regardless of skill level!\n\n💡 *Tip: Save local cosplay meetups to your offline agenda in the Events screen.*';
    }

    // 4. Events, Maps & GPS
    if (query.contains('event') ||
        query.contains('convention') ||
        query.contains('map') ||
        query.contains('gps') ||
        query.contains('meetup') ||
        query.contains('ticket')) {
      return '📍 **Location-Aware Events & Calendar**\nOur app uses GPS location services to calculate distances to nearby fan conventions, cosplay meetups, and anime screenings.\n\n💡 *Tip: Open the Events screen, tap "Sort events near me" or switch to "Map View" to explore venue pins visually!*';
    }

    // 5. Merchandise, Wishlist & Cart
    if (query.contains('merch') ||
        query.contains('store') ||
        query.contains('cart') ||
        query.contains('buy') ||
        query.contains('price') ||
        query.contains('checkout')) {
      return '🛍️ **Official Fan Merchandise & Store**\nYou can browse hoodies, pins, and journals with category filters and price sorting. Add items to your wishlist (❤️) or cart to test simulated checkouts.\n\n💡 *Note: Payments are simulated for demo purposes as specified in the SRS scope.*';
    }

    // 6. Glossary, Lore & Deep Dive
    if (query.contains('glossary') ||
        query.contains('lore') ||
        query.contains('trivia') ||
        query.contains('deep dive') ||
        query.contains('story')) {
      return '📚 **Fandom Lore & Glossary**\nOur app features 27+ rich glossary definitions and a Deep Dive hub with secret trivia facts, lore diagrams, and behind-the-scenes interviews.\n\n💡 *Tip: Tap "Deep Dive 🧠" from the profile or explore tab to unlock hidden lore!*';
    }

    // 7. Community Guidelines & Safety
    if (query.contains('safe') ||
        query.contains('report') ||
        query.contains('rule') ||
        query.contains('privacy')) {
      return '🛡️ **Community & Safety Guidelines**\nKeep discussions respectful, protect your personal identity, and report abusive behavior. Never share passwords or real banking information in public threads.';
    }

    // 8. General Fandom Definition
    if (query.contains('fandom') || query.contains('what is')) {
      return '🌟 **What is a Fandom?**\nA fandom is a vibrant subculture of passionate enthusiasts who share friendship and creativity around stories, games, art, and entertainment. They connect fans across the globe!';
    }

    // 9. Intelligent General NLP Response Fallback
    return '🤖 **Fandom Knowledge Search Result**\nRegarding "$question":\nOur Fandom Verse library includes verified guides across Anime, Gaming, Sci-Fi, Comics, and Fan Art. You can search by keywords in the Explore tab or filter content by fandom category.\n\nAsk me about:\n• ⛩️ Anime & Manga lore\n• 🎮 Gaming & Speedrunning\n• 📍 Nearby Events & Maps\n• 🛍️ Merch & Wishlist\n• 🎭 Cosplay Guidelines';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: Color(0xFFFFD740)),
            SizedBox(width: 8),
            Text('AI Fan Helper'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Clear Chat',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  const _Message(
                    'Chat history cleared. How can I assist you with fandoms, events, or lore?',
                    fromUser: false,
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Live Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFF1E1E28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Fandom AI Engine v2.0 · Online & Knowledge Base Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Suggested Prompt Chips
            SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _suggestedPrompts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (ctx, idx) {
                  final prompt = _suggestedPrompts[idx];
                  return ActionChip(
                    label: Text(prompt, style: const TextStyle(fontSize: 12)),
                    backgroundColor: const Color(0xFF2B2B36),
                    onPressed: () => _send(prompt),
                  );
                },
              ),
            ),

            const Divider(height: 1, color: Colors.white10),

            // Messages Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_thinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24242B),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox.square(
                              dimension: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFFD740),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'AI is thinking...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final message = _messages[index];
                  return Align(
                    alignment: message.fromUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: message.fromUser
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFF24242B),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(
                            message.fromUser ? 18 : 4,
                          ),
                          bottomRight: Radius.circular(
                            message.fromUser ? 4 : 18,
                          ),
                        ),
                        border: Border.all(
                          color: message.fromUser
                              ? Colors.transparent
                              : const Color(0xFFFFD740).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: message.fromUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: TextStyle(
                              color: message.fromUser
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                          if (message.time != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              message.time!,
                              style: TextStyle(
                                fontSize: 10,
                                color: message.fromUser
                                    ? Colors.black54
                                    : Colors.white38,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ask AI about anime, events, speedrunning...',
                        filled: true,
                        fillColor: const Color(0xFF1E1E28),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _thinking ? null : () => _send(),
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD740),
                      foregroundColor: Colors.black,
                    ),
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
