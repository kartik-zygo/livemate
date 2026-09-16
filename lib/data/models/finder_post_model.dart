import '../../core/utils/json_utils.dart';
import 'city_model.dart';
import 'enums.dart';
import 'tag_model.dart';

class FinderPostModel {
  const FinderPostModel({
    required this.id,
    required this.ownerId,
    required this.budgetMin,
    required this.budgetMax,
    required this.cityId,
    required this.genderPreference,
    required this.tier,
    required this.status,
    required this.tags,
    this.note,
    this.ageMin,
    this.ageMax,
    this.city,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final int budgetMin;
  final int budgetMax;
  final String cityId;
  final Gender genderPreference;
  final PostTier tier;
  final FinderPostStatus status;
  final List<TagModel> tags;
  final String? note;
  final int? ageMin;
  final int? ageMax;
  final CityModel? city;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasAgeRange => ageMin != null || ageMax != null;

  factory FinderPostModel.fromJson(Map<String, dynamic> json) =>
      FinderPostModel(
        id: asString(json['id']),
        ownerId: asString(json['ownerId']),
        budgetMin: asInt(json['budgetMin']),
        budgetMax: asInt(json['budgetMax']),
        cityId: asString(json['cityId']),
        genderPreference: Gender.fromWire(json['genderPreference']),
        tier: PostTier.fromWire(json['tier']),
        status: FinderPostStatus.fromWire(json['status']),
        // Tags arrive through a join table shaped as [{ "tag": { ... } }].
        tags: asMapList(
          json['tags'],
        ).map((e) => TagModel.fromJson(asMap(e['tag'] ?? e))).toList(),
        note: asStringOrNull(json['note']),
        ageMin: asIntOrNull(json['ageMin']),
        ageMax: asIntOrNull(json['ageMax']),
        city: json['city'] == null
            ? null
            : CityModel.fromJson(asMap(json['city'])),
        createdAt: asDate(json['createdAt']),
        updatedAt: asDate(json['updatedAt']),
      );

  static List<FinderPostModel> listFrom(Object? raw) =>
      asMapList(raw).map(FinderPostModel.fromJson).toList();
}

class FinderPostPayload {
  const FinderPostPayload({
    this.budgetMin,
    this.budgetMax,
    this.genderPreference,
    this.cityId,
    this.note,
    this.ageMin,
    this.ageMax,
    this.tier,
    this.tagIds,
  });

  final int? budgetMin;
  final int? budgetMax;
  final Gender? genderPreference;
  final String? cityId;
  final String? note;
  final int? ageMin;
  final int? ageMax;
  final PostTier? tier;
  final List<String>? tagIds;

  Map<String, dynamic> toJson() => pruneNulls({
    'budgetMin': budgetMin,
    'budgetMax': budgetMax,
    'genderPreference': genderPreference?.wire,
    'cityId': cityId,
    'note': note,
    'ageMin': ageMin,
    'ageMax': ageMax,
    'tier': tier?.wire,
    'tagIds': tagIds,
  });
}
