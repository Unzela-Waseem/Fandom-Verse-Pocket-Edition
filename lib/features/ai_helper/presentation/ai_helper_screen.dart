import 'package:flutter/material.dart';

class AiHelperScreen extends StatefulWidget {
  const AiHelperScreen({super.key});

  @override
  State<AiHelperScreen> createState() => _AiHelperScreenState();
}

class _Message {
  const _Message(this.text, {required this.fromUser});
  final String text;
  final bool fromUser;
}

class _AiHelperScreenState extends State<AiHelperScreen> {
  final _controller = TextEditingController();
  final _messages = <_Message>[
    const _Message(
      'Hi! I am the Fandom Fan Helper. Ask me about cosplay, conventions, fandom terms, bookmarks, or safe community participation.',
      fromUser: false,
    ),
  ];
  bool _thinking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _thinking) return;
    setState(() {
      _messages.add(_Message(question, fromUser: true));
      _controller.clear();
      _thinking = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _messages.add(_Message(_answer(question), fromUser: false));
      _thinking = false;
    });
  }

  String _answer(String question) {
    final query = question.toLowerCase();
    if (query.contains('cosplay')) {
      return 'Cosplay means costume play. Start with a comfortable character-inspired outfit, test visibility and movement, and always ask before photographing another cosplayer.';
    }
    if (query.contains('convention') || query.contains('event')) {
      return 'Open the Events tab to filter conventions, meetups, and screenings by city. Save an event to keep its agenda available offline.';
    }
    if (query.contains('bookmark') || query.contains('offline')) {
      return 'Tap the bookmark icon on supported content. The article text and bundled media metadata are stored locally for offline access.';
    }
    if (query.contains('fandom')) {
      return 'A fandom is a community connected by enthusiasm for a story, creator, artist, sport, game, or fictional universe.';
    }
    if (query.contains('safe') || query.contains('report')) {
      return 'Protect personal information, respect creators and community rules, and report harmful content to moderators. Never share passwords or payment details in discussions.';
    }
    return 'I do not have a verified answer for that yet. Try asking about cosplay, events, offline bookmarks, fandom basics, or community safety. My answers may be imperfect.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Fan Helper')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Text(
                'Offline curated FAQ mode · Answers may be incomplete.',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_thinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
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
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: message.fromUser
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFF24242B),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.fromUser ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Ask a fandom question',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _thinking ? null : _send,
                    icon: const Icon(Icons.send),
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
