import '../models/enquiry_model.dart';
import '../models/enums.dart';
import '../providers/enquiry_api_provider.dart';

class EnquiryRepository {
  const EnquiryRepository(this._api);

  final EnquiryApiProvider _api;

  Future<void> send(String listingId, {String? message}) async {
    final trimmed = message?.trim();
    await _api.send(
      listingId,
      trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
  }

  Future<List<EnquiryModel>> sent() async =>
      _sortNewestFirst((await _api.sent()).map(EnquiryModel.fromJson).toList());

  Future<List<EnquiryModel>> received() async => _sortNewestFirst(
    (await _api.received()).map(EnquiryModel.fromJson).toList(),
  );

  Future<int> pendingCount() => _api.pendingCount();

  Future<EnquiryModel> respond(String id, EnquiryStatus status) async {
    assert(
      status == EnquiryStatus.accepted || status == EnquiryStatus.declined,
      'Only ACCEPTED or DECLINED can be sent back to the API.',
    );
    return EnquiryModel.fromJson(await _api.respond(id, status.wire));
  }

  static List<EnquiryModel> _sortNewestFirst(List<EnquiryModel> items) {
    items.sort((a, b) {
      final at = a.updatedAt ?? a.createdAt;
      final bt = b.updatedAt ?? b.createdAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    return items;
  }
}
