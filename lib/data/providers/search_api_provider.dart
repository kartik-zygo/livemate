import '../../core/config/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/json_utils.dart';

/// Search is city-to-city. `cityId` is required on both endpoints, results are
/// capped at 50 and there is no pagination — narrow the filters instead.
class SearchApiProvider {
  const SearchApiProvider(this._client);

  final DioClient _client;

  Future<List<Map<String, dynamic>>> tenantListings(
    Map<String, dynamic> query,
  ) async {
    final data = await _client.get<dynamic>(
      ApiEndpoints.searchTenantListings,
      query: query,
    );
    return asMapList(data);
  }

  Future<List<Map<String, dynamic>>> finderPosts(
    Map<String, dynamic> query,
  ) async {
    final data = await _client.get<dynamic>(
      ApiEndpoints.searchFinderPosts,
      query: query,
    );
    return asMapList(data);
  }
}
