import 'package:get/get.dart';

import '../../data/repositories/saved_repository.dart';
import '../network/api_exception.dart';

/// One source of truth for every heart icon in the app.
///
/// `GET /saved-listings/ids` is fetched once after sign-in; toggles apply
/// optimistically and roll back if the server disagrees, so a card never has to
/// wait on a round trip to flip.
class ShortlistService extends GetxService {
  ShortlistService(this._repo);

  final SavedRepository _repo;

  final RxSet<String> savedIds = <String>{}.obs;
  final RxSet<String> _inFlight = <String>{}.obs;

  /// Bumped on every successful toggle so the Saved tab knows to refetch.
  final RxInt revision = 0.obs;

  bool isSaved(String listingId) => savedIds.contains(listingId);

  bool isBusy(String listingId) => _inFlight.contains(listingId);

  Future<void> refresh() async {
    try {
      savedIds.assignAll(await _repo.ids());
    } on ApiException {
      // A failed shortlist sync should never block browsing.
    }
  }

  void clear() {
    savedIds.clear();
    _inFlight.clear();
  }

  /// Returns the new saved state, or the unchanged one if the call failed.
  Future<bool> toggle(String listingId) async {
    if (_inFlight.contains(listingId)) return isSaved(listingId);

    final wasSaved = isSaved(listingId);
    _inFlight.add(listingId);
    if (wasSaved) {
      savedIds.remove(listingId);
    } else {
      savedIds.add(listingId);
    }

    try {
      final result = wasSaved
          ? await _repo.unsave(listingId)
          : await _repo.save(listingId);
      if (result) {
        savedIds.add(listingId);
      } else {
        savedIds.remove(listingId);
      }
      revision.value++;
      return result;
    } on ApiException {
      // Roll back to the pre-toggle state.
      if (wasSaved) {
        savedIds.add(listingId);
      } else {
        savedIds.remove(listingId);
      }
      rethrow;
    } finally {
      _inFlight.remove(listingId);
    }
  }
}
