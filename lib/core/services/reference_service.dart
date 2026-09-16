import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/city_model.dart';
import '../../data/models/tag_model.dart';
import '../../data/repositories/reference_repository.dart';
import '../network/api_exception.dart';

/// Cities and tags: fetched once, cached on disk, then filtered in memory.
///
/// 652 cities across 36 states is small enough that a request per keystroke
/// would be slower and no more accurate — so the typeahead never touches the
/// network. `GET /cities` requires auth, so the fetch happens after sign-in.
class ReferenceService extends GetxService {
  ReferenceService(this._repo);

  final ReferenceRepository _repo;

  static const String _citiesKey = 'flatmate.cities.v1';
  static const String _tagsKey = 'flatmate.tags.v1';
  static const String _lastCityKey = 'flatmate.lastCityId.v1';

  final RxList<CityModel> cities = <CityModel>[].obs;
  final RxList<TagModel> tags = <TagModel>[].obs;
  final RxBool loading = false.obs;
  final RxnString loadError = RxnString();

  /// The city the user last browsed, restored across launches so Discover has
  /// something to show immediately.
  final Rxn<CityModel> selectedCity = Rxn<CityModel>();

  SharedPreferences? _prefs;
  Map<String, CityModel> _byId = const {};

  bool get isReady => cities.isNotEmpty;

  Future<ReferenceService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _restoreFromDisk();
    return this;
  }

  /// Loads reference data if it is missing or [force] is set. Safe to call on
  /// every sign-in; it is a no-op once warm.
  Future<void> ensureLoaded({bool force = false}) async {
    if (loading.value) return;
    if (!force && cities.isNotEmpty && tags.isNotEmpty) return;

    loading.value = true;
    loadError.value = null;
    try {
      final results = await Future.wait([_repo.cities(), _repo.tags()]);
      cities.assignAll(results[0] as List<CityModel>);
      tags.assignAll(results[1] as List<TagModel>);
      _reindex();
      await _persist();
      _restoreSelectedCity();
    } on ApiException catch (e) {
      // Stale cache still beats an empty picker.
      loadError.value = cities.isEmpty ? e.message : null;
    } finally {
      loading.value = false;
    }
  }

  CityModel? cityById(String? id) => id == null ? null : _byId[id];

  /// Ranks prefix matches first so typing "pun" surfaces Pune above Rajpura,
  /// then falls back to substring hits on either the city or the state.
  List<CityModel> search(String query, {int limit = 40}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return cities.take(limit).toList(growable: false);

    final namePrefix = <CityModel>[];
    final statePrefix = <CityModel>[];
    final contains = <CityModel>[];

    for (final city in cities) {
      if (city.searchName.startsWith(q)) {
        namePrefix.add(city);
      } else if (city.searchState.startsWith(q)) {
        statePrefix.add(city);
      } else if (city.searchName.contains(q) || city.searchState.contains(q)) {
        contains.add(city);
      }
    }

    return [
      ...namePrefix,
      ...statePrefix,
      ...contains,
    ].take(limit).toList(growable: false);
  }

  List<TagModel> tagsIn(TagCategoryFilter filter) =>
      tags.where((t) => filter.matches(t)).toList(growable: false);

  Future<void> selectCity(CityModel? city) async {
    selectedCity.value = city;
    if (city == null) {
      await _prefs?.remove(_lastCityKey);
    } else {
      await _prefs?.setString(_lastCityKey, city.id);
    }
  }

  void _reindex() {
    _byId = {for (final c in cities) c.id: c};
  }

  void _restoreFromDisk() {
    final prefs = _prefs;
    if (prefs == null) return;

    final rawCities = prefs.getString(_citiesKey);
    if (rawCities != null) {
      try {
        final decoded = jsonDecode(rawCities);
        if (decoded is List) {
          cities.assignAll(
            decoded.whereType<Map>().map(
              (e) => CityModel.fromJson(Map<String, dynamic>.from(e)),
            ),
          );
        }
      } catch (_) {
        prefs.remove(_citiesKey);
      }
    }

    final rawTags = prefs.getString(_tagsKey);
    if (rawTags != null) {
      try {
        final decoded = jsonDecode(rawTags);
        if (decoded is List) {
          tags.assignAll(
            decoded.whereType<Map>().map(
              (e) => TagModel.fromJson(Map<String, dynamic>.from(e)),
            ),
          );
        }
      } catch (_) {
        prefs.remove(_tagsKey);
      }
    }

    _reindex();
    _restoreSelectedCity();
  }

  void _restoreSelectedCity() {
    if (selectedCity.value != null) return;
    final id = _prefs?.getString(_lastCityKey);
    final city = cityById(id);
    if (city != null) selectedCity.value = city;
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(
      _citiesKey,
      jsonEncode(cities.map((c) => c.toJson()).toList()),
    );
    await prefs.setString(
      _tagsKey,
      jsonEncode(tags.map((t) => t.toJson()).toList()),
    );
  }
}

/// Small predicate wrapper so callers can ask for "all tags" or one category
/// without two separate methods.
class TagCategoryFilter {
  const TagCategoryFilter(this._test);

  final bool Function(TagModel) _test;

  bool matches(TagModel tag) => _test(tag);

  static const TagCategoryFilter all = TagCategoryFilter(_always);

  static bool _always(TagModel _) => true;
}
