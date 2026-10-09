import 'package:flutter/foundation.dart';

@immutable
class FandomQuoteMatch {
  const FandomQuoteMatch({
    required this.fandom,
    required this.character,
    required this.searchQuery,
    required this.matchedQuote,
  });

  final String fandom;
  final String character;
  final String searchQuery;
  final String matchedQuote;
}

@immutable
class _QuoteRule {
  const _QuoteRule(this.match, this.result);

  final List<String> match;
  final FandomQuoteMatch result;
}

/// Matches a small, curated set of famous fandom dialogue entirely on-device.
/// Speech-to-text is supplied by the device or browser; after text is
/// received, matching is fully local and needs no API key or network request.
class QuoteRecognizerService {
  static const List<_QuoteRule> _rules = [
    _QuoteRule(
      ['i am iron man', 'im iron man', 'iron man'],
      FandomQuoteMatch(
        fandom: 'Marvel',
        character: 'Iron Man',
        searchQuery: 'iron',
        matchedQuote: 'I am Iron Man.',
      ),
    ),
    _QuoteRule(
      ['avengers assemble', 'captain america'],
      FandomQuoteMatch(
        fandom: 'Marvel',
        character: 'Captain America',
        searchQuery: 'marvel',
        matchedQuote: 'Avengers Assemble!',
      ),
    ),
    _QuoteRule(
      ['dattebayo', 'believe it', 'naruto'],
      FandomQuoteMatch(
        fandom: 'Naruto',
        character: 'Naruto Uzumaki',
        searchQuery: 'naruto',
        matchedQuote: 'Dattebayo! (Believe it!)',
      ),
    ),
    _QuoteRule(
      ['may the force be with you', 'star wars'],
      FandomQuoteMatch(
        fandom: 'Star Wars',
        character: 'Jedi',
        searchQuery: 'star wars',
        matchedQuote: 'May the Force be with you.',
      ),
    ),
    _QuoteRule(
      ['no i am your father', 'i am your father', 'darth vader'],
      FandomQuoteMatch(
        fandom: 'Star Wars',
        character: 'Darth Vader',
        searchQuery: 'darth',
        matchedQuote: 'No, I am your father.',
      ),
    ),
    _QuoteRule(
      ['expecto patronum', 'harry potter'],
      FandomQuoteMatch(
        fandom: 'Harry Potter',
        character: 'Harry Potter',
        searchQuery: 'harry potter',
        matchedQuote: 'Expecto Patronum!',
      ),
    ),
    _QuoteRule(
      ['you are a wizard harry', 'you are a wizard', 'hagrid'],
      FandomQuoteMatch(
        fandom: 'Harry Potter',
        character: 'Hagrid',
        searchQuery: 'harry potter',
        matchedQuote: "You're a wizard, Harry.",
      ),
    ),
    _QuoteRule(
      ['bazinga', 'sheldon cooper'],
      FandomQuoteMatch(
        fandom: 'The Big Bang Theory',
        character: 'Sheldon Cooper',
        searchQuery: 'bazinga',
        matchedQuote: 'Bazinga!',
      ),
    ),
    _QuoteRule(
      ['i am batman', 'im batman', 'batman'],
      FandomQuoteMatch(
        fandom: 'DC',
        character: 'Batman',
        searchQuery: 'batman',
        matchedQuote: 'I am Batman.',
      ),
    ),
  ];

  static List<String> get supportedQuotes => _rules
      .map((rule) => rule.result.matchedQuote)
      .toSet()
      .toList(growable: false);

  static FandomQuoteMatch? recognize(String spokenText) {
    final normalized = _normalize(spokenText);
    if (normalized.isEmpty) return null;

    for (final rule in _rules) {
      if (rule.match
          .map(_normalize)
          .any((phrase) => normalized.contains(phrase))) {
        return rule.result;
      }
    }
    return null;
  }

  static String _normalize(String text) {
    var normalized = text.toLowerCase().replaceAll(RegExp('[’\']'), '');
    normalized = normalized.replaceAll(RegExp(r'\bi[ ]?m\b'), 'i am');
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    return normalized.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
