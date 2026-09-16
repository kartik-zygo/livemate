import '../../core/config/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/json_utils.dart';

/// The backend verifies the Supabase JWT and upserts a local user row on the
/// first authenticated call, so hitting `/auth/me` right after sign-up is what
/// actually creates the profile.
class AuthApiProvider {
  const AuthApiProvider(this._client);

  final DioClient _client;

  Future<Map<String, dynamic>> me() async {
    final data = await _client.get<dynamic>(ApiEndpoints.authMe);
    return asMap(data);
  }
}
