/// Character model for Popular Characters feature.
/// Data is bundled locally (creative/additional data, not SRS requirement).
class Character {
  const Character({
    required this.id,
    required this.name,
    required this.fandom,
    required this.description,
    required this.characterType,
    required this.imageAsset,
    this.isPopular = true,
    required this.popularityOrder,
  });

  final String id;
  final String name;
  final String fandom;
  final String description;
  final String characterType;
  final String imageAsset; // asset path or network url
  final bool isPopular;
  final int popularityOrder;
}

/// Bundled popular characters — creative additional data.
const popularCharacters = [
  Character(
    id: 'goku',
    name: 'Goku',
    fandom: 'Dragon Ball',
    description:
        'A powerful Saiyan warrior who constantly trains to become stronger. '
        'His never-give-up spirit and boundless power have made him one of the most iconic anime heroes of all time.',
    characterType: 'Anime Character',
    imageAsset: 'assets/goku-removebg-preview.png',
    popularityOrder: 1,
  ),
  Character(
    id: 'naruto',
    name: 'Naruto Uzumaki',
    fandom: 'Naruto',
    description:
        'A young ninja who dreams of becoming Hokage and gaining recognition from his village. '
        'His journey from an outcast to a hero has inspired millions of fans worldwide.',
    characterType: 'Anime Character',
    imageAsset: 'assets/naruto-removebg-preview.png',
    popularityOrder: 2,
  ),
  Character(
    id: 'luffy',
    name: 'Monkey D. Luffy',
    fandom: 'One Piece',
    description:
        'A pirate captain who dreams of finding the One Piece and becoming Pirate King. '
        'After eating a Devil Fruit, his body became as stretchy as rubber.',
    characterType: 'Anime Character',
    imageAsset: 'assets/monkeydluffy-removebg-preview.png',
    popularityOrder: 3,
  ),
  Character(
    id: 'gojo',
    name: 'Satoru Gojo',
    fandom: 'Jujutsu Kaisen',
    description:
        'A powerful jujutsu sorcerer known for his exceptional abilities and unshakeable confidence. '
        'He is considered the strongest sorcerer in the modern era.',
    characterType: 'Anime Character',
    imageAsset: 'assets/Satoru_Gojo-removebg-preview.png',
    popularityOrder: 4,
  ),
  Character(
    id: 'spiderman',
    name: 'Spider-Man',
    fandom: 'Marvel',
    description:
        'A superhero with spider-like abilities who protects New York City while balancing everyday life as Peter Parker. '
        'His motto: with great power comes great responsibility.',
    characterType: 'Marvel Superhero',
    imageAsset: 'assets/spidermman-removebg-preview.png',
    popularityOrder: 5,
  ),
  Character(
    id: 'batman',
    name: 'Batman',
    fandom: 'DC Comics',
    description:
        'A skilled hero who fights crime in Gotham City using intelligence, technology and expert combat skills. '
        'Bruce Wayne became Batman after witnessing his parents being murdered.',
    characterType: 'DC Superhero',
    imageAsset: 'assets/batman-removebg-preview.png',
    popularityOrder: 6,
  ),
  Character(
    id: 'darth_vader',
    name: 'Darth Vader',
    fandom: 'Star Wars',
    description:
        'A powerful character from the Star Wars universe associated with the dark side of the Force. '
        'Once Anakin Skywalker — a Jedi hero — he became one of the most iconic villains in cinema history.',
    characterType: 'Star Wars Character',
    imageAsset: 'assets/darthvader-removebg-preview.png',
    popularityOrder: 7,
  ),
];
