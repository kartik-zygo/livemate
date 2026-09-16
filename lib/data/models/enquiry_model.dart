import '../../core/utils/json_utils.dart';
import 'enums.dart';
import 'photo_model.dart';
import 'user_model.dart';

/// The trimmed listing shape that rides along on an enquiry — enough to render
/// a row, not the full detail object.
class EnquiryListingRef {
  const EnquiryListingRef({
    required this.id,
    required this.title,
    required this.budget,
    required this.ownerId,
    required this.photos,
  });

  final String id;
  final String title;
  final int budget;
  final String ownerId;
  final List<PhotoModel> photos;

  PhotoModel? get coverPhoto => photos.isEmpty ? null : photos.first;

  factory EnquiryListingRef.fromJson(Map<String, dynamic> json) =>
      EnquiryListingRef(
        id: asString(json['id']),
        title: asString(json['title'], 'Listing'),
        budget: asInt(json['budget']),
        ownerId: asString(json['ownerId']),
        photos: PhotoModel.listFrom(json['photos']),
      );
}

/// One enquiry, from either side of the conversation.
///
/// [ownerContact] is populated on a *sent* enquiry once the owner accepts;
/// [senderContact] on a *received* one once you accept. Both stay null
/// otherwise — that null is the privacy gate, so never render a contact detail
/// without checking [contact] first.
class EnquiryModel {
  const EnquiryModel({
    required this.id,
    required this.status,
    required this.listing,
    this.message,
    this.sender,
    this.ownerContact,
    this.senderContact,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final EnquiryStatus status;
  final EnquiryListingRef listing;
  final String? message;
  final PersonSummary? sender;
  final ContactModel? ownerContact;
  final ContactModel? senderContact;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Whichever side's contact this payload carries, or null while gated.
  ContactModel? get contact => ownerContact ?? senderContact;

  bool get isPending => status == EnquiryStatus.pending;
  bool get isAccepted => status == EnquiryStatus.accepted;
  bool get isDeclined => status == EnquiryStatus.declined;

  factory EnquiryModel.fromJson(Map<String, dynamic> json) => EnquiryModel(
    id: asString(json['id']),
    status: EnquiryStatus.fromWire(json['status']),
    listing: EnquiryListingRef.fromJson(asMap(json['listing'])),
    message: asStringOrNull(json['message']),
    sender: json['sender'] == null
        ? null
        : PersonSummary.fromJson(asMap(json['sender'])),
    ownerContact: json['ownerContact'] == null
        ? null
        : ContactModel.fromJson(asMap(json['ownerContact'])),
    senderContact: json['senderContact'] == null
        ? null
        : ContactModel.fromJson(asMap(json['senderContact'])),
    createdAt: asDate(json['createdAt']),
    updatedAt: asDate(json['updatedAt']),
  );

  static List<EnquiryModel> listFrom(Object? raw) =>
      asMapList(raw).map(EnquiryModel.fromJson).toList();
}
