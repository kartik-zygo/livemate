import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Every configurable value in the app, read from the `.env` file at the
/// project root.
///
///   cp .env.example .env      # then paste your Supabase key into it
///   flutter run
///
/// No build flags are needed. `.env` is loaded by [load] before anything else
/// in `main()`, and is git-ignored — `.env.example` is the committed template.
///
/// A `--dart-define` of the same name still wins over the file, so CI can
/// inject values without writing one:
///
///   flutter build apk --dart-define=SUPABASE_ANON_KEY=...
class Env {
  const Env._();

  /// Reads `.env` into memory. Safe to call when the file is missing or
  /// malformed — the values simply fall back to their defaults, and
  /// [missingKeys] reports what is still unset.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // A missing or unreadable .env is not fatal here; main() checks
      // hasSupabaseCredentials and shows the setup screen instead.
      dotenv.testLoad(fileInput: '');
    }
  }

  // ── Readers ────────────────────────────────────────────────────────────
  // Precedence: --dart-define > .env > default.

  static String _string(String key, String fallback) {
    const defines = <String, String>{
      'SUPABASE_ANON_KEY': String.fromEnvironment('SUPABASE_ANON_KEY'),
      'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL'),
      'API_SERVER_ROOT': String.fromEnvironment('API_SERVER_ROOT'),
    };

    final define = defines[key];
    if (define != null && define.isNotEmpty) return define;

    final value = dotenv.maybeGet(key)?.trim();
    return (value == null || value.isEmpty) ? fallback : value;
  }

  static int _int(String key, int fallback) {
    final raw = dotenv.maybeGet(key)?.trim();
    if (raw == null || raw.isEmpty) return fallback;
    return int.tryParse(raw) ?? fallback;
  }

  // ── API ────────────────────────────────────────────────────────────────

  /// Root of the REST API. `/health` lives here; everything else hangs off
  /// [apiBaseUrl]. A trailing slash in `.env` is tolerated.
  static String get serverRoot => _string(
    'API_SERVER_ROOT',
    'https://www.zygonich.com/livemate',
  ).replaceAll(RegExp(r'/+$'), '');

  static String get apiBaseUrl => '$serverRoot/api/v1';

  // ── Supabase ───────────────────────────────────────────────────────────

  static String get supabaseUrl => _string(
    'SUPABASE_URL',
    'https://nlpvkgtyrlbybobxzhex.supabase.co',
  ).replaceAll(RegExp(r'/+$'), '');

  /// The project's publishable ("anon") key. Required — there is no sensible
  /// default, since it is specific to the Supabase project.
  static String get supabaseAnonKey => _string(
    'SUPABASE_ANON_KEY',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5scHZrZ3R5cmxieWJvYnh6aGV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcwNTMyMDksImV4cCI6MjEwMjYyOTIwOX0.yjzvIge8Y4mfZsAmdUXyW-p95kbsV0FD1Rp2qS2L6jk',
  );

  // ── Timeouts ───────────────────────────────────────────────────────────

  static Duration get connectTimeout =>
      Duration(seconds: _int('CONNECT_TIMEOUT_SECONDS', 20));

  static Duration get receiveTimeout =>
      Duration(seconds: _int('RECEIVE_TIMEOUT_SECONDS', 30));

  // ── Server-enforced limits ─────────────────────────────────────────────
  // Mirrored client-side so a user finds out before a round trip, not after.

  static int get maxPhotosPerListing => _int('MAX_PHOTOS_PER_LISTING', 4);

  static int get minPhotosToPublish => _int('MIN_PHOTOS_TO_PUBLISH', 3);

  static int get maxPhotoBytes => _int('MAX_PHOTO_MB', 2) * 1024 * 1024;

  /// Search returns at most this many rows and has no pagination.
  static int get maxSearchResults => _int('MAX_SEARCH_RESULTS', 50);

  static int get maxTagsPerFinderPost => _int('MAX_TAGS_PER_FINDER_POST', 5);

  /// The only image types `POST /tenant-listings/:id/photos` accepts.
  static const List<String> allowedPhotoExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  /// Cities Livemate covers, across all 36 states and union territories. Copy
  /// only — the real list comes from `GET /cities`.
  static const int cityCount = 652;

  // ── Validation ─────────────────────────────────────────────────────────

  /// True when the app has everything it needs to reach Supabase.
  static bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Keys that are still unset, for the setup screen to list by name.
  static List<String> get missingKeys => [
    if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    if (supabaseUrl.isEmpty) 'SUPABASE_URL',
    if (serverRoot.isEmpty) 'API_SERVER_ROOT',
  ];

  /// Whether the configured API root is plain HTTP. Neither platform carries a
  /// cleartext exception any more, so such a root is blocked on device.
  static bool get usesCleartextApi => serverRoot.startsWith('http://');
}
