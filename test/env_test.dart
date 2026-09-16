import 'package:livemate/core/config/env.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads a fake .env in place of the real file.
void loadEnv(String contents) => dotenv.testLoad(fileInput: contents);

void main() {
  group('Env defaults', () {
    setUp(() => loadEnv(''));

    test('falls back to the spec values when the file is empty', () {
      expect(Env.serverRoot, 'https://www.zygonich.com/livemate');
      expect(Env.apiBaseUrl, 'https://www.zygonich.com/livemate/api/v1');
      expect(Env.supabaseUrl, 'https://nlpvkgtyrlbybobxzhex.supabase.co');
      expect(Env.connectTimeout, const Duration(seconds: 20));
      expect(Env.receiveTimeout, const Duration(seconds: 30));
      expect(Env.maxPhotosPerListing, 4);
      expect(Env.minPhotosToPublish, 3);
      expect(Env.maxPhotoBytes, 2 * 1024 * 1024);
      expect(Env.maxSearchResults, 50);
      expect(Env.maxTagsPerFinderPost, 5);
    });

    test(
      'reports the anon key as missing so main() can show the setup screen',
      () {
        expect(Env.supabaseAnonKey, isEmpty);
        expect(Env.hasSupabaseCredentials, isFalse);
        expect(Env.missingKeys, ['SUPABASE_ANON_KEY']);
      },
    );
  });

  group('Env overrides', () {
    test('reads every value from the file', () {
      loadEnv('''
SUPABASE_ANON_KEY=test-key
SUPABASE_URL=https://example.supabase.co
API_SERVER_ROOT=https://api.flatmate.test
CONNECT_TIMEOUT_SECONDS=5
RECEIVE_TIMEOUT_SECONDS=7
MAX_PHOTOS_PER_LISTING=6
MIN_PHOTOS_TO_PUBLISH=2
MAX_PHOTO_MB=4
MAX_SEARCH_RESULTS=25
MAX_TAGS_PER_FINDER_POST=3
''');

      expect(Env.supabaseAnonKey, 'test-key');
      expect(Env.supabaseUrl, 'https://example.supabase.co');
      expect(Env.serverRoot, 'https://api.flatmate.test');
      expect(Env.apiBaseUrl, 'https://api.flatmate.test/api/v1');
      expect(Env.connectTimeout, const Duration(seconds: 5));
      expect(Env.receiveTimeout, const Duration(seconds: 7));
      expect(Env.maxPhotosPerListing, 6);
      expect(Env.minPhotosToPublish, 2);
      expect(Env.maxPhotoBytes, 4 * 1024 * 1024);
      expect(Env.maxSearchResults, 25);
      expect(Env.maxTagsPerFinderPost, 3);
      expect(Env.hasSupabaseCredentials, isTrue);
      expect(Env.missingKeys, isEmpty);
    });

    test('tolerates a trailing slash on either URL', () {
      loadEnv('''
API_SERVER_ROOT=http://10.0.0.1:8095/
SUPABASE_URL=https://example.supabase.co/
''');
      expect(Env.serverRoot, 'http://10.0.0.1:8095');
      expect(Env.apiBaseUrl, 'http://10.0.0.1:8095/api/v1');
      expect(Env.supabaseUrl, 'https://example.supabase.co');
    });

    test('a blank or whitespace value falls back rather than blanking out', () {
      loadEnv('''
API_SERVER_ROOT=
SUPABASE_URL=
''');
      expect(Env.serverRoot, 'https://www.zygonich.com/livemate');
      expect(Env.supabaseUrl, 'https://nlpvkgtyrlbybobxzhex.supabase.co');
    });

    test('a non-numeric limit falls back instead of crashing at startup', () {
      loadEnv('MAX_SEARCH_RESULTS=lots\nCONNECT_TIMEOUT_SECONDS=soon');
      expect(Env.maxSearchResults, 50);
      expect(Env.connectTimeout, const Duration(seconds: 20));
    });

    test('flags a cleartext API root, which neither platform allows', () {
      loadEnv('API_SERVER_ROOT=http://10.0.0.1:8095');
      expect(Env.usesCleartextApi, isTrue);

      loadEnv('API_SERVER_ROOT=https://api.flatmate.test');
      expect(Env.usesCleartextApi, isFalse);
    });
  });
}
