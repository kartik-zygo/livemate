import '../models/tenant_listing_model.dart';
import '../providers/saved_api_provider.dart';

class SavedRepository {
  const SavedRepository(this._api);

  final SavedApiProvider _api;

  Future<List<TenantListingModel>> listings() async =>
      (await _api.listings()).map(TenantListingModel.fromJson).toList();

  Future<Set<String>> ids() async => (await _api.ids()).toSet();

  Future<bool> save(String listingId) => _api.save(listingId);

  Future<bool> unsave(String listingId) => _api.unsave(listingId);
}
