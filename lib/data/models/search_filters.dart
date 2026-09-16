import 'enums.dart';

/// Query for `GET /search/tenant-listings`.
///
/// `cityId` is the entire match rule — there is no radius, no coordinates and
/// no locality anywhere in this product, so there is nothing else to widen.
class ListingSearchFilters {
  const ListingSearchFilters({
    this.cityId,
    this.budgetMin,
    this.budgetMax,
    this.gender,
    this.propertyTypes = const {},
    this.roomTypes = const {},
    this.furnishings = const {},
    this.minBedrooms,
    this.availableBy,
    this.sort = ListingSort.newest,
  });

  final String? cityId;
  final int? budgetMin;
  final int? budgetMax;
  final Gender? gender;
  final Set<PropertyType> propertyTypes;
  final Set<RoomType> roomTypes;
  final Set<Furnishing> furnishings;
  final int? minBedrooms;
  final DateTime? availableBy;
  final ListingSort sort;

  bool get hasCity => (cityId ?? '').isNotEmpty;

  /// Everything except the city and the sort order — what the "Clear all"
  /// affordance resets and what the filter-count badge counts.
  int get activeCount {
    var n = 0;
    if (budgetMin != null) n++;
    if (budgetMax != null) n++;
    if (gender != null && gender != Gender.any) n++;
    if (propertyTypes.isNotEmpty) n++;
    if (roomTypes.isNotEmpty) n++;
    if (furnishings.isNotEmpty) n++;
    if (minBedrooms != null) n++;
    if (availableBy != null) n++;
    return n;
  }

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{'cityId': cityId, 'sort': sort.wire};
    if (budgetMin != null) q['budgetMin'] = budgetMin;
    if (budgetMax != null) q['budgetMax'] = budgetMax;
    if (gender != null) q['gender'] = gender!.wire;
    if (propertyTypes.isNotEmpty) {
      q['propertyTypes'] = propertyTypes.map((e) => e.wire).join(',');
    }
    if (roomTypes.isNotEmpty) {
      q['roomTypes'] = roomTypes.map((e) => e.wire).join(',');
    }
    if (furnishings.isNotEmpty) {
      q['furnishings'] = furnishings.map((e) => e.wire).join(',');
    }
    if (minBedrooms != null) q['minBedrooms'] = minBedrooms;
    if (availableBy != null) {
      q['availableBy'] = availableBy!.toUtc().toIso8601String();
    }
    return q;
  }

  ListingSearchFilters copyWith({
    String? cityId,
    int? budgetMin,
    int? budgetMax,
    Gender? gender,
    Set<PropertyType>? propertyTypes,
    Set<RoomType>? roomTypes,
    Set<Furnishing>? furnishings,
    int? minBedrooms,
    DateTime? availableBy,
    ListingSort? sort,
    bool clearBudgetMin = false,
    bool clearBudgetMax = false,
    bool clearGender = false,
    bool clearMinBedrooms = false,
    bool clearAvailableBy = false,
  }) => ListingSearchFilters(
    cityId: cityId ?? this.cityId,
    budgetMin: clearBudgetMin ? null : (budgetMin ?? this.budgetMin),
    budgetMax: clearBudgetMax ? null : (budgetMax ?? this.budgetMax),
    gender: clearGender ? null : (gender ?? this.gender),
    propertyTypes: propertyTypes ?? this.propertyTypes,
    roomTypes: roomTypes ?? this.roomTypes,
    furnishings: furnishings ?? this.furnishings,
    minBedrooms: clearMinBedrooms ? null : (minBedrooms ?? this.minBedrooms),
    availableBy: clearAvailableBy ? null : (availableBy ?? this.availableBy),
    sort: sort ?? this.sort,
  );

  /// Keeps the city and sort, drops every narrowing filter.
  ListingSearchFilters cleared() =>
      ListingSearchFilters(cityId: cityId, sort: sort);
}

/// Query for `GET /search/finder-posts`. A post matches when its budget range
/// *overlaps* the requested one.
class FinderSearchFilters {
  const FinderSearchFilters({
    this.cityId,
    this.budgetMin,
    this.budgetMax,
    this.tagIds = const {},
  });

  final String? cityId;
  final int? budgetMin;
  final int? budgetMax;
  final Set<String> tagIds;

  bool get hasCity => (cityId ?? '').isNotEmpty;

  int get activeCount {
    var n = 0;
    if (budgetMin != null) n++;
    if (budgetMax != null) n++;
    if (tagIds.isNotEmpty) n++;
    return n;
  }

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{'cityId': cityId};
    if (budgetMin != null) q['budgetMin'] = budgetMin;
    if (budgetMax != null) q['budgetMax'] = budgetMax;
    if (tagIds.isNotEmpty) q['tagIds'] = tagIds.join(',');
    return q;
  }

  FinderSearchFilters copyWith({
    String? cityId,
    int? budgetMin,
    int? budgetMax,
    Set<String>? tagIds,
    bool clearBudgetMin = false,
    bool clearBudgetMax = false,
  }) => FinderSearchFilters(
    cityId: cityId ?? this.cityId,
    budgetMin: clearBudgetMin ? null : (budgetMin ?? this.budgetMin),
    budgetMax: clearBudgetMax ? null : (budgetMax ?? this.budgetMax),
    tagIds: tagIds ?? this.tagIds,
  );

  FinderSearchFilters cleared() => FinderSearchFilters(cityId: cityId);
}
