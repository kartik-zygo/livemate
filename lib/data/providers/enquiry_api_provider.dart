import '../../core/config/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/json_utils.dart';

class EnquiryApiProvider {
  const EnquiryApiProvider(this._client);

  final DioClient _client;

  /// Re-sending updates the existing enquiry and resets it to PENDING — there
  /// is only ever one enquiry per person per listing.
  Future<Map<String, dynamic>> send(String listingId, String? message) async {
    final data = await _client.post<dynamic>(
      ApiEndpoints.tenantListingEnquiries(listingId),
      body: pruneNulls({'message': message}),
    );
    return asMap(data);
  }

  Future<List<Map<String, dynamic>>> sent() async {
    final data = await _client.get<dynamic>(ApiEndpoints.enquiriesSent);
    return asMapList(data);
  }

  Future<List<Map<String, dynamic>>> received() async {
    final data = await _client.get<dynamic>(ApiEndpoints.enquiriesReceived);
    return asMapList(data);
  }

  Future<int> pendingCount() async {
    final data = await _client.get<dynamic>(ApiEndpoints.enquiriesPendingCount);
    return asInt(asMap(data)['count']);
  }

  /// Listing owner only, and only on a still-PENDING enquiry.
  Future<Map<String, dynamic>> respond(String id, String status) async {
    final data = await _client.patch<dynamic>(
      ApiEndpoints.enquiry(id),
      body: {'status': status},
    );
    return asMap(data);
  }
}
