import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/shortlist_service.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/tenant_listing_model.dart';
import '../../../data/repositories/enquiry_repository.dart';
import '../../../data/repositories/tenant_listing_repository.dart';

class ListingDetailController extends GetxController {
  ListingDetailController(
    this._listings,
    this._enquiries,
    this._auth,
    this._shortlist,
  );

  final TenantListingRepository _listings;
  final EnquiryRepository _enquiries;
  final AuthService _auth;
  final ShortlistService _shortlist;

  final Rxn<TenantListingModel> listing = Rxn<TenantListingModel>();
  final Rx<ViewStatus> status = ViewStatus.idle.obs;
  final RxnString error = RxnString();
  final RxBool sendingEnquiry = false.obs;
  final RxInt photoIndex = 0.obs;

  /// Set once the user sends an enquiry in this session, so the CTA can flip to
  /// a "waiting on the owner" state without a refetch.
  final RxBool enquirySent = false.obs;

  late final String listingId;

  bool get isOwner =>
      listing.value != null && listing.value!.ownerId == _auth.userId;

  bool get isSaved => _shortlist.isSaved(listingId);

  bool get canEnquire =>
      !isOwner && (listing.value?.status == ListingStatus.active);

  @override
  void onInit() {
    super.onInit();
    listingId = Get.arguments is String ? Get.arguments as String : '';
    load();
  }

  Future<void> load() async {
    if (listingId.isEmpty) {
      error.value = 'That listing could not be opened.';
      status.value = ViewStatus.error;
      return;
    }

    status.value = ViewStatus.loading;
    error.value = null;
    try {
      listing.value = await _listings.byId(listingId);
      status.value = ViewStatus.success;
    } on ApiException catch (e) {
      error.value = e.message;
      status.value = ViewStatus.error;
    }
  }

  Future<void> reload() => load();

  Future<void> toggleSave() async {
    try {
      await _shortlist.toggle(listingId);
    } on ApiException catch (e) {
      AppFeedback.error(e.message);
    }
  }

  /// Sends or re-sends the enquiry. Re-sending updates the existing one and
  /// resets it to PENDING — there is only ever one per person per listing.
  Future<bool> sendEnquiry(String? message) async {
    sendingEnquiry.value = true;
    try {
      await _enquiries.send(listingId, message: message);
      enquirySent.value = true;
      return true;
    } on ApiException catch (e) {
      AppFeedback.error(e.message);
      return false;
    } finally {
      sendingEnquiry.value = false;
    }
  }

  void editListing() {
    final current = listing.value;
    if (current == null) return;
    Get.toNamed(Routes.editListing, arguments: current)?.then((_) => load());
  }

  Future<void> deleteListing() async {
    final confirmed = await AppFeedback.confirm(
      title: 'Delete this listing?',
      message:
          'It will disappear from search straight away. Enquiries you have '
          'already received stay in your inbox.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_forever_rounded,
    );
    if (!confirmed) return;

    try {
      await _listings.remove(listingId);
      AppFeedback.success('Listing deleted.');
      Get.back<bool>(result: true);
    } on ApiException catch (e) {
      AppFeedback.error(e.message);
    }
  }

  void setPhotoIndex(int index) => photoIndex.value = index;
}
