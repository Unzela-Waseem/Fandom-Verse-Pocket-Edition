import '../domain/library_models.dart';

const contentCatalog = [
  // Core baseline items preserved for regression tests
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
    imageUrl:
        'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&q=80',
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
    imageUrl:
        'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&q=80',
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
    imageUrl:
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&q=80',
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
    imageUrl:
        'https://images.unsplash.com/photo-1535223289827-42f1e9919769?w=800&q=80',
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
    imageUrl:
        'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&q=80',
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
    imageUrl:
        'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&q=80',
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
    imageUrl:
        'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=800&q=80',
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
    imageUrl:
        'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&q=80',
  ),

  // Anime Fandom - News, Story, Gallery, Video, Podcast, Profile
  ContentItem(
    id: 'news-anime-season',
    title: 'New Anime Season Announced: Shinobi Rising',
    summary:
        'The official production committee unveils the upcoming autumn anime season slate featuring legendary ninja sagas.',
    body:
        'Studio animators confirmed an explosive 24-episode seasonal run featuring high-octane sakuga sequences and original character arcs. Fans can expect simultaneous worldwide broadcasts with multi-language subtitling. Official key visuals showcase our protagonist balancing elemental fire and wind techniques.',
    category: 'Anime',
    type: ContentType.news,
    creator: 'Fandom Verse Team',
    tags: ['anime', 'news', 'naruto', 'trending'],
    trending: true,
    imageUrl:
        'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800&q=80',
  ),
  ContentItem(
    id: 'story-anime-naruto',
    title: 'Naruto: Whispers of the Hidden Valley',
    summary:
        'An original fan-written tale of a young genin squad discovering an ancient sealed temple during a thunderstorm.',
    body:
        'Rain pounded the mossy tiles of the ancient shrine. As lightning illuminated the carved stone foxes, Ren untied his forehead protector. "The seal is weakening," he whispered. Together with his squad, he channeled chakra into the barrier tag, determined to protect the hidden village from whatever slumbered beneath the temple roots.',
    category: 'Anime',
    type: ContentType.story,
    creator: 'Fandom Verse Editorial',
    tags: ['anime', 'story', 'naruto'],
    trending: true,
    imageUrl:
        'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&q=80',
  ),
  ContentItem(
    id: 'gallery-anime-shinobi',
    title: 'Gallery: Legendary Ninja Characters & Battle Posters',
    summary:
        'Curated collection of high-resolution character designs, battle poses, and promotional poster artwork.',
    body:
        'Explore dynamic sketches and colored plates of the protagonist, rival swordsmen, and ancient village elders. Tap any poster or character card to open the high-resolution full-screen viewer.',
    category: 'Anime',
    type: ContentType.gallery,
    creator: 'Ari Studio',
    tags: ['anime', 'gallery', 'art', 'naruto'],
    imageUrl:
        'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&q=80',
  ),
  ContentItem(
    id: 'video-anime-combat',
    title: 'Video: Epic Shinobi Combat Breakdown',
    summary:
        'A frame-by-frame analytical clip exploring hand-to-hand martial choreography and animation spacing.',
    body:
        'Watch key animators deconstruct the choreography of classic hand-to-hand taijutsu duels. Learn how camera tilts and smear frames heighten the physical impact of every strike.',
    category: 'Anime',
    type: ContentType.video,
    creator: 'Fandom Verse Editorial',
    tags: ['anime', 'video', 'action'],
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    imageUrl:
        'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&q=80',
  ),
  ContentItem(
    id: 'podcast-anime-shonen',
    title: 'Podcast: Talk Anime - The Shonen Golden Age',
    summary:
        'Hosts explore the enduring legacy of shonen storytelling, tournament arcs, and rival friendship dynamics.',
    body:
        'Episode 42: What makes a shonen protagonist memorable? We examine the hero’s journey from underdog to village hero, the psychological role of rivalries, and how modern series build on foundational classics like Naruto and Dragon Ball.',
    category: 'Anime',
    type: ContentType.podcast,
    creator: 'Verse Audio',
    tags: ['anime', 'podcast', 'naruto'],
    imageUrl:
        'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=800&q=80',
  ),
  ContentItem(
    id: 'profile-anime-master',
    title: 'Creator Profile: Mangaka Kenji Satou',
    summary:
        'Spotlight on the celebrated mangaka known for intricate brushwork and heartfelt emotional character arcs.',
    body:
        'With over fifteen years illustrating serialized monthly manga, Kenji Satou shares insights into character silhouette design, pacing weekly cliffhangers, and training the next generation of studio assistants.',
    category: 'Anime',
    type: ContentType.profile,
    creator: 'Ari Studio',
    tags: ['anime', 'creator', 'manga'],
    imageUrl:
        'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&q=80',
  ),

  // Comics Fandom (Marvel & Superhero) - News, Story, Gallery, Video, Podcast
  ContentItem(
    id: 'news-marvel-multiverse',
    title: 'Marvel Multiverse Incursion Protocol Revealed',
    summary:
        'Editorial team outlines the timeline collision rules and variant registries for the upcoming cosmic comic event.',
    body:
        'Writers revealed the multiversal incursion rules that will govern the major comic crossover event. Alternate earths will face eight-hour convergence windows where heroes must coordinate across dimensional barriers to preserve reality continuity without destroying sister timelines.',
    category: 'Comics',
    type: ContentType.news,
    creator: 'Fandom Verse Team',
    tags: ['marvel', 'comics', 'news', 'trending'],
    trending: true,
    imageUrl:
        'https://images.unsplash.com/photo-1612036782180-6f0b6cd846fe?w=800&q=80',
  ),
  ContentItem(
    id: 'story-marvel-variants',
    title: 'Marvel: Chronicles of Earth-838',
    summary:
        'An original multiverse fan fiction exploring a timeline where technology and arcane sorcery united.',
    body:
        'From the gleaming titanium towers of New York, the Sorcerer Supreme looked down upon the quantum transit lanes. Here, magic had been cataloged as a particle wave equation. When an unexpected energy fluctuation announced the arrival of an out-of-universe variant, the defense grid automatically engaged.',
    category: 'Comics',
    type: ContentType.story,
    creator: 'Fandom Verse Community',
    tags: ['marvel', 'comics', 'story'],
    imageUrl:
        'https://images.unsplash.com/photo-1568832359672-e36cf5d74f54?w=800&q=80',
  ),
  ContentItem(
    id: 'gallery-comics-covers',
    title: 'Gallery: Iconic Superhero Covers & Comic Variants',
    summary:
        'High-resolution archival showcase of classic variant comic covers and splash pages.',
    body:
        'From dramatic shadow cross-hatching to vibrant holographic foil variants, this gallery celebrates legendary cover artwork from the golden age to modern digital masters. Tap any illustration to inspect full details in full screen.',
    category: 'Comics',
    type: ContentType.gallery,
    creator: 'Ari Studio',
    tags: ['marvel', 'comics', 'gallery', 'art'],
    imageUrl:
        'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800&q=80',
  ),
  ContentItem(
    id: 'video-comics-penciling',
    title: 'Video: Comic Penciling to Digital Ink Masterclass',
    summary:
        'Timelapse and commentary on how dynamic superhero poses are drafted, inked, and colored.',
    body:
        'Watch veteran inker Marcus Vance transform rough blue-pencil sketches into finished, dynamic cover art ready for publication. Learn brush control, perspective lines, and dramatic rim lighting.',
    category: 'Comics',
    type: ContentType.video,
    creator: 'Lore Lab',
    tags: ['comics', 'video', 'marvel'],
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  ),
  ContentItem(
    id: 'podcast-comics-multiverse',
    title: 'Podcast: The Multiverse Vault - Origins of Variants',
    summary:
        'Deep conversational analysis of Marvel multiversal lore, continuity retcons, and parallel timelines.',
    body:
        'In this episode, we unpack why parallel timelines have become the defining modern comic narrative trope, how writers keep canon straight across hundreds of concurrent issues, and our favorite alternate variants.',
    category: 'Comics',
    type: ContentType.podcast,
    creator: 'Verse Audio',
    tags: ['marvel', 'comics', 'podcast'],
  ),

  // Gaming Fandom - News, Story, Gallery, Video, Podcast
  ContentItem(
    id: 'story-gaming-esports',
    title: 'The Glitch in Sector 7: An Esports Thriller',
    summary:
        'A team of underdog players encounters an undocumented mystery code during the world championship qualifiers.',
    body:
        'The arena scoreboard was tied 14-14. As Maya sprinted through the digital neon alleyways of Sector 7, her HUD flickered. An unmapped doorway appeared in the brick texture. She had two seconds to decide: play the safe lane or step through the glitch.',
    category: 'Gaming',
    type: ContentType.story,
    creator: 'Fandom Verse Community',
    tags: ['gaming', 'story', 'esports'],
  ),
  ContentItem(
    id: 'gallery-gaming-arenas',
    title: 'Gallery: Cyberpunk Arenas & Character Skins',
    summary:
        'Original concept art of competitive battle arenas, cyberpunk weapon finishes, and legendary skins.',
    body:
        'A curated visual lookbook of sci-fi esports arena environments, from neon-lit rain-soaked rooftops to subterranean data vaults. Tap to inspect in full-screen zoom.',
    category: 'Gaming',
    type: ContentType.gallery,
    creator: 'Ari Studio',
    tags: ['gaming', 'gallery', 'art'],
  ),
  ContentItem(
    id: 'video-gaming-finals',
    title: 'Video: Grand Finals Match Highlights',
    summary:
        'Fast-paced reel of match-winning clutch plays, coordinated ultimate maneuvers, and team reactions.',
    body:
        'Relive the most intense moments from the grand championship series. Includes slow-motion replay analysis of team coordination and tactical ability economy.',
    category: 'Gaming',
    type: ContentType.video,
    creator: 'Arena Desk',
    tags: ['gaming', 'video', 'esports'],
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  ),
  ContentItem(
    id: 'podcast-gaming-level-design',
    title: 'Podcast: Level Design & Game Engine Balancing',
    summary:
        'Game developers discuss symmetric map architecture, player psychology, and hero balancing.',
    body:
        'Episode 19: How do designers prevent spawn trapping while ensuring high visual variety across competitive arenas? Developers discuss sightlines, audio occlusions, and how community feedback shapes live game patches.',
    category: 'Gaming',
    type: ContentType.podcast,
    creator: 'Verse Audio',
    tags: ['gaming', 'podcast'],
  ),

  // Sci-Fi Fandom - News, Gallery, Video, Podcast
  ContentItem(
    id: 'news-scifi-odyssey',
    title: 'Starship Odyssey: Deep Space Discovery Announced',
    summary:
        'Expedition command confirms discovery of an ancient Dyson swarm surrounding a binary star system.',
    body:
        'Deep space radio telemetry confirmed that the robotic exploration fleet Starlight IV has entered orbit around a star enveloped by a structured precursor megastructure. Scientists estimate the structure captures over 80% of the host star energy.',
    category: 'Sci-Fi',
    type: ContentType.news,
    creator: 'Fandom Verse Team',
    tags: ['scifi', 'news', 'space'],
  ),
  ContentItem(
    id: 'gallery-scifi-homeworlds',
    title: 'Gallery: Deep Space Explorers & Alien Homeworlds',
    summary:
        'Panoramic illustrations of interstellar cruiser fleets and atmospheric extraterrestrial biospheres.',
    body:
        'Showcase of original space exploration artwork, starship cutaways, and alien biological landscapes. Open any image for high-definition full-screen viewing.',
    category: 'Sci-Fi',
    type: ContentType.gallery,
    creator: 'Ari Studio',
    tags: ['scifi', 'gallery', 'art'],
  ),
  ContentItem(
    id: 'video-scifi-jumps',
    title: 'Video: Visual FX Breakdown of Starship Jumps',
    summary:
        'Behind-the-scenes breakdown of particle physics simulations and camera lensing used in warp transitions.',
    body:
        'VFX artists walk through the node-based compositing layers required to render faster-than-light warp space warping without visual distortion artifacts.',
    category: 'Sci-Fi',
    type: ContentType.video,
    creator: 'Lore Lab',
    tags: ['scifi', 'video'],
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
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
