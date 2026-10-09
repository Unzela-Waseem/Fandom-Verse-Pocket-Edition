# Requirements Traceability

Status values: `planned`, `in progress`, `implemented`, `verified`, `external prerequisite`.

| Area | Status | Evidence |
|---|---|---|
| Flutter foundation and Android 9 baseline | implemented | `pubspec.yaml`, `android/app/build.gradle.kts` |
| Theme and Fan/Admin entry experience | implemented | `lib/app`, `lib/features/authentication` |
| Input validation | verified | `lib/core/validation`, unit tests |
| Email/password Authentication and AuthGate | implemented | `lib/features/authentication`, live Firebase provider configuration |
| Google/Apple sign-in | in progress | Google provider enabled on Spark; Web popup, Android debug SHA/config, iOS URL scheme, consent, and Fan profile completion implemented. Real-account/device acceptance and Android release SHA remain pending. Apple code is gated until Apple Developer/Firebase provider setup. |
| Firestore authorization | implemented | Deployed default-deny `firebase/firestore.rules`; Admin requires active profile role plus trusted custom claim |
| Image/video delivery | in progress | Admin URLs now reach Fan images and content video playback; Cloudinary account claim, real-device playback, and actual editorial assets pending |
| Avatar and in-app media upload | external prerequisite | Firebase Storage client remains disabled on Spark; trusted-computer signed Cloudinary upload tool is ready, but in-app upload needs a separate authenticated signing backend |
| Profiles and dashboard | implemented | Firestore-backed profile creation/editing, fandoms, badge, bio, counters, and dashboard navigation |
| Fan dashboard visual shell | implemented | `lib/features/dashboard/presentation/fan_shell.dart` |
| Content hub, search, bookmarks, offline cache | in progress | Search/filter/detail, live Firestore records, account-scoped full-text snapshots and Firestore bookmark mirroring; offline/reconnection integration tests pending |
| Events, Maps links, calendar/agenda | implemented | City filter, contextual GPS permission, nearby sorting, external Maps, ticket validation, and offline agenda; bundled previews are labeled and cannot open placeholder venues/tickets |
| Store, wishlist, cart, simulated checkout | in progress | Live Firestore products, account-scoped local state mirrored to Firestore, simulated checkout and tests; cross-device conflict/integration verification pending |
| AI Fan Helper | implemented | Offline curated FAQ conversation with loading and fallback states |
| In-app notifications | external prerequisite | Published announcements, personal read/unread center, Fan opt-in/device registration, and tested price-drop function source; Cloud Functions/FCM deployment and device verification require billing/setup |
| Contact, About, discussions | implemented | Firestore inquiry/discussion flows, ownership rules, project team screen |
| Admin CRUD and moderation | implemented | Firestore-backed collection editors, validated user profile/status controls, discussion moderation (hide/unhide/delete), inquiry triage with admin notes, announcements, and atomic audit events; all 10 modules on admin dashboard including live stats for Users, Content, Events, Products, Discussions, and Inquiries. Pre-seeded evaluator credentials documented in README. Media uploads remain bound to Cloudinary external prerequisite. |
| Backup, audit and deployment config | external prerequisite | Atomic Admin audit records and backup/restore runbook prepared; billing, schedule activation, and restore drill pending |
