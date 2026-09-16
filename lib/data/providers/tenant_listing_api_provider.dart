import 'package:dio/dio.dart';

import '../../core/config/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/json_utils.dart';

class TenantListingApiProvider {
  const TenantListingApiProvider(this._client);

  final DioClient _client;

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final data = await _client.post<dynamic>(
      ApiEndpoints.tenantListings,
      body: body,
    );
    return asMap(data);
  }

  Future<Map<String, dynamic>> byId(String id) async {
    final data = await _client.get<dynamic>(ApiEndpoints.tenantListing(id));
    return asMap(data);
  }

  Future<List<Map<String, dynamic>>> mine() async {
    final data = await _client.get<dynamic>(ApiEndpoints.tenantListingsMine);
    return asMapList(data);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.patch<dynamic>(
      ApiEndpoints.tenantListing(id),
      body: body,
    );
    return asMap(data);
  }

  Future<void> remove(String id) =>
      _client.delete(ApiEndpoints.tenantListing(id));

  /// Multipart upload of a single photo. The response is the updated listing,
  /// which flips DRAFT to ACTIVE once the third photo lands.
  Future<Map<String, dynamic>> uploadPhoto(
    String id,
    MultipartFile file,
  ) async {
    final form = FormData.fromMap({'file': file});
    final data = await _client.upload<dynamic>(
      ApiEndpoints.tenantListingPhotos(id),
      form,
    );
    return asMap(data);
  }
}
