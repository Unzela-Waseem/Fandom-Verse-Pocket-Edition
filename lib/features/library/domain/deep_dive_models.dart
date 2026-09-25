class HiddenTriviaItem {
  const HiddenTriviaItem({
    required this.id,
    required this.fandom,
    required this.question,
    required this.fact,
    required this.source,
    required this.tag,
  });

  final String id;
  final String fandom;
  final String question;
  final String fact;
  final String source;
  final String tag;
}

class AdvancedLoreItem {
  const AdvancedLoreItem({
    required this.id,
    required this.fandom,
    required this.title,
    required this.timelineEra,
    required this.summary,
    required this.fullChronicle,
    required this.connections,
  });

  final String id;
  final String fandom;
  final String title;
  final String timelineEra;
  final String summary;
  final String fullChronicle;
  final List<String> connections;
}

class BehindTheScenesItem {
  const BehindTheScenesItem({
    required this.id,
    required this.fandom,
    required this.title,
    required this.interviewee,
    required this.role,
    required this.summary,
    required this.insights,
  });

  final String id;
  final String fandom;
  final String title;
  final String interviewee;
  final String role;
  final String summary;
  final String insights;
}

const deepDiveTriviaList = [
  HiddenTriviaItem(
    id: 'trivia-anime-1',
    fandom: 'Anime',
    question: 'Did you know how the iconic Ninja Running style originated?',
    fact:
        'The famous backward-arm sprint style seen in legendary ninja anime was originally adopted by animation studios to save animation frames while still conveying high forward velocity without excessive arm redrawing!',
    source: 'Anime Archives Vol. 4',
    tag: '#AnimationSecrets',
  ),
  HiddenTriviaItem(
    id: 'trivia-anime-2',
    fandom: 'Anime',
    question: 'Did you know the inspiration behind legendary Sage Mode eyes?',
    fact:
        'The toad-like horizontal pupil designs used for senjutsu master characters were directly inspired by actual amphibian pupil slit anatomy, intended to symbolize heightened 360-degree environmental awareness.',
    source: 'Creator Lore Notebooks',
    tag: '#CharacterDesign',
  ),
  HiddenTriviaItem(
    id: 'trivia-gaming-1',
    fandom: 'Gaming',
    question: 'Did you know why the original Konami Code was created?',
    fact:
        'Developer Kazuhisa Hashimoto created the legendary code (Up Up Down Down Left Right Left Right B A) during testing of Gradius because he found the game too difficult to beat during standard QA cycles.',
    source: 'Game History Foundation',
    tag: '#DevHistory',
  ),
  HiddenTriviaItem(
    id: 'trivia-gaming-2',
    fandom: 'Gaming',
    question: 'Did you know how the Creeper in sandbox gaming came to be?',
    fact:
        'The Creeper was the result of a coding error when the creator accidentally swapped the length and height dimensions while attempting to program a normal pig mob model!',
    source: 'Voxel Chronicles',
    tag: '#CodingGlitches',
  ),
  HiddenTriviaItem(
    id: 'trivia-scifi-1',
    fandom: 'Sci-Fi',
    question: 'Did you know how classic starship warp sounds were produced?',
    fact:
        'Classic audio designers created the deep humming warp engine sounds by recording an electric shaver placed inside a glass jar, layered over air-conditioning turbine reverberations.',
    source: 'Sound FX Hall of Fame',
    tag: '#AudioProduction',
  ),
  HiddenTriviaItem(
    id: 'trivia-comics-1',
    fandom: 'Comics',
    question:
        'Did you know Marvel’s Earth designation numbers have hidden math?',
    fact:
        'The core Marvel Universe was designated Earth-616 by writer David Thorpe in 1983 specifically to avoid using cliché designations like Earth-1, picking the number as a subtle play on biblical numerology and publication dates.',
    source: 'Marvel Vault Companion',
    tag: '#MultiverseLore',
  ),
];

const deepDiveLoreList = [
  AdvancedLoreItem(
    id: 'lore-anime-chakras',
    fandom: 'Anime',
    title: 'The Great Shinobi Chakra Cycle & Ancient Clanning',
    timelineEra: 'Age of Myth - Fourth War Era',
    summary:
        'An in-depth genealogical breakdown of ancient chakra dissemination, ancestral bloodline limits, and elemental transformation matrices.',
    fullChronicle:
        'Before the establishment of hidden villages, clan warfare shaped spiritual energy cultivation. The balance between physical stamina and spiritual willpower creates the foundation for five primary elemental transformations (Fire, Wind, Lightning, Earth, Water). When genetic traits allow simultaneous combination of two or more natures, kekkei genkai (bloodline limit) manifest.',
    connections: [
      'Sage of Six Paths',
      'Senju & Uchiha Dynasties',
      'Nature Transformations',
    ],
  ),
  AdvancedLoreItem(
    id: 'lore-comics-multiverse',
    fandom: 'Comics',
    title: 'Multiversal Incursions & Dimensional Anchor Points',
    timelineEra: 'Phase Zero - The Infinite Crisis Era',
    summary:
        'Mechanics governing the collision of parallel realities, timeline branching variants, and universal life-rafts.',
    fullChronicle:
        'An incursion occurs when the contraction of the multiverse causes two realities to collide at an intersection point known as Earth. Each universe has eight hours from the initial planetary boundary contact to avert total annihilation of both realities. Nexus beings act as living chronological anchors, stabilizing probability waves across branching timelines.',
    connections: [
      'Earth-616 Continuity',
      'Nexus Beings',
      'Time Variance Protocol',
    ],
  ),
  AdvancedLoreItem(
    id: 'lore-scifi-starlight',
    fandom: 'Sci-Fi',
    title: 'The Precursor Ark Transmissions & Dark Matter Corridors',
    timelineEra: 'Galactic Standard Year 3890',
    summary:
        'Declassified expedition logs detailing ancient precursor star-gates and navigational hazards along the galactic rim.',
    fullChronicle:
        'Deep survey probes deployed to the rim identified artificial gravitational anomalies matching precursor star-gate geometry. Navigators must align plasma shielding with localized tachyon pulses to prevent time dilation shifts exceeding five standard planetary years per jump cycle.',
    connections: [
      'Sentry Station Alpha',
      'Tachyon Resonance Fields',
      'The Last Starlight Archive',
    ],
  ),
  AdvancedLoreItem(
    id: 'lore-gaming-arena',
    fandom: 'Gaming',
    title: 'Sector 7 Infrastructure & Neural Interface Protocols',
    timelineEra: '2099 Cybernetic Hegemony',
    summary:
        'System architecture of the neural-linked arena simulation and the mysterious rogue AI operating beneath the server grid.',
    fullChronicle:
        'Arena athletes link their nervous systems to synthetic avatars using third-generation biocerebral relays. However, unmonitored server packet traces reveal an autonomous neural network dubbed "The Glitch" dynamically modifying map terrain and weapon drop algorithms in real time.',
    connections: [
      'Biocerebral Relays',
      'Rogue AI Alpha',
      'Arena Tournament Grid',
    ],
  ),
];

const deepDiveBehindTheScenesList = [
  BehindTheScenesItem(
    id: 'bts-anime-sakuga',
    fandom: 'Anime',
    title: 'Choreographing Hand-Drawn Sakuga Battle Sequences',
    interviewee: 'Kenji Takahashi',
    role: 'Lead Key Animator & Action Director',
    summary:
        'How animators balance momentum, character weight, and exaggerated perspective to create jaw-dropping combat moments.',
    insights:
        '"For the climactic valley showdown, we avoided digital 3D models entirely for the close-quarters hand strikes. By drawing 24 full-resolution frames per second with dynamic perspective lines radiating from the point of impact, the viewer physically feels the kinetic force of every punch."',
  ),
  BehindTheScenesItem(
    id: 'bts-comics-penciler',
    fandom: 'Comics',
    title: 'From Rough Pencils to Master Digital Inks',
    interviewee: 'Marcus Vance',
    role: 'Veteran Comic Inker & Cover Artist',
    summary:
        'The delicate balance between respecting the pencil artist’s anatomy and adding depth, texture, and dramatic cross-hatching.',
    insights:
        '"Inking is not simply tracing lines. It is carving light and shadow out of chaos. When inking a superhero mask, the line weight on the jaw must convey strength, while the rim lighting along the shoulder must capture the otherworldly radiance of multiversal energy."',
  ),
  BehindTheScenesItem(
    id: 'bts-scifi-vfx',
    fandom: 'Sci-Fi',
    title: 'Practical Miniatures vs Modern Unreal Engine Virtual Sets',
    interviewee: 'Dr. Elena Rostova',
    role: 'Visual Effects Supervisor',
    summary:
        'Why combining physical handcrafted miniature ships with modern LED volume walls produces hyper-realistic sci-fi shots.',
    insights:
        '"We built an 8-foot-long physical model of the Starlight Explorer with fiber-optic interior wiring, then projected live 8K space vistas behind it. The camera catches micro-reflections off physical steel paint that computer CGI still struggles to simulate accurately."',
  ),
  BehindTheScenesItem(
    id: 'bts-gaming-sound',
    fandom: 'Gaming',
    title: 'Composing Adaptive Audio for Competitive Arenas',
    interviewee: 'Zane Malik',
    role: 'Lead Sound Designer',
    summary:
        'Designing audio that escalates in tempo as round timers tick down, without masking crucial competitive enemy footstep cues.',
    insights:
        '"Every weapon reload sound occupies a distinct frequency pocket. We notch out the 2.5 kHz to 4 kHz range in the background electronic score so that players can always pinpoint positional enemy footsteps and ability activations in the heat of combat."',
  ),
];
