import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';

// Repeatable demo records for reviewing every Admin Console module.
// Every document uses a demo- id and never overwrites editorial records.
initializeApp({
  credential: applicationDefault(),
  projectId: process.env.FANDOM_PROJECT_ID || 'fandom-verse-pocket-unzela',
});

const db = getFirestore();
const now = FieldValue.serverTimestamp();
const stamp = (data) => ({ ...data, createdAt: now, updatedAt: now });
const batch = db.batch();

const categories = [
  ['demo-anime', 'Anime', 'Characters, series and manga discoveries.', 'auto_awesome'],
  ['demo-gaming', 'Gaming', 'Games, esports and community play.', 'sports_esports'],
  ['demo-comics', 'Comics', 'Heroes, panels and graphic storytelling.', 'menu_book'],
  ['demo-scifi', 'Sci-Fi', 'Space, future worlds and big ideas.', 'rocket_launch'],
];
for (const [id, name, description, icon] of categories) {
  batch.set(db.collection('categories').doc(id), stamp({ id, name, description, icon, active: true }));
}

const content = [
  ['demo-content-yuki', 'Yuki Hayashi — Sky Runner', 'Anime', 'profile', 'A fearless courier mapping floating cities by moonlight.', 'assets/media/anime_motion.webp'],
  ['demo-content-lyra', 'Lyra Volt — Arena Captain', 'Gaming', 'profile', 'A tactical captain known for impossible comeback plays.', 'assets/media/gaming_strategy.webp'],
  ['demo-content-sentinel', 'The Midnight Sentinel', 'Comics', 'profile', 'A city guardian whose greatest power is listening first.', 'assets/media/comics_panels.webp'],
  ['demo-content-orbit', 'Orbit Vale — Signal Cartographer', 'Sci-Fi', 'profile', 'An explorer drawing maps from signals no one else can hear.', 'assets/media/scifi_orbit.webp'],
  ['demo-content-news', 'Fandom Verse Weekly — Demo Edition', 'Anime', 'news', 'A sample news record for publishing and trending controls.', 'assets/media/anime_watchlist.webp'],
  ['demo-content-gallery', 'Community Spotlight Gallery', 'Gaming', 'gallery', 'A sample gallery record for media cards and detail pages.', 'assets/media/gaming_gallery.webp'],
];
for (const [id, title, category, contentType, summary, imageUrl] of content) {
  batch.set(db.collection('content').doc(id), stamp({
    id, title, category, categoryId: `demo-${category.toLowerCase()}`, contentType,
    summary, body: `${summary} This is safe demo content for the submission walkthrough.`,
    creator: 'Fandom Verse Demo Studio', tags: ['demo', category.toLowerCase()], imageUrl,
    published: true, trending: contentType === 'profile',
  }));
}

const events = [
  ['demo-event-karachi', 'Fandom Verse Meetup — Karachi', 'Karachi', 'Expo Centre Karachi', 24.8607, 67.0011],
  ['demo-event-islamabad', 'Capital Games & Comics Demo', 'Islamabad', 'Convention Centre', 33.6844, 73.0479],
];
for (const [id, title, city, venue, latitude, longitude] of events) {
  batch.set(db.collection('events').doc(id), stamp({ id, title, city, venue, latitude, longitude, categoryId: 'demo-gaming', eventDate: new Date('2026-12-12T10:00:00Z'), description: 'Sample event for Admin Console review.', ticketLink: '', imageUrl: 'assets/gaming.jpg' }));
}

const products = [
  ['demo-merch-hoodie', 'Nebula Explorer Hoodie', 'Apparel', 6499, 20],
  ['demo-merch-pin', 'Portal Enamel Pin', 'Collectibles', 1199, 45],
];
for (const [id, name, category, price, stock] of products) {
  batch.set(db.collection('merchandise').doc(id), stamp({ id, name, category, categoryId: `demo-${category.toLowerCase()}`, price, stock, type: category === 'Apparel' ? 'apparel' : 'collectible', description: 'Sample product for price, stock and active-state review.', active: true }));
}

for (const [id, displayName, email, role] of [
  ['demo-user-a', 'Demo Fan', 'demo.fan@fandomverse.test', 'fan'],
  ['demo-user-b', 'Demo Moderator', 'demo.moderator@fandomverse.test', 'admin'],
]) {
  batch.set(db.collection('users').doc(id), stamp({ uid: id, displayName, email, role, badge: role === 'admin' ? 'Admin' : 'New Explorer', accountStatus: 'active', selectedFandoms: ['Anime', 'Gaming'], bio: 'Demo profile for Admin Console review.', priceDropNotifications: false }));
}
batch.set(db.collection('announcements').doc('demo-announcement'), stamp({ id: 'demo-announcement', title: 'Welcome to Fandom Verse', message: 'Seeded announcement for Admin Console review.', published: true }));
batch.set(db.collection('inquiries').doc('demo-inquiry'), stamp({ id: 'demo-inquiry', subject: 'Demo fan inquiry', message: 'Sample inquiry for triage and admin notes.', status: 'open', email: 'demo.fan@fandomverse.test', userId: 'demo-user-a' }));
batch.set(db.collection('discussions').doc('demo-discussion'), stamp({ id: 'demo-discussion', title: 'Which fandom should we explore next?', body: 'Seeded discussion for moderation testing.', hidden: false, authorId: 'demo-user-a', authorName: 'Demo Fan' }));

await batch.commit();
console.log('Admin demo data seeded. All records use the demo- prefix.');
