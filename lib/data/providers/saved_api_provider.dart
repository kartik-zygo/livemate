import '../../core/config/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/json_utils.dart';

class SavedApiProvider {
  const SavedApiProvider(this._client);

  final DioClient _client;

  Future<List<Map<String, dynamic>>> listings() async {
    final data = await _client.get<dynamic>(ApiEndpoints.savedListings);
    return asMapList(data);
  }

  /// One cheap call that drives every heart icon in the app.
  Future<List<String>> ids() async {
    final data = await _client.get<dynamic>(ApiEndpoints.savedListingIds);
    return asStringList(data);
  }

  Future<bool> save(String listingId) async {
    final data = await _client.post<dynamic>(
      ApiEndpoints.tenantListingSave(listingId),
    );
    return asBool(asMap(data)['saved'], true);
  }

  Future<bool> unsave(String listingId) async {
    final data = await _client.dio.delete<dynamic>(
      ApiEndpoints.tenantListingSave(listingId),
    );
    return asBool(asMap(data.data)['saved'], false);
  }
}
