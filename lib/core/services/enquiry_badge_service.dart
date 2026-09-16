import 'package:get/get.dart';

import '../../data/repositories/enquiry_repository.dart';
import '../network/api_exception.dart';

/// Drives the bottom-nav badge from `GET /enquiries/received/pending-count`.
///
/// Lives above the nav shell rather than inside it so any screen that changes
/// the count — accepting an enquiry, declining one — can refresh it directly.
class EnquiryBadgeService extends GetxService {
  EnquiryBadgeService(this._repo);

  final EnquiryRepository _repo;

  final RxInt pendingCount = 0.obs;

  bool _fetching = false;

  Future<void> refresh() async {
    if (_fetching) return;
    _fetching = true;
    try {
      pendingCount.value = await _repo.pendingCount();
    } on ApiException {
      // The badge is decorative; a failure here must stay silent.
    } finally {
      _fetching = false;
    }
  }

  /// Applied immediately when the user answers an enquiry, so the badge does
  /// not lag behind the list they are looking at.
  void decrement([int by = 1]) {
    final next = pendingCount.value - by;
    pendingCount.value = next < 0 ? 0 : next;
  }

  void clear() => pendingCount.value = 0;
}
