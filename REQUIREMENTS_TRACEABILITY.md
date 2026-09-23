# Requirements Traceability

Status values: `planned`, `in progress`, `implemented`, `verified`, `external prerequisite`.

| Area | Status | Evidence |
|---|---|---|
| Flutter foundation and Android 9 baseline | implemented | `pubspec.yaml`, `android/app/build.gradle.kts` |
| Theme and Fan/Admin entry experience | implemented | `lib/app`, `lib/features/authentication` |
| Input validation | verified | `lib/core/validation`, unit tests |
| Email/password Authentication and AuthGate | implemented | `lib/features/authentication`, live Firebase provider configuration |
| Firestore authorization | implemented | Deployed default-deny `firebase/firestore.rules` |
| Storage authorization | external prerequisite | Rules ready; new-project bucket provisioning requires billing |
| Profiles and dashboard | implemented | Firestore-backed profile creation/editing, fandoms, badge, bio, counters, and dashboard navigation |
| Fan dashboard visual shell | implemented | `lib/features/dashboard/presentation/fan_shell.dart` |
| Content hub, search, bookmarks, offline cache | in progress | Search/filter/detail, live published Firestore records, account-scoped local state, and saved full-text snapshots implemented; cross-device sync pending |
| Events, Maps links, calendar/agenda | implemented | City filter, contextual GPS permission, nearby sorting, external Maps, ticket validation, and offline agenda |
| Store, wishlist, cart, simulated checkout | in progress | Live Firestore product records, account-scoped local wishlist/cart/orders, simulated checkout and tests; cross-device sync pending |
| AI Fan Helper | implemented | Offline curated FAQ conversation with loading and fallback states |
| In-app notifications | in progress | Published Admin announcements and personal read/unread notification center; price-drop generation and FCM delivery pending |
| Contact, About, discussions | implemented | Firestore inquiry/discussion flows, ownership rules, project team screen |
| Admin CRUD and moderation | in progress | Firestore-backed collection editors, status controls, moderation, inquiries, announcements, and audit events; trusted account provisioning, media uploads, and live device verification pending |
| Backup, audit and deployment config | external prerequisite | Atomic Admin audit records and backup/restore runbook prepared; billing, schedule activation, and restore drill pending |
