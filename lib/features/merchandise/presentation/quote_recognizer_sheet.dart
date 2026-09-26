import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/services/quote_recognizer_service.dart';

class QuoteRecognizerSheet extends StatefulWidget {
  final Function(String query) onMatchFound;

  const QuoteRecognizerSheet({super.key, required this.onMatchFound});

  @override
  State<QuoteRecognizerSheet> createState() => _QuoteRecognizerSheetState();
}

class _QuoteRecognizerSheetState extends State<QuoteRecognizerSheet> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  FandomQuoteMatch? _currentMatch;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => debugPrint('onSpeechError: $val'),
      onStatus: (val) => debugPrint('onSpeechStatus: $val'),
    );
    setState(() {});
    
    // Auto start listening if enabled
    if (_speechEnabled) {
      _startListening();
    }
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          // Check for match
          _currentMatch = QuoteRecognizerService.recognize(_lastWords);
        });

        // If a match is found, handle it immediately!
        if (_currentMatch != null) {
          _handleMatch();
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }
  
  bool _isHandlingMatch = false;

  void _handleMatch() async {
    if (_currentMatch == null || _isHandlingMatch) return;
    _isHandlingMatch = true;
    
    // Stop listening just in case
    await _speechToText.stop();
    
    // Give user a moment to see the success state
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Close the sheet
      Navigator.pop(context);
      // Fire callback to search
      widget.onMatchFound(_currentMatch!.searchQuery);
    }
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF09040E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Fandom AI Quote Recognizer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _speechToText.isListening
                ? "Listening... Speak a famous quote!"
                : _speechEnabled
                    ? "Tap the mic to start listening..."
                    : "Microphone permission denied.",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _speechToText.isListening ? _stopListening : _startListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _speechToText.isListening ? 90 : 70,
              height: _speechToText.isListening ? 90 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentMatch != null 
                    ? Colors.green 
                    : (_speechToText.isListening ? Colors.redAccent : const Color(0xFFE879F9)),
                boxShadow: [
                  if (_speechToText.isListening)
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
                    : (_speechToText.isListening ? Icons.mic : Icons.mic_none),
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _lastWords.isEmpty ? "..." : '"$_lastWords"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                if (_currentMatch != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  Text(
                    'Matched: ${_currentMatch!.character} (${_currentMatch!.fandom})',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'Searching merch...',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  )
                ]
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
