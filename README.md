# Livemate

**Find your place. Find your people.**

A two-sided marketplace for shared housing in India, built to the Livemate API
specification. Package name `com.livematex.app` — see
[RELEASING.md](RELEASING.md) for the Play Store pipeline.

- **Tenant listings** — someone has a room and wants a flatmate.
- **Finder posts** — someone is looking for a room, either self-serve or with a
  Livemate manager's help.

The core loop is **browse → enquire → owner accepts → contact details revealed →
move in**. Every screen serves that sequence.

---

## Running it

All configuration lives in a single `.env` file at the project root. Copy the
template, paste your Supabase key into it, and run — no build flags needed.

```bash
flutter pub get
cp .env.example .env
# open .env and fill in SUPABASE_ANON_KEY=
flutter run
```

`.env` is git-ignored; `.env.example` is the committed template. A fresh clone
must copy it before building, because `.env` is declared as an asset.

### What is in .env

| Key | Default | Notes |
| --- | --- | --- |
| `SUPABASE_ANON_KEY` | *(empty — required)* | The project's publishable ("anon") key |
| `SUPABASE_URL` | `https://nlpvkgtyrlbybobxzhex.supabase.co` | Issues the JWTs the API verifies |
| `API_SERVER_ROOT` | `https://www.zygonich.com/livemate` | `/health` here, everything else under `/api/v1` |
| `CONNECT_TIMEOUT_SECONDS` | `20` | |
| `RECEIVE_TIMEOUT_SECONDS` | `30` | |
| `MAX_PHOTOS_PER_LISTING` | `4` | Server-enforced; mirrored client-side |
| `MIN_PHOTOS_TO_PUBLISH` | `3` | Below this a listing stays a DRAFT |
| `MAX_PHOTO_MB` | `2` | |
| `MAX_SEARCH_RESULTS` | `50` | Hard cap, no pagination |
| `MAX_TAGS_PER_FINDER_POST` | `5` | |

Every value except the key is already filled in from the specification — the key
is the one thing the spec deliberately withheld ("read it from the web app's
`.env`; never commit secrets"). Without it the app boots into a setup screen
naming exactly what is missing, rather than a login form that could never
succeed.

A `--dart-define` of the same name still overrides the file, so CI can inject
values without writing one:

```bash
flutter build apk --dart-define=SUPABASE_ANON_KEY=<the key>
```

### HTTPS only

The API is served over HTTPS at `https://www.zygonich.com/livemate`, so neither
platform carries a cleartext exception: no `network_security_config.xml` on
Android and no `NSAppTransportSecurity` block in `ios/Runner/Info.plist`. An
`http://` value for `API_SERVER_ROOT` will be blocked on device.

---

## Architecture

MVVM over GetX, exactly as the spec lays out.

```
lib/
├── main.dart
├── app/
│   ├── routes/        app_pages.dart, app_routes.dart
│   ├── theme/         app_colors.dart, app_theme.dart, app_text_styles.dart
│   └── bindings/      initial_binding.dart
├── core/
│   ├── network/       dio_client.dart, auth_interceptor.dart, api_exception.dart
│   ├── config/        env.dart, api_endpoints.dart
│   ├── services/      auth, reference (cities/tags), shortlist, enquiry badge
│   ├── utils/         formatters.dart, validators.dart, enum_meta.dart, json_utils.dart
│   └── widgets/       the shared design system
├── data/
│   ├── models/        one per entity, plus enums.dart and search_filters.dart
│   ├── providers/     raw Dio calls, one per resource
│   └── repositories/  models in and out, error mapping
└── modules/
    ├── dashboard/     the shell: sections, drawer, command bar, Home
    └── <feature>/     views · widgets · controllers · bindings
```

**Layering rules, enforced throughout:**

- **View** — widgets only. No business logic, no Dio, no `setState` for app
  state. Reads through `Obx`.
- **ViewModel** — `GetxController` holding `Rx` state, calling repositories.
- **Model** — repositories are the only thing that touches providers.

DI is per-route `Bindings` with `Get.lazyPut`; app-wide state is a `GetxService`
registered with `Get.putAsync` in `InitialBinding`. Navigation is named routes
only.

One naming note: controllers expose `reload()` rather than `refresh()`, because
`GetxController` already defines a synchronous `refresh()` for its own change
notification.

### The dependency graph

`DioClient` reads its bearer token straight off the Supabase client rather than
from `AuthService`. That breaks what would otherwise be a cycle — `AuthService`
needs `UserRepository`, which needs `DioClient`, which would need `AuthService`
for the token.

The auth interceptor is a `QueuedInterceptor`: on a 401 it refreshes the session
once, replays the request, and gives up cleanly if the session is genuinely
gone. Concurrent 401s do not each trigger a refresh.

---

## Screens

All fourteen from the spec, behind **one dashboard page**. There is no bottom
navigation bar; the shell in [`modules/dashboard/`](lib/modules/dashboard/)
holds six sections in an `IndexedStack` so each keeps its scroll position and
loaded results:

**Home · Discover · Search · Enquiries · Shortlist · Profile**

Two ways to move between them, both driving the one `DashboardController`:

- **The section rail** — a scrolling row of glass pills in the floating command
  bar, for switching between sections you are working in.
- **The app drawer** — the full map, adding My listings, My finder posts, Edit
  profile, both create flows and sign out.

The command bar also carries the one city control in the app (shown only where
results are city-scoped) and the create action. Back walks you out of a section
before it walks you out of the app.

**Home** is the dashboard proper: counts that link into the sections they
count, quick actions, a strip of the newest rooms in your city and one of the
people looking there. It reads entirely from controllers the other sections
already keep warm, so opening it costs no extra requests.

A live pending-enquiry badge, driven by
`GET /enquiries/received/pending-count`, appears on both the rail and the
drawer.

| # | Screen | Key calls |
| --- | --- | --- |
| 1 | Splash / auth gate | session check → `GET /auth/me` |
| 2 | Login | Supabase `signInWithPassword` |
| 3 | Sign up | `signUp` → sign in → `GET /auth/me` |
| 4 | Discover | `GET /search/tenant-listings` + a finder-post strip |
| 5 | Search + filters | city picker, the full filter param set, Rooms/People toggle |
| 6 | Listing detail | `GET /tenant-listings/:id`, save, enquire |
| 7 | Create listing | 5 steps → `POST /tenant-listings`, then photos |
| 8 | Finder post detail | `GET /finder-posts/:id` |
| 9 | Create finder post | 3 steps, tier choice → `POST /finder-posts` |
| 10 | Enquiries — Received | `GET /enquiries/received`, `PATCH /enquiries/:id` |
| 11 | Enquiries — Sent | `GET /enquiries/sent` |
| 12 | Shortlist | `GET /saved-listings` |
| 13 | Profile | `GET /users/me`, `GET /legal`, `DELETE /users/me` |
| 14 | Edit profile | `PATCH /users/me` |

Plus **My listings** and **My finder posts**, reachable from the drawer, from
Home and from Profile, so the owner side of `/mine` is actually usable.

---

## The invariants this app is built around

**The contact gate.** `ownerContact` and `senderContact` are null until an
enquiry is accepted. `ContactCard` renders nothing at all when handed a null
contact — it cannot degrade into a blank row that looks like missing data.
Pending and declined states get their own explicit copy instead.

**City-only geography.** There are no coordinates, localities or radius anywhere
in this product, and no map or geolocation package is installed. `GET /cities`
is fetched once, cached to disk, and filtered in memory — prefix matches ranked
first, so typing "pun" surfaces Pune above Rajpura. Every row shows
"name, state" because city names repeat across states. `cityId` is required to
post or to search, and the UI blocks both with an inviting empty state rather
than showing empty results.

**No distance.** `ListingSort.DISTANCE` still exists server-side but silently
falls back to newest-first, so the app does not offer it and never renders a
"…km away" label.

**The 50-result cap.** Search returns at most 50 rows with no pagination. Both
feeds say so at the bottom and point at the filters, rather than letting someone
scroll waiting for a page two that will not come.

**Photos.** Multipart to `POST /tenant-listings/:id/photos`, field `file`, JPEG
/ PNG / WebP under 2 MB. The 3-photo publish threshold and 4-photo ceiling are
enforced client-side and shown as a progress meter. Photos display via
`GET /media/photos/:id`, which is public and immutably cached — no auth header,
no presign round trip.

**Finder posts publish immediately.** `POST /finder-posts` answers `201` with
the post already `ACTIVE`. There is no order step; the tier is only a choice of
how much help the poster wants, and it defaults to self-serve.

**Error messages.** NestJS returns `message` as a String *or* a List of strings.
`ApiException` handles both and keeps the full list so a form can surface every
field error at once.

---

## Design

Warm terracotta (`#f97316`) with a teal accent (`#14b8a6`), matching the web
app's re-theme.

- **Ambient field** — three or four large soft colour circles behind every
  screen, painted with radial gradients in a `CustomPainter` rather than a
  full-screen `BackdropFilter`, which is visually equivalent at this radius and
  far cheaper on mid-range Android.
- **Frosted glass** — white at ~55% with a white hairline and a soft warm
  shadow. `GlassCard` takes `blur: false` for list rows, where a real
  `BackdropFilter` per row is the one place this pattern gets expensive.
- **Glass** — every surface in the app is a frosted pane built from one
  primitive, `GlassSurface` in
  [`core/widgets/glass.dart`](lib/core/widgets/glass.dart): a saturated
  backdrop blur, a diagonal fill running bright-to-thin, a specular hotspot in
  the lit corner, and a gradient rim light stroked over the content so the edge
  survives whatever sits inside. `GlassCard`, `GlassPanel`, `GlassPill`,
  `GlassIconButton` and `GlassSheet` are all thin wrappers over it.
- **The field behind the glass** — `AmbientBackground` paints six large soft
  colour blobs, drifting on slow orbits, that the panes sample. Two of them are
  cool (violet, sky) and appear nowhere else in the palette: a pane sampling one
  hue looks tinted, while a pane sampling a field that shifts hue across its
  width picks up a gradient of its own, which is what reads as refraction. The
  shell owns exactly one animated instance for the whole session.
- **Turning the blur off** — `Glass.enableBackdropBlur` is the single switch. It
  drops only the sampled blur and keeps the fills, rim light and shadows, for
  when the app has to run on low-end hardware.
- **Motion** — cards scale on press (200ms `easeOutCubic`); lists enter as
  fade + 14px slide-up staggered ~50ms, capped at 8 items so a long list does
  not trail. Reduced-motion is honoured.
- **Loading** — shimmer skeletons shaped like the real card, never a bare
  spinner.
- **Empty states** — a custom SVG illustration, one line, and a way forward.
  Nine hand-authored vectors live in `assets/illustrations/`.
- **Money** — always `₹` with `en_IN` grouping: ₹15,000, ₹1,20,000.
- **Accessibility** — `brand-700` for text on light (never `brand-500`), 44×44
  minimum tap targets, semantic labels on every icon-only button, and text
  scaling clamped at 1.35× so dense cards bend rather than break.

Type uses the platform UI font with a tuned scale (headings 700–800 with tight
tracking, body 400–500). To move to Inter or Geist, drop the `.ttf` files into
`assets/fonts/`, declare a `fonts:` block in `pubspec.yaml`, and set `_family`
in [`app_text_styles.dart`](lib/app/theme/app_text_styles.dart).

---

## Brand

The mark is a house holding two people who have found each other; their clasped
arms are the diagonal that reads as the **M** in the wordmark.

| Asset | Path |
| --- | --- |
| Mark (authoritative, in-app) | `assets/brand/livemate_mark.svg` |
| Wordmark + lockup widgets | [`core/widgets/brand.dart`](lib/core/widgets/brand.dart) |
| Launcher icon source | `assets/brand/icon.png` |
| Android adaptive layers | `assets/brand/icon_foreground.png`, `icon_background.png` |

The PNGs are generated from the same coordinates as the SVG:

```bash
python tool/brand/generate_brand_assets.py   # redraw the sources
dart run flutter_launcher_icons              # fan them out to every platform
```

There is no SVG rasteriser on this toolchain, so
`tool/brand/generate_brand_assets.py` re-draws the mark from the identical
512-unit coordinate system rather than converting it. Change one, change both.

---

## Tests

```bash
flutter test
flutter analyze
```

The suite covers the invariants that would be expensive to get wrong: enum wire
round-tripping and its fallback behaviour, `en_IN` currency formatting, the
null/past/future availability rule, the enquiry contact gate across all three
statuses, filter query serialisation, and payload pruning.

[`test/glass_test.dart`](test/glass_test.dart) covers the design system's own
invariants: that a glass pane sizes to its child under loose, tight and
unbounded constraints, that icon buttons keep a 44px tap target however small
the disc is, and that `DashboardSection`'s order still matches the
`IndexedStack` children it indexes.

---

## Deliberately not built

Matching the spec's known gaps: no maps or geolocation, no in-app messaging
(the loop ends at contact reveal), no reviews or ratings, no pagination, no push
notifications. Photos live in Postgres as an interim measure. `GET /cities`
requires auth, so there is no logged-out browse experience.
