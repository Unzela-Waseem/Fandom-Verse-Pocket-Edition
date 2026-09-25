class FandomQuoteMatch {
  final String fandom;
  final String character;
  final String searchQuery;
  final String matchedQuote;

  FandomQuoteMatch({
    required this.fandom,
    required this.character,
    required this.searchQuery,
    required this.matchedQuote,
  });
}

class QuoteRecognizerService {
  // A dictionary mapping famous quotes to their respective Fandom data.
  // In a real production app, this would be backed by an NLP model or LLM backend.
  static final Map<String, FandomQuoteMatch> _quotesDb = {
    'i am iron man': FandomQuoteMatch(
      fandom: 'Marvel',
      character: 'Iron Man',
      searchQuery: 'iron',
      matchedQuote: 'I am Iron Man.',
    ),
    'avengers assemble': FandomQuoteMatch(
      fandom: 'Marvel',
      character: 'Captain America',
      searchQuery: 'marvel',
      matchedQuote: 'Avengers Assemble!',
    ),
    'dattebayo': FandomQuoteMatch(
      fandom: 'Naruto',
      character: 'Naruto Uzumaki',
      searchQuery: 'naruto',
      matchedQuote: 'Dattebayo! (Believe it!)',
    ),
    'believe it': FandomQuoteMatch(
      fandom: 'Naruto',
      character: 'Naruto Uzumaki',
      searchQuery: 'naruto',
      matchedQuote: 'Dattebayo! (Believe it!)',
    ),
    'may the force be with you': FandomQuoteMatch(
      fandom: 'Star Wars',
      character: 'Jedi',
      searchQuery: 'star wars',
      matchedQuote: 'May the force be with you.',
    ),
    'i am your father': FandomQuoteMatch(
      fandom: 'Star Wars',
      character: 'Darth Vader',
      searchQuery: 'darth',
      matchedQuote: 'No, I am your father.',
    ),
    'expecto patronum': FandomQuoteMatch(
      fandom: 'Harry Potter',
      character: 'Harry Potter',
      searchQuery: 'harry potter',
      matchedQuote: 'Expecto Patronum!',
    ),
    'you are a wizard': FandomQuoteMatch(
      fandom: 'Harry Potter',
      character: 'Hagrid',
      searchQuery: 'harry potter',
      matchedQuote: "You're a wizard, Harry.",
    ),
    'bazinga': FandomQuoteMatch(
      fandom: 'The Big Bang Theory',
      character: 'Sheldon Cooper',
      searchQuery: 'bazinga',
      matchedQuote: 'Bazinga!',
    ),
    'i am batman': FandomQuoteMatch(
      fandom: 'DC',
      character: 'Batman',
      searchQuery: 'batman',
      matchedQuote: 'I am Batman.',
    ),
  };

  /// Processes the raw spoken text and returns a match if found.
  static FandomQuoteMatch? recognize(String spokenText) {
    final lowerText = spokenText.toLowerCase().trim();
    
    // Simple substring matching for robustness
    for (final entry in _quotesDb.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }
}
