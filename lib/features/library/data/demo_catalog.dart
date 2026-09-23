import '../domain/library_models.dart';

const contentCatalog = [
  ContentItem(
    id: 'beginner-multiverse',
    title: 'Your first journey through the multiverse',
    summary:
        'A welcoming guide to fandom communities, language, and etiquette.',
    body:
        'Fandom is built around shared enthusiasm. Start by choosing a world you enjoy, learn its common terms, and join conversations with curiosity and respect. Save this guide for offline access before your first event.',
    category: 'Beginner Hub',
    type: ContentType.beginnerGuide,
    creator: 'Fandom Verse Editorial',
    tags: ['beginner', 'community'],
    trending: true,
  ),
  ContentItem(
    id: 'profile-nova-lee',
    title: 'Creator profile: Nova Lee',
    summary: 'Meet an independent illustrator building luminous sci-fi worlds.',
    body:
        'Nova Lee combines architectural sketches with vibrant cosmic color. Her community workshops help new artists develop original worlds while respecting the work of other creators.',
    category: 'Sci-Fi',
    type: ContentType.profile,
    creator: 'Ari Studio',
    tags: ['creator', 'art'],
  ),
  ContentItem(
    id: 'story-last-starlight',
    title: 'The Last Starlight Archive',
    summary:
        'An original short fan story about a library at the edge of space.',
    body:
        'At the edge of mapped space, every forgotten story becomes a star. Mina, the archive keeper, discovers one light that refuses to fade and follows it toward a civilization missing from every chart.',
    category: 'Sci-Fi',
    type: ContentType.story,
    creator: 'Fandom Verse Community',
    tags: ['story', 'space'],
  ),
  ContentItem(
    id: 'glossary-cosplay',
    title: 'Glossary: Cosplay essentials',
    summary: 'From armor foam to closet cosplay, learn the most useful terms.',
    body:
        'Cosplay means costume play. A build log documents progress, a handler assists a cosplayer at events, and closet cosplay creates a recognizable look from everyday clothing.',
    category: 'Glossary',
    type: ContentType.glossary,
    creator: 'Fandom Verse Editorial',
    tags: ['cosplay', 'terms'],
  ),
  ContentItem(
    id: 'news-arena-season',
    title: 'Community arena season announced',
    summary:
        'Local teams will compete across four weekends with beginner brackets.',
    body:
        'The new community season includes accessible beginner brackets, coaching sessions, and a code of conduct designed for welcoming competition.',
    category: 'Gaming',
    type: ContentType.news,
    creator: 'Arena Desk',
    tags: ['esports', 'news'],
    trending: true,
  ),
  ContentItem(
    id: 'gallery-world-builders',
    title: 'Gallery: Worlds built by fans',
    summary:
        'A curated metadata collection of original environments and costumes.',
    body:
        'This gallery celebrates original fan-created environments. Image downloads are represented by the bundled project artwork so saved gallery metadata remains available offline.',
    category: 'Art',
    type: ContentType.gallery,
    creator: 'Community Gallery',
    tags: ['gallery', 'art'],
  ),
  ContentItem(
    id: 'podcast-lore-room',
    title: 'Podcast: Inside the lore room',
    summary:
        'Writers discuss consistent world-building without overwhelming new fans.',
    body:
        'The episode explores timelines, character motivation, and how a glossary can make deep fictional histories more welcoming.',
    category: 'Fantasy',
    type: ContentType.podcast,
    creator: 'Verse Audio',
    tags: ['podcast', 'lore'],
  ),
  ContentItem(
    id: 'deep-dive-hidden-symbols',
    title: 'Deep Dive: Hidden symbols in imagined cities',
    summary:
        'Advanced visual storytelling, production details, and hidden trivia.',
    body:
        'Repeated shapes can reveal how a fictional society sees itself. Circular architecture often implies continuity, while broken grids can suggest disruption. These original examples demonstrate the technique without relying on an existing franchise.',
    category: 'Deep Dive',
    type: ContentType.deepDive,
    creator: 'Lore Lab',
    tags: ['trivia', 'behind-the-scenes', 'advanced'],
    trending: true,
  ),
];

final eventCatalog = [
  FandomEvent(
    id: 'karachi-cosplay-meet',
    title: 'Karachi Cosplay Makers Meetup',
    description:
        'A community workshop for costumes, props, and safe build techniques.',
    city: 'Karachi',
    venue: 'Arts Council Garden',
    date: DateTime(2026, 10, 18, 14),
    category: 'Cosplay Meetup',
    latitude: 24.8607,
    longitude: 67.0011,
    ticketUrl: '',
    isDemo: true,
  ),
  FandomEvent(
    id: 'lahore-screening-night',
    title: 'Fantasy Screening Night',
    description: 'An outdoor screening and moderated fan discussion.',
    city: 'Lahore',
    venue: 'Community Arts Courtyard',
    date: DateTime(2026, 11, 7, 18, 30),
    category: 'Screening',
    latitude: 31.5204,
    longitude: 74.3587,
    ticketUrl: '',
    isDemo: true,
  ),
  FandomEvent(
    id: 'islamabad-game-con',
    title: 'Capital Games & Comics Convention',
    description: 'Independent games, comics, panels, and beginner tournaments.',
    city: 'Islamabad',
    venue: 'Convention Centre',
    date: DateTime(2026, 12, 12, 10),
    category: 'Convention',
    latitude: 33.6844,
    longitude: 73.0479,
    ticketUrl: '',
    isDemo: true,
  ),
];

const productCatalog = [
  Product(
    id: 'nebula-hoodie',
    name: 'Nebula Explorer Hoodie',
    description: 'Original Fandom Verse embroidered hoodie.',
    category: 'Apparel',
    price: 6499,
    previousPrice: 7499,
    stock: 20,
  ),
  Product(
    id: 'portal-pin',
    name: 'Portal Enamel Pin',
    description: 'A luminous portal pin for bags and jackets.',
    category: 'Collectibles',
    price: 1199,
    stock: 45,
  ),
  Product(
    id: 'lore-journal',
    name: 'Lore Keeper Journal',
    description: 'Hardcover notebook for theories and world-building.',
    category: 'Collectibles',
    price: 2299,
    stock: 30,
  ),
  Product(
    id: 'cosmic-wallpaper',
    name: 'Cosmic Wallpaper Pack',
    description: 'Five original high-resolution digital backgrounds.',
    category: 'Digital',
    price: 799,
    previousPrice: 999,
    stock: 999,
  ),
  Product(
    id: 'arena-shirt',
    name: 'Arena Pulse T-Shirt',
    description: 'Soft cotton gaming-inspired graphic shirt.',
    category: 'Apparel',
    price: 3299,
    stock: 18,
  ),
];
