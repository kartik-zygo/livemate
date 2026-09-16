import '../../core/config/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/json_utils.dart';

class UserApiProvider {
  const UserApiProvider(this._client);

  final DioClient _client;

  Future<Map<String, dynamic>> me() async {
    final data = await _client.get<dynamic>(ApiEndpoints.usersMe);
    return asMap(data);
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> body) async {
    final data = await _client.patch<dynamic>(ApiEndpoints.usersMe, body: body);
    return asMap(data);
  }

  Future<void> deleteMe() => _client.delete(ApiEndpoints.usersMe);
}
