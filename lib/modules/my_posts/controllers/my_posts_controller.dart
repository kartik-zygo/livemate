import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/finder_post_model.dart';
import '../../../data/models/tenant_listing_model.dart';
import '../../../data/repositories/finder_post_repository.dart';
import '../../../data/repositories/tenant_listing_repository.dart';

/// Backs both "My listings" and "My finder posts" — the same shape of screen
/// over two different resources.
class MyPostsController extends GetxController {
  MyPostsController(this._listings, this._finderPosts);

  final TenantListingRepository _listings;
  final FinderPostRepository _finderPosts;

  final RxList<TenantListingModel> listings = <TenantListingModel>[].obs;
  final RxList<FinderPostModel> posts = <FinderPostModel>[].obs;
  final Rx<ViewStatus> status = ViewStatus.idle.obs;
  final RxnString error = RxnString();

  /// Set by the binding so one controller can serve both routes.
  late final bool showsListings;

  int get liveCount => showsListings
      ? listings.where((l) => l.status == ListingStatus.active).length
      : posts.where((p) => p.status == FinderPostStatus.active).length;

  int get draftCount =>
      showsListings ? listings.where((l) => !l.isPublished).length : 0;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    status.value = ViewStatus.loading;
    error.value = null;
    try {
      if (showsListings) {
        listings.assignAll(await _listings.mine());
      } else {
        posts.assignAll(await _finderPosts.mine());
      }
      status.value = ViewStatus.success;
    } on ApiException catch (e) {
      error.value = e.message;
      status.value = ViewStatus.error;
    }
  }

  Future<void> reload() => load();

  void openListing(TenantListingModel listing) => Get.toNamed(
    Routes.listingDetail,
    arguments: listing.id,
  )?.then((_) => load());

  void openPost(FinderPostModel post) => Get.toNamed(
    Routes.finderPostDetail,
    arguments: post.id,
  )?.then((_) => load());

  void createListing() =>
      Get.toNamed(Routes.createListing)?.then((_) => load());

  void createFinderPost() =>
      Get.toNamed(Routes.createFinderPost)?.then((_) => load());

  void editListing(TenantListingModel listing) =>
      Get.toNamed(Routes.editListing, arguments: listing)?.then((_) => load());
}
