import '../domain/library_models.dart';

/// A deliberately small, editorial demo catalog.
///
/// Every card has its own copy and visual. The two video and two audio entries
/// ship with the app so they remain playable without a network connection.
/// Admin-created Firestore content is merged over this fallback catalog at
/// runtime.
const contentCatalog = [
  ContentItem(
    id: 'anime-first-steps',
    title: 'Anime: A Friendly First Watchlist',
    summary: 'Choose your first series by mood, length, and comfort level.',
    body:
        'Start with one genre you already enjoy, then keep a short watchlist instead of chasing every recommendation. This guide explains episode counts, subtitles versus dubs, and a respectful way to discuss spoilers with new friends.',
    category: 'Anime',
    type: ContentType.beginnerGuide,
    creator: 'Fandom Verse Editorial',
    tags: ['anime', 'beginner', 'watchlist'],
    trending: true,
    imageUrl: 'assets/media/anime_watchlist.webp',
  ),
  ContentItem(
    id: 'anime-character-gallery',
    title: 'Original Character Sketchbook',
    summary: 'A visual prompt pack for designing a hero, rival, and mentor.',
    body:
        'Build an original character from silhouette to motivation. Each prompt asks for a practical costume detail, one imperfect habit, and a relationship that changes the character over time. These are original fan-creation exercises, not copies of existing characters.',
    category: 'Anime',
    type: ContentType.gallery,
    creator: 'Fandom Verse Creators',
    tags: ['anime', 'art', 'oc'],
    imageUrl: 'assets/media/anime_sketchbook.webp',
  ),
  ContentItem(
    id: 'gaming-first-team',
    title: 'Build Your First Gaming Squad',
    summary: 'Simple communication habits that make group play more fun.',
    body:
        'A great squad agrees on a goal before the match, keeps callouts short, and makes room for players who are still learning. Use this starter guide to create a welcoming session, set boundaries around voice chat, and celebrate progress instead of only wins.',
    category: 'Gaming',
    type: ContentType.beginnerGuide,
    creator: 'Fandom Verse Play Lab',
    tags: ['gaming', 'teamwork', 'beginner'],
    trending: true,
    imageUrl: 'assets/media/gaming_squad.webp',
  ),
  ContentItem(
    id: 'gaming-interface-deep-dive',
    title: 'Why Great Game Interfaces Feel Invisible',
    summary: 'A practical deep dive into readable HUDs, menus, and feedback.',
    body:
        'Good interfaces answer three questions quickly: where am I, what can I do, and what changed? Study contrast, spacing, motion, and sound feedback together. The best interface is useful without hiding the world players came to explore.',
    category: 'Gaming',
    type: ContentType.deepDive,
    creator: 'Fandom Verse Design Desk',
    tags: ['gaming', 'design', 'ui'],
    imageUrl: 'assets/media/gaming_interface.webp',
  ),
  ContentItem(
    id: 'gaming-community-story',
    title: 'The One-Button Tournament',
    summary: 'How a small local challenge became a welcoming community ritual.',
    body:
        'The rule was intentionally simple: one control, two minutes, and one cheer for every new player. The story follows how organisers made a low-pressure event feel exciting while keeping the focus on accessibility, fair turns, and shared laughs.',
    category: 'Gaming',
    type: ContentType.story,
    creator: 'Fandom Verse Community',
    tags: ['gaming', 'community', 'story'],
    imageUrl: 'assets/media/gaming_tournament.webp',
  ),
  ContentItem(
    id: 'comics-panel-language',
    title: 'How Comics Tell Time Between Panels',
    summary: 'Read pacing, motion, and emotion through page layout.',
    body:
        'Panel size, page turns, and the space between frames all guide a reader through time. This short lesson shows how artists can slow down a reveal, create a sense of speed, or let a silent reaction carry an entire scene.',
    category: 'Comics',
    type: ContentType.deepDive,
    creator: 'Fandom Verse Editorial',
    tags: ['comics', 'visual-storytelling', 'art'],
    trending: true,
    imageUrl: 'assets/media/comics_panels.webp',
  ),
  ContentItem(
    id: 'comics-cover-gallery',
    title: 'Cover Concepts: Light, Shadow, and Scale',
    summary: 'A gallery of original cover-design prompts for comic creators.',
    body:
        'Try one bold object, one clear focal point, and a colour palette that matches the story mood. This gallery is a set of original concept prompts for practice; it is not a catalogue of licensed comic art.',
    category: 'Comics',
    type: ContentType.gallery,
    creator: 'Fandom Verse Creators',
    tags: ['comics', 'gallery', 'covers'],
    imageUrl: 'assets/media/comics_covers.webp',
  ),
  ContentItem(
    id: 'scifi-worldbuilding-guide',
    title: 'Worldbuilding Without an Encyclopedia',
    summary:
        'Create a believable science-fiction setting from five useful rules.',
    body:
        'Choose one technology, decide who benefits from it, and show one everyday consequence. Add a limitation, a cultural habit, and a conflict that cannot be solved by the technology alone. Readers will feel the world through its people before they need a map.',
    category: 'Sci-Fi',
    type: ContentType.beginnerGuide,
    creator: 'Fandom Verse Story Lab',
    tags: ['scifi', 'writing', 'worldbuilding'],
    trending: true,
    imageUrl: 'assets/media/scifi_orbit.webp',
  ),
  ContentItem(
    id: 'scifi-future-archive',
    title: 'Signals From a Shared Future',
    summary:
        'A short original fiction piece about a community archive in orbit.',
    body:
        'When the station receives a damaged memory capsule, its archivists disagree about whether it belongs to a person, a nation, or everyone. The story explores care, consent, and the strange responsibility of preserving a future that has not happened yet.',
    category: 'Sci-Fi',
    type: ContentType.story,
    creator: 'Fandom Verse Fiction',
    tags: ['scifi', 'fiction', 'future'],
    imageUrl: 'assets/media/scifi_archive.webp',
  ),
  ContentItem(
    id: 'creator-focus-detail',
    title: 'Creator Focus: The Beauty of Small Details',
    summary: 'A locally bundled visual reel for the Explore video player.',
    body:
        'This short, royalty-free visual reel is bundled with the app as a playback demonstration. It is intentionally labelled as a demo visual rather than presented as footage from a specific fandom or creator.',
    category: 'Creator Culture',
    type: ContentType.video,
    creator: 'Fandom Verse Demo Studio',
    tags: ['video', 'creator', 'offline'],
    trending: true,
    imageUrl: 'assets/media/creator_detail.webp',
    videoUrl: 'assets/media/creator_focus_bee.mp4',
  ),
  ContentItem(
    id: 'creator-focus-motion',
    title: 'Creator Focus: Motion and Colour',
    summary: 'A second distinct locally bundled visual reel.',
    body:
        'This separate royalty-free clip lets fans test video controls, mute, playback, and offline viewing without a broken third-party link. Replace it from the Admin content tools when production media is ready.',
    category: 'Creator Culture',
    type: ContentType.video,
    creator: 'Fandom Verse Demo Studio',
    tags: ['video', 'motion', 'offline'],
    imageUrl: 'assets/media/creator_motion.webp',
    videoUrl: 'assets/media/creator_focus_butterfly.mp4',
  ),
  ContentItem(
    id: 'fandom-kindness-code',
    title: 'The Fandom Kindness Code',
    summary: 'A practical guide to crediting creators and protecting the fun.',
    body:
        'Ask before reposting, credit the artist when you share, keep spoilers behind a warning, and never turn disagreement into harassment. A healthy fandom has room for different theories, ships, games, and opinions while keeping real people safe.',
    category: 'Community',
    type: ContentType.glossary,
    creator: 'Fandom Verse Community',
    tags: ['community', 'safety', 'etiquette'],
    imageUrl: 'assets/media/community_kindness.webp',
  ),
  ContentItem(
    id: 'community-creator-spotlight',
    title: 'Creator Spotlight: Build, Share, Credit',
    summary: 'A practical checklist for showcasing fan work responsibly.',
    body:
        'Share your own process, link back to collaborators, and clearly label mock-ups, edits, and inspired work. This spotlight explains how small credits and consent checks help community artists feel safe enough to keep creating.',
    category: 'Community',
    type: ContentType.story,
    creator: 'Fandom Verse Community',
    tags: ['community', 'creators', 'credit'],
    imageUrl: 'assets/media/community_spotlight.webp',
  ),
  ContentItem(
    id: 'audio-cosmic-focus',
    title: 'Audio Room: Cosmic Focus',
    summary: 'An original offline ambient audio track for reading and writing.',
    body:
        'A short original synth atmosphere made for focused reading, writing, and theory crafting. It is bundled in the app, so it plays without a data connection.',
    category: 'Audio Room',
    type: ContentType.podcast,
    creator: 'Fandom Verse Audio Lab',
    tags: ['audio', 'ambient', 'offline'],
    imageUrl: 'assets/media/audio_cosmic.webp',
    videoUrl: 'assets/media/cosmic_atmosphere.mp3',
  ),
  ContentItem(
    id: 'audio-arcade-pulse',
    title: 'Audio Room: Arcade Pulse',
    summary: 'An original offline electronic audio track for play sessions.',
    body:
        'A separate original synth cue with a brighter pulse for game nights and creative sessions. The playback bar reports the real file duration and position.',
    category: 'Audio Room',
    type: ContentType.podcast,
    creator: 'Fandom Verse Audio Lab',
    tags: ['audio', 'arcade', 'offline'],
    imageUrl: 'assets/media/audio_arcade.webp',
    videoUrl: 'assets/media/arcade_pulse.mp3',
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
    imageUrl: 'assets/premium_bg.jpg',
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
    imageUrl: 'assets/trending_scifi.jpg',
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
    imageUrl: 'assets/trending_gaming.jpg',
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
    imageUrl: 'assets/premium_bg.jpg',
    modelUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
    tryOnModelUrl:
        'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb',
  ),
  Product(
    id: 'portal-pin',
    name: 'Portal Enamel Pin',
    description: 'A luminous portal pin for bags and jackets.',
    category: 'Collectibles',
    price: 1199,
    stock: 45,
    imageUrl: 'assets/trending_scifi.jpg',
    modelUrl:
        'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/DamagedHelmet/glTF-Binary/DamagedHelmet.glb',
    tryOnModelUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
  ),
  Product(
    id: 'lore-journal',
    name: 'Lore Keeper Journal',
    description: 'Hardcover notebook for theories and world-building.',
    category: 'Collectibles',
    price: 2299,
    stock: 30,
    imageUrl: 'assets/trending_comics.jpg',
    modelUrl: 'https://modelviewer.dev/shared-assets/models/NeilArmstrong.glb',
    tryOnModelUrl:
        'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb',
  ),
  Product(
    id: 'cosmic-wallpaper',
    name: 'Cosmic Wallpaper Pack',
    description: 'Five original high-resolution digital backgrounds.',
    category: 'Digital',
    price: 799,
    previousPrice: 999,
    stock: 999,
    imageUrl: 'assets/images/fandom_multiverse.png',
    modelUrl:
        'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb',
    tryOnModelUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
  ),
  Product(
    id: 'arena-shirt',
    name: 'Arena Pulse T-Shirt',
    description: 'Soft cotton gaming-inspired graphic shirt.',
    category: 'Apparel',
    price: 3299,
    stock: 18,
    imageUrl: 'assets/gaming.jpg',
    modelUrl:
        'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/BoomBox/glTF-Binary/BoomBox.glb',
    tryOnModelUrl:
        'https://modelviewer.dev/shared-assets/models/NeilArmstrong.glb',
  ),
];
