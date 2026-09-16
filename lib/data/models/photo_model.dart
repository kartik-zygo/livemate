import '../../core/config/api_endpoints.dart';
import '../../core/config/env.dart';
import '../../core/utils/json_utils.dart';

/// Photo bytes live in Postgres; `GET /media/photos/:id` streams them publicly
/// with a one-year immutable cache header, so [url] can go straight into an
/// image widget with no auth header and no presign round trip.
class PhotoModel {
  const PhotoModel({
    required this.id,
    required this.sortOrder,
    this.contentType,
    this.sizeBytes,
  });

  final String id;
  final int sortOrder;
  final String? contentType;
  final int? sizeBytes;

  String get url => '${Env.apiBaseUrl}${ApiEndpoints.photo(id)}';

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
    id: asString(json['id']),
    sortOrder: asInt(json['sortOrder']),
    contentType: asStringOrNull(json['contentType']),
    sizeBytes: asIntOrNull(json['sizeBytes']),
  );

  static List<PhotoModel> listFrom(Object? raw) {
    final list = asMapList(raw).map(PhotoModel.fromJson).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }
}
