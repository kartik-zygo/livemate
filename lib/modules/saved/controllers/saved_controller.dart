import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/shortlist_service.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/tenant_listing_model.dart';
import '../../../data/repositories/saved_repository.dart';

class SavedController extends GetxController {
  SavedController(this._repo, this._shortlist);

  final SavedRepository _repo;
  final ShortlistService _shortlist;

  final RxList<TenantListingModel> listings = <TenantListingModel>[].obs;
  final Rx<ViewStatus> status = ViewStatus.idle.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    // The shortlist can change from any card in the app; refetch when it does
    // rather than letting this tab drift out of sync.
    ever<int>(_shortlist.revision, (_) => load());
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    status.value = ViewStatus.loading;
    error.value = null;
    try {
      listings.assignAll(await _repo.listings());
      status.value = ViewStatus.success;
    } on ApiException catch (e) {
      error.value = e.message;
      status.value = ViewStatus.error;
    }
  }

  Future<void> reload() => load();

  void openListing(TenantListingModel listing) =>
      Get.toNamed(Routes.listingDetail, arguments: listing.id);
}
