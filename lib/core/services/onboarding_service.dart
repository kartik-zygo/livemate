import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the intro has been seen, so it runs exactly once per
/// install rather than on every cold start.
///
/// Deliberately keyed with a version suffix: if the intro is ever rewritten
/// around a new feature, bumping the key shows it again to people who have
/// already been through the old one.
class OnboardingService extends GetxService {
  static const String _seenKey = 'livemate.onboarded.v1';

  SharedPreferences? _prefs;

  final RxBool seen = false.obs;

  Future<OnboardingService> init() async {
    _prefs = await SharedPreferences.getInstance();
    seen.value = _prefs?.getBool(_seenKey) ?? false;
    return this;
  }

  Future<void> markSeen() async {
    seen.value = true;
    await _prefs?.setBool(_seenKey, true);
  }

  /// Only used from a debug build or a test — nothing in the UI calls it.
  Future<void> reset() async {
    seen.value = false;
    await _prefs?.remove(_seenKey);
  }
}
