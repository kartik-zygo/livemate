import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../core/config/env.dart';
import '../../core/network/api_exception.dart';
import '../models/tenant_listing_model.dart';
import '../providers/tenant_listing_api_provider.dart';

class TenantListingRepository {
  const TenantListingRepository(this._api);

  final TenantListingApiProvider _api;

  Future<TenantListingModel> create(TenantListingPayload payload) async =>
      TenantListingModel.fromJson(await _api.create(payload.toJson()));

  Future<TenantListingModel> byId(String id) async =>
      TenantListingModel.fromJson(await _api.byId(id));

  Future<List<TenantListingModel>> mine() async =>
      (await _api.mine()).map(TenantListingModel.fromJson).toList();

  Future<TenantListingModel> update(
    String id,
    TenantListingPayload payload,
  ) async =>
      TenantListingModel.fromJson(await _api.update(id, payload.toJson()));

  Future<void> remove(String id) => _api.remove(id);

  /// Uploads one photo. Size and type are checked here so the user is told
  /// before a doomed 2 MB round trip.
  Future<TenantListingModel> uploadPhoto(String id, File file) async {
    final bytes = await file.length();
    if (bytes > Env.maxPhotoBytes) {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      final cap = Env.maxPhotoBytes ~/ (1024 * 1024);
      throw ApiException(
        message: 'That image is $mb MB. Photos must be under $cap MB.',
        kind: ApiErrorKind.server,
      );
    }

    final contentType = _contentTypeFor(file.path);
    if (contentType == null) {
      throw const ApiException(
        message: 'Photos must be JPEG, PNG or WebP.',
        kind: ApiErrorKind.server,
      );
    }

    final multipart = await MultipartFile.fromFile(
      file.path,
      filename: file.uri.pathSegments.last,
      contentType: contentType,
    );
    return TenantListingModel.fromJson(await _api.uploadPhoto(id, multipart));
  }

  static MediaType? _contentTypeFor(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      _ => null,
    };
  }
}
