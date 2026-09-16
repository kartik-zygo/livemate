import '../../core/utils/json_utils.dart';
import 'city_model.dart';
import 'enums.dart';
import 'photo_model.dart';
import 'user_model.dart';

class TenantListingModel {
  const TenantListingModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.budget,
    required this.cityId,
    required this.openTo,
    required this.status,
    required this.amenities,
    required this.photos,
    this.propertyType,
    this.roomType,
    this.furnishing,
    this.bedrooms,
    this.bathrooms,
    this.depositAmount,
    this.availableFrom,
    this.maxOccupants,
    this.city,
    this.owner,
    this.enquiryCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final int budget;
  final String cityId;
  final Gender openTo;
  final ListingStatus status;
  final List<Amenity> amenities;
  final List<PhotoModel> photos;
  final PropertyType? propertyType;
  final RoomType? roomType;
  final Furnishing? furnishing;
  final int? bedrooms;
  final int? bathrooms;
  final int? depositAmount;
  final DateTime? availableFrom;
  final int? maxOccupants;
  final CityModel? city;
  final PersonSummary? owner;
  final int? enquiryCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// A null or past [availableFrom] means the room is ready now.
  bool get isAvailableNow {
    final from = availableFrom;
    return from == null || !from.isAfter(DateTime.now());
  }

  PhotoModel? get coverPhoto => photos.isEmpty ? null : photos.first;

  bool get isPublished => status == ListingStatus.active;

  factory TenantListingModel.fromJson(Map<String, dynamic> json) =>
      TenantListingModel(
        id: asString(json['id']),
        ownerId: asString(json['ownerId']),
        title: asString(json['title']),
        description: asString(json['description']),
        budget: asInt(json['budget']),
        cityId: asString(json['cityId']),
        openTo: Gender.fromWire(json['openTo']),
        status: ListingStatus.fromWire(json['status']),
        amenities: Amenity.listFromWire(json['amenities']),
        photos: PhotoModel.listFrom(json['photos']),
        propertyType: PropertyType.fromWire(json['propertyType']),
        roomType: RoomType.fromWire(json['roomType']),
        furnishing: Furnishing.fromWire(json['furnishing']),
        bedrooms: asIntOrNull(json['bedrooms']),
        bathrooms: asIntOrNull(json['bathrooms']),
        depositAmount: asIntOrNull(json['depositAmount']),
        availableFrom: asDate(json['availableFrom']),
        maxOccupants: asIntOrNull(json['maxOccupants']),
        city: json['city'] == null
            ? null
            : CityModel.fromJson(asMap(json['city'])),
        owner: json['owner'] == null
            ? null
            : PersonSummary.fromJson(asMap(json['owner'])),
        enquiryCount: asIntOrNull(asMapOrNull(json['_count'])?['enquiries']),
        createdAt: asDate(json['createdAt']),
        updatedAt: asDate(json['updatedAt']),
      );

  static List<TenantListingModel> listFrom(Object? raw) =>
      asMapList(raw).map(TenantListingModel.fromJson).toList();
}

/// Request body for POST/PATCH /tenant-listings.
///
/// PATCH treats every field as optional, so nulls are pruned rather than sent —
/// omitting a field leaves it untouched.
class TenantListingPayload {
  const TenantListingPayload({
    this.title,
    this.description,
    this.budget,
    this.cityId,
    this.openTo,
    this.amenities,
    this.propertyType,
    this.roomType,
    this.furnishing,
    this.bedrooms,
    this.bathrooms,
    this.depositAmount,
    this.availableFrom,
    this.maxOccupants,
  });

  final String? title;
  final String? description;
  final int? budget;
  final String? cityId;
  final Gender? openTo;
  final List<Amenity>? amenities;
  final PropertyType? propertyType;
  final RoomType? roomType;
  final Furnishing? furnishing;
  final int? bedrooms;
  final int? bathrooms;
  final int? depositAmount;
  final DateTime? availableFrom;
  final int? maxOccupants;

  Map<String, dynamic> toJson() => pruneNulls({
    'title': title,
    'description': description,
    'budget': budget,
    'cityId': cityId,
    'openTo': openTo?.wire,
    'amenities': amenities?.map((a) => a.wire).toList(),
    'propertyType': propertyType?.wire,
    'roomType': roomType?.wire,
    'furnishing': furnishing?.wire,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'depositAmount': depositAmount,
    'availableFrom': availableFrom?.toUtc().toIso8601String(),
    'maxOccupants': maxOccupants,
  });
}
