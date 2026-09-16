// Domain enums. Wire values are sent and received verbatim — never localise or
// case-fold them on the way out.

/// Decodes a wire string into [values], falling back to [fallback] so an
/// unrecognised server value degrades instead of throwing.
T _decode<T>(
  List<T> values,
  String Function(T) wireOf,
  Object? raw,
  T fallback,
) {
  if (raw is! String) return fallback;
  for (final v in values) {
    if (wireOf(v) == raw) return v;
  }
  return fallback;
}

enum PlatformRole {
  user('user', 'Member'),
  manager('manager', 'Manager'),
  admin('admin', 'Admin');

  const PlatformRole(this.wire, this.label);
  final String wire;
  final String label;

  static PlatformRole fromWire(Object? raw) =>
      _decode<PlatformRole>(values, (e) => e.wire, raw, PlatformRole.user);
}

/// A *preference* — who a listing or finder post is open to.
enum Gender {
  male('MALE', 'Men'),
  female('FEMALE', 'Women'),
  any('ANY', 'Anyone');

  const Gender(this.wire, this.label);
  final String wire;
  final String label;

  static Gender fromWire(Object? raw) =>
      _decode<Gender>(values, (e) => e.wire, raw, Gender.any);
  static Gender? fromWireOrNull(Object? raw) =>
      raw == null ? null : fromWire(raw);
}

/// A person's own gender.
enum ProfileGender {
  male('MALE', 'Male'),
  female('FEMALE', 'Female'),
  other('OTHER', 'Other');

  const ProfileGender(this.wire, this.label);
  final String wire;
  final String label;

  static ProfileGender? fromWire(Object? raw) => raw == null
      ? null
      : _decode<ProfileGender>(values, (e) => e.wire, raw, ProfileGender.other);
}

enum TagCategory {
  cleanliness('CLEANLINESS', 'Cleanliness'),
  petFriendly('PET_FRIENDLY', 'Pets'),
  foodPreference('FOOD_PREFERENCE', 'Food');

  const TagCategory(this.wire, this.label);
  final String wire;
  final String label;

  static TagCategory fromWire(Object? raw) =>
      _decode<TagCategory>(values, (e) => e.wire, raw, TagCategory.cleanliness);
}

enum FinderPostStatus {
  draft('DRAFT', 'Draft'),
  active('ACTIVE', 'Active'),
  paused('PAUSED', 'Paused'),
  closed('CLOSED', 'Closed'),
  expired('EXPIRED', 'Expired');

  const FinderPostStatus(this.wire, this.label);
  final String wire;
  final String label;

  /// An unrecognised status reads as closed, so the post is hidden rather than
  /// shown as live or editable.
  static FinderPostStatus fromWire(Object? raw) => _decode<FinderPostStatus>(
    values,
    (e) => e.wire,
    raw,
    FinderPostStatus.closed,
  );
}

enum ListingStatus {
  draft('DRAFT', 'Draft'),
  active('ACTIVE', 'Active'),
  rented('RENTED', 'Rented'),
  inactive('INACTIVE', 'Inactive');

  const ListingStatus(this.wire, this.label);
  final String wire;
  final String label;

  static ListingStatus fromWire(Object? raw) =>
      _decode<ListingStatus>(values, (e) => e.wire, raw, ListingStatus.draft);
}

/// How much help a finder post gets. Optional on create; the server defaults
/// to self-serve.
enum PostTier {
  selfServe('SELF_SERVE', 'Self-serve'),
  managed('MANAGED', 'Managed');

  const PostTier(this.wire, this.label);
  final String wire;
  final String label;

  static PostTier fromWire(Object? raw) =>
      _decode<PostTier>(values, (e) => e.wire, raw, PostTier.selfServe);
}

enum PropertyType {
  apartment('APARTMENT', 'Apartment'),
  independentHouse('INDEPENDENT_HOUSE', 'Independent house'),
  pg('PG', 'PG'),
  studio('STUDIO', 'Studio'),
  villa('VILLA', 'Villa');

  const PropertyType(this.wire, this.label);
  final String wire;
  final String label;

  static PropertyType? fromWire(Object? raw) => raw == null
      ? null
      : _decode<PropertyType>(values, (e) => e.wire, raw, apartment);
}

enum RoomType {
  private('PRIVATE', 'Private room'),
  shared('SHARED', 'Shared room'),
  entirePlace('ENTIRE_PLACE', 'Entire place');

  const RoomType(this.wire, this.label);
  final String wire;
  final String label;

  static RoomType? fromWire(Object? raw) => raw == null
      ? null
      : _decode<RoomType>(values, (e) => e.wire, raw, private);
}

enum Furnishing {
  fullyFurnished('FULLY_FURNISHED', 'Fully furnished'),
  semiFurnished('SEMI_FURNISHED', 'Semi furnished'),
  unfurnished('UNFURNISHED', 'Unfurnished');

  const Furnishing(this.wire, this.label);
  final String wire;
  final String label;

  static Furnishing? fromWire(Object? raw) => raw == null
      ? null
      : _decode<Furnishing>(values, (e) => e.wire, raw, semiFurnished);
}

enum EnquiryStatus {
  pending('PENDING', 'Pending'),
  accepted('ACCEPTED', 'Accepted'),
  declined('DECLINED', 'Declined');

  const EnquiryStatus(this.wire, this.label);
  final String wire;
  final String label;

  static EnquiryStatus fromWire(Object? raw) =>
      _decode<EnquiryStatus>(values, (e) => e.wire, raw, EnquiryStatus.pending);
}

enum Amenity {
  wifi('WIFI', 'Wi-Fi'),
  ac('AC', 'Air conditioning'),
  furnished('FURNISHED', 'Furnished'),
  washingMachine('WASHING_MACHINE', 'Washing machine'),
  fridge('FRIDGE', 'Fridge'),
  geyser('GEYSER', 'Geyser'),
  parking('PARKING', 'Parking'),
  lift('LIFT', 'Lift'),
  powerBackup('POWER_BACKUP', 'Power backup'),
  balcony('BALCONY', 'Balcony');

  const Amenity(this.wire, this.label);
  final String wire;
  final String label;

  static Amenity? fromWire(Object? raw) =>
      raw == null ? null : _decode<Amenity>(values, (e) => e.wire, raw, wifi);

  static List<Amenity> listFromWire(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .map(Amenity.fromWire)
        .whereType<Amenity>()
        .toSet()
        .toList(growable: false);
  }
}

/// `DISTANCE` is still accepted by the API but there are no coordinates behind
/// it, so it silently falls back to newest-first. The app does not offer it.
enum ListingSort {
  newest('NEWEST', 'Newest first'),
  priceAsc('PRICE_ASC', 'Price: low to high'),
  priceDesc('PRICE_DESC', 'Price: high to low');

  const ListingSort(this.wire, this.label);
  final String wire;
  final String label;

  static ListingSort fromWire(Object? raw) =>
      _decode<ListingSort>(values, (e) => e.wire, raw, ListingSort.newest);
}

/// The four states every fetching screen renders.
enum ViewStatus { idle, loading, success, error }

extension ViewStatusX on ViewStatus {
  bool get isLoading => this == ViewStatus.loading;
  bool get isSuccess => this == ViewStatus.success;
  bool get isError => this == ViewStatus.error;
  bool get isIdle => this == ViewStatus.idle;
}
