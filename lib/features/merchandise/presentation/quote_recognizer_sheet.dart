import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/services/quote_recognizer_service.dart';

class QuoteRecognizerSheet extends StatefulWidget {
  const QuoteRecognizerSheet({super.key, required this.onMatchFound});

  final ValueChanged<String> onMatchFound;

  @override
  State<QuoteRecognizerSheet> createState() => _QuoteRecognizerSheetState();
}

class _QuoteRecognizerSheetState extends State<QuoteRecognizerSheet> {
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _quoteController = TextEditingController();
  bool _speechEnabled = false;
  bool _isHandlingMatch = false;
  String _lastWords = '';
  String? _message;
  FandomQuoteMatch? _currentMatch;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final enabled = await _speechToText.initialize(
      onError: (error) {
        if (!mounted) return;
        setState(() => _message = 'Microphone error: ${error.errorMsg}');
      },
      onStatus: (_) {
        if (mounted) setState(() {});
      },
    );
    if (!mounted) return;
    setState(() {
      _speechEnabled = enabled;
      if (!enabled) {
        _message =
            'Microphone permission is unavailable. Type a quote instead.';
      }
    });
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
      return;
    }
    setState(() => _message = 'Listening for a supported quote…');
    await _speechToText.listen(
      onResult: (result) {
        if (!mounted) return;
        _recognize(result.recognizedWords, autoOpen: true);
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    if (mounted) setState(() {});
  }

  void _recognize(String words, {required bool autoOpen}) {
    final match = QuoteRecognizerService.recognize(words);
    setState(() {
      _lastWords = words;
      _quoteController.text = words;
      _currentMatch = match;
      _message = match == null
          ? 'No local match yet. Try another quote or type it below.'
          : 'Match found: ${match.character}.';
    });
    if (match != null && autoOpen) _handleMatch();
  }

  Future<void> _handleMatch() async {
    final match = _currentMatch;
    if (match == null || _isHandlingMatch) return;
    _isHandlingMatch = true;
    await _speechToText.stop();
    if (!mounted) return;
    Navigator.pop(context);
    widget.onMatchFound(match.searchQuery);
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _speechToText.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listening = _speechToText.isListening;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF140924),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quote Match',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Private local matching — no API key required.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: listening ? _stopListening : _startListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: listening ? 90 : 72,
                  height: listening ? 90 : 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentMatch != null
                        ? Colors.green
                        : (listening
                            ? Colors.redAccent
                            : const Color(0xFFE879F9)),
                    boxShadow: [
                      if (listening)
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                  child: Icon(
                    _currentMatch != null
                        ? Icons.check
                        : (listening ? Icons.mic : Icons.mic_none),
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                listening
                    ? 'Listening… say a supported quote.'
                    : 'Tap the microphone or type a quote.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quoteController,
                onSubmitted: (value) => _recognize(value, autoOpen: false),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Type or paste a quote',
                  hintText: 'Example: Avengers assemble',
                  prefixIcon: Icon(Icons.format_quote),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => _recognize(
                  _quoteController.text,
                  autoOpen: false,
                ),
                icon: const Icon(Icons.search),
                label: const Text('Match quote'),
              ),
              if (_lastWords.isNotEmpty || _message != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (_lastWords.isNotEmpty)
                        Text(
                          '“$_lastWords”',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      if (_message != null) ...[
                        if (_lastWords.isNotEmpty) const SizedBox(height: 8),
                        Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _currentMatch == null
                                ? Colors.orangeAccent
                                : Colors.greenAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (_currentMatch != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${_currentMatch!.character} · ${_currentMatch!.fandom}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: _handleMatch,
                          child: const Text('Show matching merchandise'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                'Try: ${QuoteRecognizerService.supportedQuotes.take(3).join(' · ')}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
