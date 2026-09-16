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

/// The default feed for the user's city: newest active listings, plus a strip
/// of people currently looking there.
///
/// Discovery is city-to-city — there is no radius to widen and no coordinates
/// to sort by, so an empty result means "narrow differently or try another
/// city", never "move the map".
class DiscoverController extends GetxController {
  DiscoverController(this._search, this._reference);

  final SearchRepository _search;
  final ReferenceService _reference;

  final RxList<TenantListingModel> listings = <TenantListingModel>[].obs;
  final RxList<FinderPostModel> finderPosts = <FinderPostModel>[].obs;
  final Rx<ViewStatus> status = ViewStatus.idle.obs;
  final RxnString error = RxnString();

  Rxn<CityModel> get city => _reference.selectedCity;

  bool get hasCity => city.value != null;

  /// True once the API returns the hard cap, so the UI can say so instead of
  /// implying there is a page two.
  bool get hitResultCap => listings.length >= 50;

  @override
  void onInit() {
    super.onInit();
    // Reload whenever the city changes, wherever it was changed from.
    ever<CityModel?>(_reference.selectedCity, (_) => load());
  }

  @override
  void onReady() {
    super.onReady();
    if (hasCity) {
      load();
    } else {
      status.value = ViewStatus.idle;
    }
  }

  Future<void> load() async {
    final selected = city.value;
    if (selected == null) {
      listings.clear();
      finderPosts.clear();
      status.value = ViewStatus.idle;
      return;
    }

    status.value = ViewStatus.loading;
    error.value = null;

    try {
      final filters = ListingSearchFilters(
        cityId: selected.id,
        sort: ListingSort.newest,
      );
      final results = await _search.listings(filters);
      listings.assignAll(results);
      status.value = ViewStatus.success;
    } on ApiException catch (e) {
      error.value = e.message;
      status.value = ViewStatus.error;
    }

    // The finder strip is supplementary; its failure must not take the feed
    // down with it.
    try {
      final posts = await _search.finderPosts(
        FinderSearchFilters(cityId: selected.id),
      );
      finderPosts.assignAll(posts.take(10));
    } on ApiException {
      finderPosts.clear();
    }
  }

  /// Named `reload` rather than `refresh` — GetxController already defines a
  /// synchronous `refresh()` for its own change notification.
  Future<void> reload() => load();

  Future<void> setCity(CityModel city) => _reference.selectCity(city);

  void openListing(TenantListingModel listing) =>
      Get.toNamed(Routes.listingDetail, arguments: listing.id);

  void openFinderPost(FinderPostModel post) =>
      Get.toNamed(Routes.finderPostDetail, arguments: post.id);
}
