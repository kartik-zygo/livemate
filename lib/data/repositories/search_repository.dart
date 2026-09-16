import '../models/finder_post_model.dart';
import '../models/search_filters.dart';
import '../models/tenant_listing_model.dart';
import '../providers/search_api_provider.dart';

class SearchRepository {
  const SearchRepository(this._api);

  final SearchApiProvider _api;

  Future<List<TenantListingModel>> listings(
    ListingSearchFilters filters,
  ) async => (await _api.tenantListings(
    filters.toQuery(),
  )).map(TenantListingModel.fromJson).toList();

  Future<List<FinderPostModel>> finderPosts(
    FinderSearchFilters filters,
  ) async => (await _api.finderPosts(
    filters.toQuery(),
  )).map(FinderPostModel.fromJson).toList();
}
