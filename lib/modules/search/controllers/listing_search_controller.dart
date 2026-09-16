import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/reference_service.dart';
import '../../../data/models/city_model.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/finder_post_model.dart';
import '../../../data/models/search_filters.dart';
import '../../../data/models/tenant_listing_model.dart';
import '../../../data/repositories/search_repository.dart';

enum SearchMode { rooms, people }

/// Named [ListingSearchController] rather than SearchController — Flutter's
/// material library already exports a class by that name.
class ListingSearchController extends GetxController {
  ListingSearchController(this._search, this._reference);

  final SearchRepository _search;
  final ReferenceService _reference;

  final Rx<SearchMode> mode = SearchMode.rooms.obs;

  final Rx<ListingSearchFilters> listingFilters =
      const ListingSearchFilters().obs;
  final Rx<FinderSearchFilters> finderFilters = const FinderSearchFilters().obs;

  final RxList<TenantListingModel> listings = <TenantListingModel>[].obs;
  final RxList<FinderPostModel> posts = <FinderPostModel>[].obs;

  final Rx<ViewStatus> status = ViewStatus.idle.obs;
  final RxnString error = RxnString();

  /// True once a search has actually run, so the idle state can differ from
  /// "ran and found nothing".
  final RxBool hasSearched = false.obs;

  CityModel? get city => _reference.cityById(
    mode.value == SearchMode.rooms
        ? listingFilters.value.cityId
        : finderFilters.value.cityId,
  );

  bool get hasCity => city != null;

  int get activeFilterCount => mode.value == SearchMode.rooms
      ? listingFilters.value.activeCount
      : finderFilters.value.activeCount;

  bool get hitResultCap => mode.value == SearchMode.rooms
      ? listings.length >= 50
      : posts.length >= 50;

  @override
  void onInit() {
    super.onInit();
    // Seed from whatever city the user is browsing, then follow it. The city
    // is picked once in the dashboard bar and every section reads that one
    // value — Search must not hold a stale copy of its own.
    final seeded = _reference.selectedCity.value;
    if (seeded != null) _applyCity(seeded);

    ever<CityModel?>(_reference.selectedCity, (next) {
      if (next == null || next.id == city?.id) return;
      _applyCity(next);
      run();
    });
  }

  @override
  void onReady() {
    super.onReady();
    if (hasCity) run();
  }

  void switchMode(SearchMode next) {
    if (mode.value == next) return;
    mode.value = next;
    hasSearched.value = false;
    status.value = ViewStatus.idle;
    error.value = null;
    if (hasCity) run();
  }

  void _applyCity(CityModel city) {
    listingFilters.value = listingFilters.value.copyWith(cityId: city.id);
    finderFilters.value = finderFilters.value.copyWith(cityId: city.id);
  }

  /// Selecting the city globally is the whole operation — the `ever` above
  /// applies it here and re-runs the search.
  Future<void> setCity(CityModel city) => _reference.selectCity(city);

  void applyListingFilters(ListingSearchFilters filters) {
    listingFilters.value = filters;
    run();
  }

  void applyFinderFilters(FinderSearchFilters filters) {
    finderFilters.value = filters;
    run();
  }

  void setSort(ListingSort sort) {
    listingFilters.value = listingFilters.value.copyWith(sort: sort);
    run();
  }

  void clearFilters() {
    if (mode.value == SearchMode.rooms) {
      listingFilters.value = listingFilters.value.cleared();
    } else {
      finderFilters.value = finderFilters.value.cleared();
    }
    run();
  }

  Future<void> run() async {
    if (!hasCity) {
      status.value = ViewStatus.idle;
      return;
    }

    status.value = ViewStatus.loading;
    error.value = null;
    hasSearched.value = true;

    try {
      if (mode.value == SearchMode.rooms) {
        listings.assignAll(await _search.listings(listingFilters.value));
      } else {
        posts.assignAll(await _search.finderPosts(finderFilters.value));
      }
      status.value = ViewStatus.success;
    } on ApiException catch (e) {
      error.value = e.message;
      status.value = ViewStatus.error;
    }
  }

  Future<void> reload() => run();

  void openListing(TenantListingModel listing) =>
      Get.toNamed(Routes.listingDetail, arguments: listing.id);

  void openPost(FinderPostModel post) =>
      Get.toNamed(Routes.finderPostDetail, arguments: post.id);
}
