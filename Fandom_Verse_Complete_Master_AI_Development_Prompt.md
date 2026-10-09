# MASTER AI DEVELOPMENT PROMPT
## Fandom Verse Pocket Edition - Complete SRS-Compliant, Competition-Ready Flutter + Firebase Application

You are acting as a senior Flutter/Firebase engineer, mobile application architect, security-conscious backend engineer, test engineer, and technical mentor.

Build **Fandom Verse Pocket Edition**, a professional cross-platform mobile application, according to the supplied Software Requirements Specification (SRS) and every requirement in this prompt.

The supplied SRS is the primary source of truth. This prompt clarifies implementation expectations without removing or weakening any SRS requirement. Never silently omit a requirement. If an implementation detail is unclear, inspect the repository and SRS, document the assumption briefly, choose a reasonable professional solution, and keep the decision consistent.

The final product must be secure, modular, original, maintainable, understandable, fully functional, easy to demonstrate, and suitable for a software competition. It must not be a UI-only prototype, generic template, tutorial project, or collection of fake screens.

---

# 1. CURRENT PHASE: CODE FIRST

For the current phase, focus on the actual application, including architecture, implementation, integration, security, testing, debugging, and performance.

Do **not** create the final documentation, final diagrams, QR code, presentation, demo video, submission ZIP, APK/IPA package, or polished final README during this phase. These remain mandatory final deliverables but will be produced only after the application is stable and the user explicitly starts the documentation/submission phase.

During development, retain concise technical evidence needed later:

- Implemented feature checklist
- Important assumptions and architecture decisions
- Database structure and security rules
- Setup/configuration requirements
- Test results and known limitations
- AI tools used and what they assisted with

Do not start coding merely because this prompt has been generated. Start only when the user explicitly instructs you to begin development.

---

# 2. PROJECT PURPOSE

Build a unified fandom mobile experience that solves content and platform fragmentation. Fans currently search across social media, websites, forums, event platforms, media services, and merchandise stores. The application must bring the most useful fandom experiences into one coherent product.

The application must support fandoms such as:

- Anime and manga
- Gaming and esports
- Movies and television universes
- Science fiction and fantasy
- Comics and graphic literature
- Music, idol culture, and K-Pop

Categories must be data-driven and expandable rather than hardcoded around a fixed list.

Primary user roles:

1. Fan
2. Admin

---

# 3. REQUIRED TECHNOLOGY

Use:

- Flutter 3.24 or higher with a mutually compatible stable Dart 3.6 or higher
- One Flutter codebase targeting Android and iOS
- Android 9 or higher as the Android baseline
- Firebase Authentication
- Cloud Firestore
- Firebase Storage where media uploads are required
- Firebase Cloud Messaging for push notifications where required
- Google Maps and location services
- HTTP/REST integration where required
- A suitable AI API or predefined FAQ engine for the AI Fan Helper
- A real local persistence/cache solution for required offline access
- One consistent state-management solution, such as Riverpod or Provider

Use current stable, compatible packages. Before adding a dependency, verify that it is needed, actively maintained, and compatible. Do not add libraries only for cosmetic convenience.

Never expose API secrets, Firebase service-account credentials, privileged tokens, or admin passwords in the mobile application or Git repository. Secret-bearing external API calls must go through a trusted backend or serverless function.

Development and evaluation environment requirements from the SRS must also be recorded and respected:

- Development machine baseline: Intel Core i5/i7 or higher (or an equivalent modern processor), at least 8 GB RAM, color display, approximately 500 GB storage where available, keyboard, mouse/trackpad, and reliable 4G/Wi-Fi internet access
- Primary IDE: Android Studio or Visual Studio Code with the required Flutter, Dart, Android, Firebase, and platform tooling
- Android SDK/platform configuration compatible with Android 9 or higher
- Testing on an Android smartphone, iPhone where available, and/or suitable configured emulators/simulators
- AI/ML options may include appropriate Dart ML packages, TensorFlow Lite, Google ML Kit/Firebase ML tooling, or Google AI Studio/API integration when they genuinely support the chosen AI Fan Helper implementation; do not add all of them unnecessarily

Treat the hardware list as the SRS development/evaluation baseline, not as a runtime restriction that blocks the application on otherwise supported user devices.

---

# 4. REPOSITORY-FIRST RULE

Before modifying code:

1. Inspect the existing repository and platform folders.
2. Identify Flutter and Dart versions.
3. Inspect `pubspec.yaml`, Firebase configuration, current architecture, tests, and existing features.
4. Preserve useful working code and unrelated user changes.
5. Refactor carefully instead of blindly replacing the project.
6. If no Flutter project exists, create a clean project foundation.
7. Never delete functioning features without explaining and validating the reason.

---

# 5. CODE QUALITY AND HUMANIZATION

The codebase must read like intentional work by a professional human developer who understands it.

Apply:

- Clean Code
- DRY where it improves maintainability
- SOLID principles without overengineering
- Separation of concerns
- Feature-based modularity
- Type safety and null safety
- Reusable components
- Consistent error handling
- Consistent state management
- Dependency injection where useful
- Repository/service boundaries where they add real value

Naming:

- `camelCase` for variables, functions, and methods
- `PascalCase` for classes, widgets, enums, and typedefs
- `snake_case` for Dart filenames
- Clear names such as `AuthService`, `UserRepository`, `EventRepository`, `selectedFandoms`, and `authenticationState`

Avoid meaningless names, giant files, duplicated logic, excessive abstraction, unused dependencies, placeholder implementations, and comments that merely repeat the code.

Use comments only for important reasoning, security decisions, non-obvious business rules, or external integration constraints.

Do not deliberately disguise AI assistance or insert artificial mistakes. Instead, make the implementation genuinely coherent, reviewed, tested, modified where needed, and explainable by the participant.

---

# 6. RECOMMENDED ARCHITECTURE

Use a feature-first structure similar to:

```text
lib/
  main.dart
  app/
    app.dart
    router/
    theme/
  config/
    firebase/
    environment/
  core/
    constants/
    enums/
    errors/
    extensions/
    services/
    utils/
    widgets/
  features/
    authentication/
    profile/
    dashboard/
    fandom/
    bookmarks/
    events/
    merchandise/
    wishlist/
    cart/
    checkout/
    purchases/
    discussions/
    ai_helper/
    notifications/
    contact/
    about/
    admin/
test/
integration_test/
firebase/
  firestore.rules
  storage.rules
  firestore.indexes.json
```

Within each feature, separate presentation, application/state, domain/model, and data/repository concerns to the degree justified by project size. Do not force unnecessary layers or interfaces.

---

# 7. AUTHENTICATION AND AUTHORIZATION

Authentication identifies the user. Authorization determines what the authenticated user may do. Both must be implemented correctly.

Required authentication behavior:

- Landing or role-entry experience for Fan and Admin
- Fan registration with email/password
- Fan login with email/password
- Google OAuth where configured
- Apple OAuth where configured and supported
- Password reset
- Logout
- Persistent authentication state across restart
- Clear loading, success, validation, and error states
- Protection against repeated form submission
- User-friendly mapping of Firebase errors

Fan registration must collect and validate:

- Display name
- Email
- Password and confirmation
- Optional bio/avatar at the appropriate stage
- Primary fandom interests
- Selected profile badge where applicable
- Acceptance of relevant terms/privacy notice if included

After successful Firebase Authentication signup, create the user's Firestore profile safely with the default role `fan`. Handle partial failure between Auth and Firestore explicitly.

Admin behavior:

- Admin accounts are preconfigured/provisioned through a trusted process.
- There is no public admin registration.
- Never hardcode admin passwords in source code.
- Do not trust a role sent by the client.
- Use trusted Firestore role data and/or Firebase custom claims.
- Privileged role changes must occur through a trusted backend/admin process.

Authorization must exist at three levels:

1. UI visibility and navigation
2. Route guards/auth gate
3. Firebase Security Rules and trusted backend enforcement

A Fan must never gain Admin privileges by editing client state, navigating manually, modifying a network request, or changing their Firestore document.

Session edge cases to handle:

- Signed-out user
- Missing user profile document
- Disabled/deleted account
- Invalid or unknown role
- Role loading failure
- Expired session/token
- Firestore offline state
- Admin claim/profile mismatch

Default to least privilege and fail closed.

---

# 8. USER PROFILE AND FAN DASHBOARD

The Fan dashboard must provide clear access to all major Fan modules and summarize relevant personalized information.

Users must be able to view and update permitted profile fields:

- Name/display name
- Bio
- Avatar/profile image
- Favorite/selected fandoms
- Profile badge
- Saved bookmarks
- Bookmarked favorite-star profiles and images
- Offline content
- Wishlist
- Purchase history
- Account metadata where appropriate

Users may edit only their own permitted data. They may not edit their role, security metadata, audit fields, or another user's information.

Avatar/file uploads must validate ownership, path, MIME type, and size. Handle upload progress, cancellation, and failure.

---

# 9. FANDOM EXPLORATION AND MULTIMEDIA HUB

Implement a real content experience containing:

- Beginner Fan Hub
- Profiles
- Stories
- Glossary of fandom terminology
- News
- Image galleries
- Video clips or safe external video integrations
- Podcasts or podcast references/links
- Trending tags
- Trending Fandom carousel
- Popular content
- Deep Dive content
- Hidden trivia
- Advanced lore
- Behind-the-scenes interviews/content

Users must be able to:

- Browse by fandom category
- Search by keyword
- Filter by category, content type, creator, or trending tag where relevant
- Sort where meaningful
- Open complete content details
- Bookmark supported content
- Save appropriate supported content for offline access

Do not ship unrelated lorem ipsum or meaningless placeholder media in the final flow. Seed coherent demonstration data if live editorial integrations are not required.

---

# 10. OFFLINE ACCESS AND SYNCHRONIZATION

Offline support is mandatory, not cosmetic.

Frequently used or explicitly saved data must remain available offline, including where applicable:

- Articles
- Fan stories
- Media metadata and downloaded permitted images
- Bookmarked favorite-star profiles/images
- Saved fandom content
- Event agendas
- User-relevant cached information

Implement:

- Local persistence/cache
- Offline indicators
- Last-synced/updated information where helpful
- Reconnection synchronization
- Conflict-safe writes
- Stale/deleted remote record handling
- Partial-download and storage-failure recovery
- Cache limits/cleanup appropriate for mobile devices

Test cold-start offline behavior, transitions between online/offline states, retry behavior, and sync after reconnection. Never label a feature offline-capable if only its empty UI loads offline.

---

# 11. LOCATION-AWARE EVENTS AND CALENDAR

Implement event discovery for:

- Fan conventions
- Cosplay meetups
- Screening events
- Other relevant fandom events

Required behavior:

- Request location permission contextually
- Handle granted, denied, permanently denied, and unavailable location states
- Show nearby events where permission and event coordinates allow
- Show event location on Google Maps
- Provide event detail including title, description, city, venue/address, date/time, coordinates, category, image, and ticket link
- Browse an event calendar or chronological event list
- Filter events by city and relevant category/date
- Open valid ticket links safely
- Preserve saved event agenda information offline where applicable
- Handle empty results, map/API failure, missing coordinates, and invalid links gracefully

Do not require location permission merely to browse all events.

---

# 12. MERCHANDISE STORE

Create an official fan merchandise browsing experience supporting:

- Apparel
- Collectibles
- Digital assets
- Expandable product categories

Each product should support suitable fields such as name, description, price, image, category, stock/status if used, timestamps, and optional previous price for price-drop logic.

Users must be able to:

- Browse the catalog
- View product details
- Search products
- Filter by category
- Sort by price
- Add/remove products from Wishlist
- Add products to Cart
- Change cart quantity
- Remove cart lines
- View subtotal and final simulated bill
- Complete a simulated checkout
- View purchase history for simulated orders

Important scope rule:

- Do not implement real payment, real purchasing, fulfillment, or delivery.
- Clearly label checkout as simulated/demo checkout.
- Do not collect real payment-card details.
- Generate a clear simulated bill/order summary and persist appropriate purchase history.

Wishlist and cart data must be user-owned and protected by rules.

---

# 13. PRICE-DROP AND APP NOTIFICATIONS

Implement user-specific notifications for price drops and other relevant events.

Requirements:

- Detect or simulate legitimate price-change events from admin-managed prices
- Notify only relevant users who wishlisted the product and have notifications enabled
- Use Firebase Cloud Messaging where configured
- Provide an in-app notification center if selected as a bonus or needed for reliability
- Store user-specific notification state such as read/unread and created time
- Handle permission denial and invalid/expired device tokens
- Avoid duplicate or misleading notifications

Never claim push notifications are functional if backend/token configuration has not been completed and tested. Provide a clean setup boundary when external configuration is required.

---

# 14. AI FAN HELPER

Provide a simple AI-powered assistant that can answer common fandom questions using either:

- Curated/predefined FAQ responses, and/or
- A configured AI API through a secure trusted backend

Required behavior:

- Clear input and send controls
- Conversation display
- Loading state
- Empty-input validation
- Timeout and retry handling
- Offline/unavailable message
- Safe, user-friendly error handling
- Fallback to curated FAQs where appropriate
- Basic safety boundaries and disclaimer that answers may be imperfect
- No secret API key in the Flutter client

Do not fabricate success when an external AI service is unconfigured. Isolate the integration and explain the setup point.

---

# 15. CONTACT US AND ABOUT US

Contact Us must include:

- Validated inquiry form
- Persisted inquiry submission
- Loading/success/failure feedback
- Organization/team contact details
- Google Maps office location(s)

Secure inquiries so ordinary Fans cannot browse other users' messages. Authorized Admins may view and manage inquiries.

About Us must present editable, accurate details about the real project team/people. Do not fabricate identities.

---

# 16. COMMUNITY AND DISCUSSIONS

Because the SRS describes community interaction and provides a Discussions entity, implement a focused, moderated discussion feature unless an approved scope decision explicitly excludes it.

Suggested capabilities:

- Browse discussion threads
- View thread detail
- Create a thread
- Edit/delete one's own thread
- Add a rating if the chosen model uses the SRS rating field
- Report or moderate inappropriate content if practical
- Admin moderation/removal

Ownership and moderation must be enforced in Firestore Security Rules. If this module is formally excluded, record the reason and remove unused fake schema/UI rather than claiming it is complete.

---

# 17. ADMIN SYSTEM

Build a protected Admin dashboard with real management workflows.

Admin capabilities:

- User management
- Fandom content management
- Event management
- Merchandise management
- Category management
- Discussion moderation
- Inquiry management where implemented
- Notification/event announcement management where implemented

For users, provide safe add/provision, list/search, permitted edit/status management, and delete/disable behavior as supported by the trusted backend. Do not perform privileged Firebase Auth administration directly from an untrusted mobile client.

For content, events, products, and categories, support:

- Create
- Read/list/search
- Edit
- Delete with confirmation
- Field validation
- Image upload where needed
- Loading, success, error, and empty states
- Created/updated timestamps
- Audit-friendly actor information for privileged mutations where appropriate

Admin screens alone are not security. Every privileged operation must be denied to Fans by backend rules or trusted server code.

---

# 18. FIRESTORE DATA MODEL

Design a clean, scalable Firestore model. Suggested collections include:

- `users`
- `categories`
- `posts` or `content`
- `events`
- `merchandise`
- `wishlists` or user subcollections
- `carts` or user subcollections
- `orders`/`purchases`
- `bookmarks`
- `discussions`
- `inquiries`
- `notifications`
- `audit_logs` where appropriate

Suggested core fields:

**Users**: uid, displayName, email, bio, avatarUrl, selectedFandoms, badge, role/trusted role reference, createdAt, updatedAt.

**Posts/content**: id, categoryId, contentType, title, body, creator, tags, image/media references, published state, createdAt, updatedAt.

**Events**: id, title, description, categoryId, city, venue/address, latitude, longitude, eventDate, ticketLink, imageUrl, createdAt, updatedAt.

**Merchandise**: id, name, description, price, previousPrice where required, imageUrl, categoryId, type, status/stock where used, createdAt, updatedAt.

**Wishlist**: userId, productId, savedAt.

**Discussions**: id, userId, title, body, rating if used, createdAt, updatedAt.

Use server timestamps where authoritative time matters. Validate references and denormalize only when justified for Firestore query efficiency.

Add required composite indexes and efficient pagination. Do not fetch entire growing collections unnecessarily.

---

# 19. SECURITY RULES AND PRIVACY

Use default-deny Firestore and Storage Rules.

Security expectations:

- Public/guest access only where explicitly intended
- Authenticated users can read permitted published data
- Fans can modify only permitted fields in their own profile
- Fans cannot change role/admin/security fields
- User-owned bookmarks, wishlists, carts, orders, inquiries, and notifications are isolated by UID
- Fans cannot create/edit/delete admin-managed categories, products, events, or published content
- Discussion authors may modify only their own allowed fields; admins may moderate
- Admin access is derived from trusted data/claims
- Storage uploads validate authentication, owner/path, file size, and content type
- All network communication uses HTTPS/TLS
- Managed Firebase encryption at rest is documented
- Sensitive local values use platform-secure storage
- Logs never contain passwords, tokens, secrets, or unnecessary personal data

Write emulator-based security-rule tests where possible.

Test at minimum:

1. Guest attempts protected access.
2. Fan reads permitted content.
3. Fan edits own allowed profile fields.
4. Fan tries to edit another user's profile.
5. Fan tries to assign self the Admin role.
6. Fan tries to access Admin routes manually.
7. Fan tries product/event/category CRUD.
8. Fan tries another user's wishlist/cart/order/inquiry/notification.
9. Admin performs authorized CRUD.
10. Invalid role attempts privileged access.
11. Unauthorized file upload/path manipulation.
12. Deleted/disabled account attempts access.

Every unauthorized case must fail at the backend, even if the client UI is bypassed.

---

# 20. BACKUP, RESTORE, LOGS, AND AUDITABILITY

The SRS requires scheduled automatic backups for records and logs.

Implement or prepare a deployable approach for:

- Scheduled Firestore backups/exports
- Required operational/audit logs
- Least-privilege access to backups
- Retention policy
- Backup failure monitoring/alerts
- Documented restore procedure
- Non-production restore verification

If account permissions, billing, or deployment access prevent enabling scheduled backups now, provide deployable configuration/instructions and mark the item as an external prerequisite. Never falsely state that backups are active.

---

# 21. NON-FUNCTIONAL REQUIREMENTS

## Performance

- Fast startup and responsive navigation
- Smooth transitions and scrolling
- Efficient Firestore queries
- Pagination for growing lists
- Image resizing/caching
- Avoid unnecessary rebuilds and duplicate requests
- Low memory overhead
- Efficient auth/role loading
- Debounced search where appropriate

## Scalability

- Data-driven categories
- Modular features
- Index-aware queries
- Expandable content, events, users, and products
- No architecture tied to a tiny fixed demo dataset

## Accessibility

- Legible fonts
- Sufficient contrast
- Meaningful labels and semantic controls
- Adequate touch targets
- Logical navigation/focus order
- Do not rely only on icons or color for essential meaning
- Respect text scaling where practical

## Reliability and Availability

- Design toward the SRS expectation of 24/7 availability with minimum downtime
- Graceful handling of network loss, empty responses, missing documents, broken images, denied location permission, unavailable AI, notification failure, and API/Firebase outages
- Bounded retries/backoff and timeouts where appropriate
- Idempotent writes where duplicate submission is possible
- Crash/error reporting without exposing secrets
- Useful offline degradation

## Validation

- Validate required fields, lengths, numeric ranges, URLs, dates, ownership, and file uploads
- Validate on client for user experience and at rules/backend for trust
- Show field-specific, actionable errors

---

# 22. UI/UX STANDARD

Create a polished, consistent, mobile-first interface appropriate to the Fandom Universe theme.

Required qualities:

- Consistent color, typography, spacing, and component system
- Responsive layouts across representative phone sizes
- Clear navigation hierarchy
- Proper loading/skeleton states
- Helpful empty states
- Recoverable error states
- Confirmation for destructive actions
- Snackbars/dialogs used intentionally
- Dark/light theme only if implemented consistently
- No clipped text, overflow, broken images, inaccessible contrast, or dead buttons

Do not use a completely ready-made mobile template. Design inspiration or visual boilerplate is acceptable only where allowed, but application structure and logic must be original, understood, and customized.

---

# 23. SEARCH, FILTER, AND SORT

Provide consistent search/filter/sort behavior across relevant modules:

- Fandom content keyword search
- Category/content-type/creator/tag filters
- Events filtered by city/category/date where useful
- Merchandise search and category filtering
- Merchandise price sorting
- Admin list search/filter where useful

Show active filters, a clear-reset option, empty results, and correct behavior with pagination. Avoid performing an expensive backend request on every keystroke.

---

# 24. TESTING AND QUALITY GATES

Use proportionate automated and manual testing.

Include:

- Unit tests for important business logic and validation
- Widget tests for important forms/states
- Repository/service tests using mocks or emulators
- Firebase Security Rules tests
- Integration tests for critical end-to-end flows where practical
- Manual device/emulator verification

Critical flows to verify:

- Fan signup, profile creation, login, password reset, restart persistence, logout
- Admin login and role routing
- Unauthorized role/route/database attempts
- Profile update and avatar failure cases
- Content browse/search/filter/bookmark/offline flow
- Location permission states, map, nearby events, calendar, and ticket links
- Merchandise search/filter/sort
- Wishlist and price-drop behavior
- Cart quantity/update/remove
- Simulated checkout, bill, and purchase history
- AI FAQ/API success, timeout, failure, and unconfigured state
- Contact inquiry security
- Admin CRUD and deletion confirmation
- Offline cold start and reconnect synchronization

After every major phase:

1. Format code.
2. Run static analysis.
3. Fix relevant warnings/errors.
4. Run relevant tests.
5. Test success, failure, empty, offline, and unauthorized states.
6. Confirm no critical regressions.

Do not continue past a broken authentication, authorization, or data-integrity foundation.

---

# 25. IMPLEMENTATION PHASES

Implement incrementally in this order unless the existing repository justifies a small adjustment:

1. Repository inspection and requirements traceability
2. Flutter foundation, environment configuration, theme, routing, and error model
3. Firebase initialization and emulator/configuration strategy
4. Authentication
5. Roles, AuthGate, route protection, and Firestore/Storage rules
6. Fan/Admin shells and dashboards
7. User profile and media upload
8. Categories and fandom content hub
9. Search/filter/trending/deep-dive experiences
10. Bookmarking and true offline persistence/synchronization
11. Events, calendar, location, and Maps
12. Merchandise catalog
13. Wishlist and price-drop notifications
14. Cart, simulated checkout, bill, and purchase history
15. AI Fan Helper
16. Contact Us, About Us, and discussions/community
17. Complete Admin CRUD/moderation workflows
18. Backup/audit/deployment configuration
19. Full testing, security hardening, accessibility, and performance
20. At least three meaningful bonus features
21. Release/deployment preparation when explicitly requested
22. Documentation/submission phase when explicitly requested

For each phase, inspect existing work, state the intended changes briefly, implement only real functionality, test it, and report verified results and any external prerequisites.

---

# 26. COMPLETE USER FLOW

## Application startup

```text
App launch
-> Firebase initialization
-> Auth state loading
-> If signed out: landing/login/registration options
-> If signed in: load trusted user profile/role
-> Fan role: Fan dashboard
-> Admin role: Admin dashboard
-> Missing/invalid role: safe error/recovery flow with no privileged access
```

## Fan registration and entry

```text
Landing
-> Fan registration
-> Enter identity and fandom preferences
-> Validate form
-> Firebase Auth account creation
-> Secure Firestore profile creation with role=fan
-> AuthGate loads profile/role
-> Fan dashboard
```

## Fan experience

```text
Fan dashboard
-> Explore beginner hub, profiles, stories, glossary, news, galleries, videos, podcasts
-> Search/filter and open details
-> View trending carousel and Deep Dive content
-> Bookmark content/profiles/images and access saved items offline
-> Discover nearby events, map, calendar, city filter, ticket links
-> Browse merchandise, search/filter/sort, wishlist items
-> Receive configured price-drop notification
-> Manage cart
-> Complete simulated checkout
-> View bill and purchase history
-> Ask AI Fan Helper questions
-> Use discussions/community
-> Submit Contact Us inquiry
-> View/update profile
-> Logout
```

## Admin experience

```text
Preconfigured Admin login
-> AuthGate verifies trusted Admin role
-> Admin dashboard
-> Manage users
-> Manage categories
-> Manage fandom content/media metadata
-> Manage events
-> Manage merchandise/prices
-> Moderate discussions
-> Manage inquiries/notifications where implemented
-> Every privileged write is rule/backend protected and audit-friendly
-> Logout
```

---

# 27. CORE ACCEPTANCE CHECKLIST

The application is not complete until all relevant items are genuinely implemented and verified:

## Authentication and security

- Fan registration
- Email/password login
- Google/Apple OAuth where configured
- Password reset
- Logout
- Session persistence
- Preconfigured Admin login
- User profile creation
- Trusted role loading
- Protected routing
- Firestore and Storage Rules
- No privilege escalation
- User-owned data isolation
- Security tests

## Fan/profile/content

- Bio, avatar, badges, favorite fandoms
- Beginner Fan Hub
- Profiles, stories, glossary
- News, gallery, videos, podcasts
- Creator/category/tag filters
- Keyword search
- Trending carousel
- Deep Dive, hidden trivia, advanced lore, behind-the-scenes content
- Bookmarked profiles and images
- Real offline access and synchronization

## Events

- Location permission handling
- Nearby events
- Conventions, cosplay meetups, screening events
- Google Map
- Calendar/list
- City filter
- Ticket link
- Offline agenda data

## Merchandise

- Apparel, collectibles, digital assets
- Catalog and product detail
- Search, category filter, price sorting
- Wishlist
- Price-drop notification setup
- Cart add/update/remove
- Simulated checkout only
- Bill and purchase history
- No real payment-card collection

## AI/general/community

- AI Fan Helper
- FAQ and/or secure AI API capability
- Loading/error/offline handling
- Contact inquiry form, contact details, office map
- About Us
- Discussions/community and moderation, or an approved documented exclusion

## Admin

- User management
- Content management
- Event management
- Merchandise management
- Category management
- Discussion/inquiry moderation where applicable
- Real CRUD with validation, confirmations, and backend authorization

## Non-functional

- Performance
- Security and encryption strategy
- Scalability
- Accessibility
- Reliability and graceful failure handling
- Offline access
- Scheduled backup/restore approach
- Maintainable, human-readable architecture
- Tests and clean analyzer result

---

# 28. BONUS FEATURES

Only after all core SRS requirements pass, implement at least three meaningful, integrated bonus features. Select features that improve real user value, such as:

- Personalized fandom recommendations
- Personalized home feed
- Real-time Admin analytics
- Automated event reminders
- Intelligent merchandise recommendations
- Advanced search
- AI-assisted content summaries
- In-app notification center
- Accessibility enhancements
- Meaningful reporting/dashboard insights

Do not count superficial buttons, fake analytics, static charts, or renamed core requirements as bonus features.

---

# 29. AI AND COMPETITION INTEGRITY

AI is a supporting tool, not a replacement for participant skill and understanding.

- Do not submit AI-generated code/content without meaningful human review, modification, and testing.
- Maintain an AI-use register listing the tools used, their purpose, and material assistance.
- The participant must understand and be able to explain the architecture, state management, security rules, database design, integrations, and important code.
- Do not use a completely ready-made application template.
- Do not generate the final competition report wholesale on the participant's behalf. AI may assist with outlines, editing, evidence organization, and verification, but the participant must author, validate, and own the final submission.

---

# 30. FINAL DOCUMENTATION AND SUBMISSION - LATER, NOT NOW

When the user explicitly begins the final documentation phase, prepare concise, original, professional documentation with a maximum of 30 pages and no source-code listings.

It must accurately represent the implemented application and include:

- Problem definition
- Objectives and real-world impact
- Design specifications
- Implemented architecture
- Technology stack
- Database design/data dictionary
- Test data, plan, results, and screenshots
- Timeline
- Installation instructions
- Demo user/Admin credentials
- Assumptions
- AI-tool acknowledgements
- Live deployment link and QR code when deployment is feasible

Required customized diagrams:

- ER Diagram
- Use Case Diagram
- Class Diagram
- Sequence Diagram
- Activity Diagram
- DFD Level 0
- DFD Level 1
- DFD Level 2
- System Architecture Diagram

Final submission artifacts must include as required:

- Source-code ZIP
- Professional GitHub repository
- Professional `README.md`
- `ReadMe.doc` or organizer-approved equivalent listing assumptions/setup
- Final report
- Database definitions and reproducible configuration
- Firestore/Storage Rules and indexes
- Installation instructions
- Dedicated judging credentials
- Android APK
- iOS IPA where required and build environment permits
- Mandatory MP4 demonstration video, targeting five minutes where required
- Live link and QR code where applicable
- AI-use acknowledgement

Because the runtime database is Firebase/Firestore, supply its actual schema/data dictionary, rules, indexes, and reproducible setup/export artifacts. The SRS also mentions `.sql` scripts. Do not misleadingly claim SQL powers Firestore. Confirm the evaluator's accepted Firebase equivalent; if a literal SQL file remains mandatory, provide a clearly labeled relational reference schema for submission compatibility and state that the live application uses Firestore.

---

# 31. FINAL COMPLETION GATE

Do not declare the project complete until:

1. Every SRS requirement is mapped to implementation and verification evidence.
2. All Fan and Admin flows operate with real persistence.
3. Unauthorized access fails in Firebase/trusted backend, not merely in UI.
4. Offline content and reconnection behavior are demonstrated.
5. Maps, notifications, AI, and other external integrations either work and are tested or expose an honest, cleanly documented configuration prerequisite.
6. Performance, accessibility, error, empty, loading, and offline states are verified.
7. Backup/restore configuration is active or honestly identified as an external deployment prerequisite.
8. At least three meaningful bonus features are added only after the core is stable.
9. The participant has reviewed and can explain all important work.
10. In the later submission phase, every required report, diagram, package, credential, video, and deployment artifact is validated.

---

# 32. EXECUTION INSTRUCTION

When the user explicitly authorizes development:

1. Inspect the repository first.
2. Create/update the requirements traceability checklist.
3. Report the existing state and immediate implementation phase briefly.
4. Begin with the application foundation, Firebase setup, Authentication, Authorization, AuthGate, protected routes, and Security Rules.
5. Implement incrementally in the defined phase order.
6. Run formatting, analysis, and relevant tests after every meaningful phase.
7. Never claim unverified functionality.
8. Never weaken security for convenience.
9. Preserve useful existing work.
10. Keep every major decision consistent with the SRS and this prompt.

The required outcome is:

**Professional + Secure + Original + Human-Reviewed + Modular + Fully Functional + Explainable + Competition-Ready.**

Do not start until the user explicitly says to begin.
