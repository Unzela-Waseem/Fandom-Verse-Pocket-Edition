# Fandom Verse Pocket Edition — Submission Video Script

**Suggested length:** 4–5 minutes  
**Tone:** confident, friendly, clear  
**Recording tip:** show the matching screen while reading each paragraph. Do not show API keys, Firebase credentials, or personal email addresses.

## 1. Splash screen — 0:00–0:15

**Screen:** Launch the app and let the video splash finish.

**Voice-over:**

“When Fandom Verse opens, the branded splash screen introduces the pocket universe and gives the app a clear, memorable first impression. The splash then moves into the authentication flow without making the fan wait through unnecessary steps.”

## 2. Onboarding — 0:15–0:40

**Screen:** Swipe through all three onboarding slides, then tap Get Started or Sign in.

**Voice-over:**

“The onboarding experience explains the product in three simple steps. First, fans discover stories, characters and hidden lore. Next, they find their community, use the AI Fan Helper and discover local meetups. The final slide brings stories, events, communities and collectibles into one fandom universe. Fans can move forward, go back or skip directly to authentication.”

## 3. Authentication and profile setup — 0:40–1:15

**Screen:** Login screen, Google button, registration screen, validation message, then profile completion.

**Voice-over:**

“Fans can sign in with email and password or continue with Google. New users can register directly in the app, with validation for name, email and password fields. Google sign-in uses Firebase Authentication, so the account is connected securely to the same profile and data system.

“After the first sign-in, the Auth Gate checks the account state. If profile information is incomplete, the fan is taken to profile completion to choose a display name, badge and favourite fandoms. Once that profile is saved, the fan is taken to the personalised dashboard. Admin accounts follow a protected admin route with role and account-status checks.”

## 4. Opening — 1:15–1:35

**Screen:** App logo, onboarding, then the home dashboard.

**Voice-over:**

“Welcome to Fandom Verse Pocket Edition — a mobile-first fandom companion built for fans who want discovery, community, creativity and shopping in one connected experience. The app brings fandom content, events, conversations, an AI helper and an admin workspace together with a clean, responsive Flutter interface.”

## 5. Personal dashboard — 1:35–2:00

**Voice-over:**

“Fans can create an account with email and password, complete a profile, choose their favourite fandoms and receive a personalised home experience. The dashboard surfaces trending stories, fandom categories, featured content and shortcuts to the areas fans use most. The layout adapts to mobile and wide screens, with bottom navigation on mobile and a navigation rail on larger screens.”

## 6. Explore catalog and character profiles — 2:00–2:50

**Screen:** Explore tab, category chips, search, Anime tab, open a character, scroll through related content.

**Voice-over:**

“The Explore catalog is the heart of the discovery experience. Fans can search by title, creator, tag or keyword, then filter by categories such as Anime, Gaming, Comics and Sci-Fi. Each category includes character profiles as well as stories, guides, galleries, videos, audio rooms and news.

“Opening a character profile gives the fan a complete context page: a hero visual, character bio, tags and related category content. From the same page, fans can move into gallery material, news, stories and deep-dive guides without losing the fandom context. Content can also be bookmarked for offline reading.”

## 7. AI Fan Helper — 2:50–3:10

**Screen:** AI Fan Helper, ask two different questions, show loading and answer states.

**Voice-over:**

“The AI Fan Helper gives fans a conversational way to explore the universe. A fan can ask about characters, fandom terminology, events or how to use the app. The interface provides a clear loading state and a helpful fallback response when a live AI connection is unavailable, so the feature remains understandable and usable.”

## 8. Events, community and notifications — 3:10–3:40

**Screen:** Events list, city filter, event detail, agenda/save action, Discussions and Notifications.

**Voice-over:**

“The Events area helps fans discover conventions, screenings and meetups. They can filter by city, view event details, open map directions, validate ticket links and save events to their agenda. Discussions provide a space for community conversation with moderation controls, while Notifications keep announcements, read states and personal updates organised.”

## 9. Store, wishlist and AR preview — 3:40–4:15

**Screen:** Store, product detail, wishlist, cart, checkout preview, then AR Preview.

**Voice-over:**

“Fandom Verse also includes a merchandise journey. Fans can browse products, compare prices, check stock, save wishlist items, add products to a local cart and complete a simulated checkout flow. The AR Preview area lets fans inspect supported fandom artifacts in an interactive space, switch between available items and view product details before deciding what to save or purchase.”

## 10. Profile and offline-friendly features — 4:15–4:35

**Screen:** Profile, edit profile, bookmarks, saved content and settings.

**Voice-over:**

“The profile area keeps the fan’s identity and activity together. Fans can edit their display name, bio, avatar and selected fandoms, review badges and counters, and revisit saved content. Bookmarked text and metadata remain available for offline reading, making the app useful even when connectivity is limited.”

## 11. Admin console — 4:35–5:30

**Screen:** Admin login, dashboard, metric cards, module cards, Users, Content, Categories, Events, Merchandise, Moderation and Audit Logs.

**Voice-over:**

“Behind the fan experience is a dedicated Admin Console. The responsive dashboard gives administrators a quick view of members, published content, events and products, with live Firestore counts where the service is available. The visual workspace groups tools into content and commerce, community care and administration, so important actions are easy to find.

“Administrators can create, search, edit, enable or disable user accounts; manage fandom categories; publish stories, news and media; schedule events; update merchandise, prices and stock; review inquiries; publish announcements; and moderate discussions. Every important administrative action is recorded in audit logs, creating a clear history of changes. The dashboard also provides a safe sign-out flow and responsive cards that remain usable on smaller screens.”

## 12. Technical value and closing — 5:30–5:55

**Screen:** Quick montage of the main screens, then app logo.

**Voice-over:**

“Fandom Verse Pocket Edition is built with Flutter and Firebase. Authentication, Firestore data, account-scoped bookmarks, profile data, moderation rules and admin permissions are connected through a structured feature-based architecture. The result is a single fandom platform that supports discovery, participation, commerce and administration instead of treating them as separate experiences.

“Thank you for exploring Fandom Verse Pocket Edition — a pocket universe made for every kind of fan.”

## Recording checklist

- Start with a clean account and a short, readable display name.
- Show one complete path: Home → Explore → Character → Related news/gallery → Bookmark.
- Show at least one Anime character and one Gaming character so the category depth is visible.
- In the Store, use the simulated checkout wording shown by the app.
- In the Admin Console, show the dashboard and two CRUD screens; avoid exposing credentials.
- Keep transitions quick, and pause briefly when a feature title appears.
