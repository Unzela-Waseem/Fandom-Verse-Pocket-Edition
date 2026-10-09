class GlossaryTerm {
  const GlossaryTerm({
    required this.term,
    required this.fandom,
    required this.definition,
    required this.example,
    this.pronunciation,
    this.relatedTerms = const [],
  });

  final String term;
  final String fandom;
  final String definition;
  final String example;
  final String? pronunciation;
  final List<String> relatedTerms;
}

const beginnerGlossaryTerms = [
  // Anime
  GlossaryTerm(
    term: 'Anime',
    fandom: 'Anime',
    pronunciation: 'AH-nee-may',
    definition:
        'Japanese animated productions featuring hand-drawn or computer-generated artwork, diverse artistic styles, and storytelling across every conceivable genre.',
    example:
        'Popular examples include Naruto, Attack on Titan, and Spirited Away.',
    relatedTerms: ['Manga', 'OVA', 'Shonen', 'Seinen'],
  ),
  GlossaryTerm(
    term: 'Manga',
    fandom: 'Anime',
    pronunciation: 'MAHN-gah',
    definition:
        'Japanese comic books and graphic novels, traditionally published in black-and-white and read from right to left. Many anime series adapt popular manga.',
    example:
        'Fans often read the manga to learn the story before the anime adaptation airs.',
    relatedTerms: ['Anime', 'Mangaka', 'Tankobon'],
  ),
  GlossaryTerm(
    term: 'OVA',
    fandom: 'Anime',
    pronunciation: 'O-V-A (Original Video Animation)',
    definition:
        'Anime episodes or mini-series produced specifically for direct-to-video, DVD, or digital streaming release rather than TV broadcast or theatrical screening.',
    example:
        'Many series release special beach or backstory OVA episodes for dedicated fans.',
    relatedTerms: ['Anime', 'Filler', 'Canon'],
  ),
  GlossaryTerm(
    term: 'Cosplay',
    fandom: 'Anime',
    pronunciation: 'KOZ-play (Costume Play)',
    definition:
        'The practice and art of dressing up as a character from a movie, book, anime, or video game, often involving handcrafted armor, props, makeup, and wigs.',
    example:
        'Hundreds of fans participated in the cosplay championship dressed as their favorite shinobi.',
    relatedTerms: ['Handler', 'Armor Foam', 'Closet Cosplay'],
  ),
  GlossaryTerm(
    term: 'Shonen',
    fandom: 'Anime',
    pronunciation: 'SHOW-nen',
    definition:
        'A genre and demographic of anime and manga aimed primarily at young audiences, typically featuring action, perseverance, close friendships, and personal growth.',
    example:
        'Classic shonen anime include Naruto, Dragon Ball Z, and One Piece.',
    relatedTerms: ['Seinen', 'Filler', 'Power Scaling'],
  ),
  GlossaryTerm(
    term: 'Seinen',
    fandom: 'Anime',
    pronunciation: 'SAY-nen',
    definition:
        'A demographic of anime and manga aimed at mature or young adult audiences, highlighting psychological complexity, intricate politics, and mature themes.',
    example:
        'Series like Berserk and Ghost in the Shell are classic seinen masterpieces.',
    relatedTerms: ['Shonen', 'Manga'],
  ),
  GlossaryTerm(
    term: 'Chibi',
    fandom: 'Anime',
    pronunciation: 'CHEE-bee',
    definition:
        'An exaggeratedly cute artistic caricature style where characters are drawn small with oversized heads and simplified features, often used for humor.',
    example:
        'Short comedy skits at the end of serious anime often feature cute chibi versions of the heroes.',
    relatedTerms: ['Kawaii', 'Cosplay'],
  ),

  // Gaming
  GlossaryTerm(
    term: 'DLC',
    fandom: 'Gaming',
    pronunciation: 'D-L-C (Downloadable Content)',
    definition:
        'Additional content created for an already released video game, distributed online. DLC can include expansion packs, cosmetic skins, weapons, or story chapters.',
    example:
        'The developers released a massive story DLC expanding the futuristic arena world.',
    relatedTerms: ['Mod', 'Season Pass', 'Patch'],
  ),
  GlossaryTerm(
    term: 'Mod',
    fandom: 'Gaming',
    pronunciation: 'Mod (Modification)',
    definition:
        'A player-created modification or alteration to a video game that changes graphics, mechanics, characters, or creates entire new game modes.',
    example:
        'Community mods added new shaders, custom character skins, and community maps.',
    relatedTerms: ['DLC', 'Sandbox', 'Engine'],
  ),
  GlossaryTerm(
    term: 'Speedrun',
    fandom: 'Gaming',
    pronunciation: 'SPEED-run',
    definition:
        'The practice of playing and finishing an entire video game, level, or challenge as quickly as humanly possible, utilizing advanced movement tech and glitches.',
    example:
        'The runner broke the world record speedrun in 14 minutes and 32 seconds.',
    relatedTerms: ['Any%', 'Glitchless', 'Split'],
  ),
  GlossaryTerm(
    term: 'Easter Egg',
    fandom: 'Gaming',
    pronunciation: 'EES-ter egg',
    definition:
        'An intentional hidden secret, joke, room, or pop-culture reference placed inside a video game by developers for observant players to discover.',
    example:
        'Pressing the hidden switch in the control room revealed an easter egg room with dev autographs.',
    relatedTerms: ['Secret', 'Lore', 'Cameo'],
  ),
  GlossaryTerm(
    term: 'Respawn',
    fandom: 'Gaming',
    pronunciation: 'REE-spawn',
    definition:
        'The reappearance of a player character, enemy, or item at a predetermined anchor point after dying or being consumed in the game world.',
    example:
        'Our squad waited at the safe zone for our fallen teammate to respawn.',
    relatedTerms: ['Checkpoint', 'HP', 'Spawn Point'],
  ),
  GlossaryTerm(
    term: 'DPS',
    fandom: 'Gaming',
    pronunciation: 'D-P-S (Damage Per Second)',
    definition:
        'A statistical measurement of how much damage a character or weapon inflicts each second, or a character class role focused exclusively on offense.',
    example:
        'Our party needed one tank, one healer, and two high-DPS heroes to defeat the boss.',
    relatedTerms: ['Buff', 'Nerf', 'Tank', 'Healer'],
  ),

  // Sci-Fi
  GlossaryTerm(
    term: 'Warp Drive',
    fandom: 'Sci-Fi',
    pronunciation: 'WORP dryv',
    definition:
        'A theoretical faster-than-light (FTL) propulsion mechanism that compresses spacetime in front of a ship and expands it behind, bypassing relativistic limits.',
    example:
        'The starship engaged its warp drive to cross the Sagittarius arm in seconds.',
    relatedTerms: ['FTL', 'Hyperspace', 'Relativity'],
  ),
  GlossaryTerm(
    term: 'Dyson Sphere',
    fandom: 'Sci-Fi',
    pronunciation: 'DY-son sfeer',
    definition:
        'A hypothetical megastructure that completely encases a star to capture the vast majority or entirety of its solar energy output.',
    example:
        'The ancient alien civilization built a Dyson Sphere to power their intergalactic network.',
    relatedTerms: ['Megastructure', 'Kardashev Scale'],
  ),
  GlossaryTerm(
    term: 'Hive Mind',
    fandom: 'Sci-Fi',
    pronunciation: 'HYV mynd',
    definition:
        'A single unified telepathic or digital collective consciousness linking multiple individuals, organisms, or drones with no personal autonomy.',
    example:
        'The insectoid species operated as a seamless hive mind directed by the central queen.',
    relatedTerms: ['Cyborg', 'Collective', 'AI'],
  ),
  GlossaryTerm(
    term: 'Terraforming',
    fandom: 'Sci-Fi',
    pronunciation: 'TER-ra-form-ing',
    definition:
        'The scientific process of deliberately transforming a barren planet’s atmosphere, temperature, and surface ecology to make it hospitable for human life.',
    example:
        'Colony ships spent three centuries terraforming the red planet before civilian arrival.',
    relatedTerms: ['Biosphere', 'Atmospheric Scrubbing'],
  ),

  // Comics
  GlossaryTerm(
    term: 'Canon',
    fandom: 'Comics',
    pronunciation: 'KAN-on',
    definition:
        'The body of storylines, character backgrounds, and events officially recognized by the creators and publisher as true within the core universe continuity.',
    example:
        'While the animated movie was fun, only the monthly comic series is considered official canon.',
    relatedTerms: ['Retcon', 'Continuity', 'Lore'],
  ),
  GlossaryTerm(
    term: 'Retcon',
    fandom: 'Comics',
    pronunciation: 'RET-kon (Retroactive Continuity)',
    definition:
        'A literary technique where previously established facts or backstory in a comic universe are altered, explained away, or contradicted by a new story.',
    example:
        'The writer retconned the hero’s origins to reveal his mentor had secretly been an undercover villain.',
    relatedTerms: ['Canon', 'Reboot', 'Origin'],
  ),
  GlossaryTerm(
    term: 'Variant',
    fandom: 'Comics',
    pronunciation: 'VAIR-ee-unt',
    definition:
        'An alternate incarnation of a hero or villain from a different timeline, dimension, or reality within a broader multiverse concept.',
    example:
        'In the Marvel multiverse, heroes encounter alternate variants of themselves across different Earths.',
    relatedTerms: ['Multiverse', 'Incursion', 'Alternate Earth'],
  ),
  GlossaryTerm(
    term: 'Crossover',
    fandom: 'Comics',
    pronunciation: 'KROSS-oh-ver',
    definition:
        'A special comic story arc or event where characters or storylines from two or more independent titles meet, team up, or battle each other.',
    example:
        'The summer crossover event brought together street-level heroes and cosmic champions.',
    relatedTerms: ['Team-up', 'Variant', 'Crisis'],
  ),
  GlossaryTerm(
    term: 'Origin Story',
    fandom: 'Comics',
    pronunciation: 'OR-i-jin stor-ee',
    definition:
        'The foundational narrative explaining how a character acquired their abilities, developed their moral code, and adopted their superhero or villain identity.',
    example:
        'Every comic legend begins with a defining origin story forged through trial or tragedy.',
    relatedTerms: ['Canon', 'Protagonist', 'Mentor'],
  ),
];
