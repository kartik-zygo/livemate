import '../../core/config/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/json_utils.dart';

class FinderPostApiProvider {
  const FinderPostApiProvider(this._client);

  final DioClient _client;

  /// Publishes straight to ACTIVE; the server answers 201 with the post.
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final data = await _client.post<dynamic>(
      ApiEndpoints.finderPosts,
      body: body,
    );
    return asMap(data);
  }

  Future<Map<String, dynamic>> byId(String id) async {
    final data = await _client.get<dynamic>(ApiEndpoints.finderPost(id));
    return asMap(data);
  }

  Future<List<Map<String, dynamic>>> mine() async {
    final data = await _client.get<dynamic>(ApiEndpoints.finderPostsMine);
    return asMapList(data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.patch<dynamic>(
      ApiEndpoints.finderPost(id),
      body: body,
    );
    return asMap(data);
  }

  Future<void> remove(String id) => _client.delete(ApiEndpoints.finderPost(id));
}
