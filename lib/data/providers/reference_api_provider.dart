import '../../core/config/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/json_utils.dart';

/// Cities and tags: fetched once, cached, filtered in memory.
class ReferenceApiProvider {
  const ReferenceApiProvider(this._client);

  final DioClient _client;

  Future<List<Map<String, dynamic>>> cities() async {
    final data = await _client.get<dynamic>(ApiEndpoints.cities);
    return asMapList(data);
  }

  Future<List<Map<String, dynamic>>> tags() async {
    final data = await _client.get<dynamic>(ApiEndpoints.tags);
    return asMapList(data);
  }

  Future<Map<String, dynamic>> publicConfig() async {
    final data = await _client.get<dynamic>(
      ApiEndpoints.publicConfig,
      skipAuth: true,
    );
    return asMap(data);
  }

  /// Privacy policy and account-deletion links. Public, like public-config.
  Future<Map<String, dynamic>> legal() async {
    final data = await _client.get<dynamic>(ApiEndpoints.legal, skipAuth: true);
    return asMap(data);
  }
}
