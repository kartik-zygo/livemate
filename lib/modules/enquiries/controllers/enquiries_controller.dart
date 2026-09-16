import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/enquiry_badge_service.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/enquiry_model.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/enquiry_repository.dart';

/// Both sides of the core loop: enquiries you received on your listings, and
/// enquiries you sent on other people's.
class EnquiriesController extends GetxController {
  EnquiriesController(this._repo, this._badge);

  final EnquiryRepository _repo;
  final EnquiryBadgeService _badge;

  final RxList<EnquiryModel> received = <EnquiryModel>[].obs;
  final RxList<EnquiryModel> sent = <EnquiryModel>[].obs;

  final Rx<ViewStatus> receivedStatus = ViewStatus.idle.obs;
  final Rx<ViewStatus> sentStatus = ViewStatus.idle.obs;
  final RxnString receivedError = RxnString();
  final RxnString sentError = RxnString();

  /// Ids currently being accepted or declined, so their row can show a spinner
  /// without locking the whole list.
  final RxSet<String> responding = <String>{}.obs;

  final RxInt tabIndex = 0.obs;

  int get pendingReceived =>
      received.where((e) => e.status == EnquiryStatus.pending).length;

  @override
  void onReady() {
    super.onReady();
    loadAll();
  }

  Future<void> loadAll() =>
      Future.wait([loadReceived(), loadSent()]).then((_) {});

  Future<void> loadReceived() async {
    receivedStatus.value = ViewStatus.loading;
    receivedError.value = null;
    try {
      received.assignAll(await _repo.received());
      receivedStatus.value = ViewStatus.success;
      _badge.refresh();
    } on ApiException catch (e) {
      receivedError.value = e.message;
      receivedStatus.value = ViewStatus.error;
    }
  }

  Future<void> loadSent() async {
    sentStatus.value = ViewStatus.loading;
    sentError.value = null;
    try {
      sent.assignAll(await _repo.sent());
      sentStatus.value = ViewStatus.success;
    } on ApiException catch (e) {
      sentError.value = e.message;
      sentStatus.value = ViewStatus.error;
    }
  }

  /// Accepting reveals both sides' contact details; declining closes the
  /// exchange. Either way the answer is final, so accept is confirmed first.
  Future<void> respond(EnquiryModel enquiry, EnquiryStatus decision) async {
    if (responding.contains(enquiry.id)) return;

    final accepting = decision == EnquiryStatus.accepted;
    final confirmed = await AppFeedback.confirm(
      title: accepting ? 'Accept this enquiry?' : 'Decline this enquiry?',
      message: accepting
          ? 'Your email and phone will be shared with '
                '${enquiry.sender?.fullName ?? 'this person'}, and theirs with '
                'you. This cannot be undone.'
          : 'They will see that you declined. This cannot be undone.',
      confirmLabel: accepting ? 'Accept and share' : 'Decline',
      destructive: !accepting,
      icon: accepting
          ? Icons.handshake_rounded
          : Icons.do_not_disturb_on_rounded,
    );
    if (!confirmed) return;

    responding.add(enquiry.id);
    try {
      final updated = await _repo.respond(enquiry.id, decision);
      final index = received.indexWhere((e) => e.id == enquiry.id);
      if (index != -1) received[index] = updated;

      if (enquiry.status == EnquiryStatus.pending) _badge.decrement();

      AppFeedback.success(
        accepting
            ? 'Accepted. Contact details are now visible to you both.'
            : 'Enquiry declined.',
      );
    } on ApiException catch (e) {
      AppFeedback.error(e.message);
      // A 400 usually means it was already answered elsewhere; resync.
      if (e.isValidation) await loadReceived();
    } finally {
      responding.remove(enquiry.id);
    }
  }

  bool isResponding(String id) => responding.contains(id);

  void openListing(String listingId) =>
      Get.toNamed(Routes.listingDetail, arguments: listingId);

  void setTab(int index) => tabIndex.value = index;
}
