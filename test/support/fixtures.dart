import 'dart:io';

import 'package:livemate/data/models/city_model.dart';
import 'package:livemate/data/models/enquiry_model.dart';
import 'package:livemate/data/models/finder_post_model.dart';
import 'package:livemate/data/models/search_filters.dart';
import 'package:livemate/data/models/tenant_listing_model.dart';
import 'package:livemate/data/models/user_model.dart';
import 'package:livemate/data/repositories/enquiry_repository.dart';
import 'package:livemate/data/repositories/finder_post_repository.dart';
import 'package:livemate/data/repositories/saved_repository.dart';
import 'package:livemate/data/repositories/search_repository.dart';
import 'package:livemate/data/repositories/tenant_listing_repository.dart';

/// Fixtures shaped like the API's own payloads, decoded through the real
/// `fromJson` so the models under test are built exactly as they are in
/// production.
///
/// Screens behave very differently once there is data on them — half the
/// reactive widgets in the app only exist inside a populated list — so the
/// smoke tests run twice: once against nothing, and once against these.
CityModel fixtureCity() => CityModel.fromJson(const {
  'id': 'city-1',
  'name': 'Pune',
  'state': 'Maharashtra',
});

UserModel fixtureUser({String id = 'user-1'}) => UserModel.fromJson({
  'id': id,
  'email': 'someone@example.com',
  'fullName': 'Test Person',
  'phone': '+919000000000',
  'bio': 'Quiet, tidy, works from home three days a week.',
  'occupation': 'Designer',
  'gender': 'FEMALE',
  'dateOfBirth': '1996-04-02T00:00:00Z',
  'role': 'USER',
  'createdAt': '2025-01-01T00:00:00Z',
});

TenantListingModel fixtureListing({
  String id = 'listing-1',
  String ownerId = 'owner-9',
  String status = 'ACTIVE',
}) => TenantListingModel.fromJson({
  'id': id,
  'ownerId': ownerId,
  'title': 'Sunny double room in Kothrud',
  'description':
      'Big south-facing room in a three-bed flat, ten minutes from the metro.',
  'budget': 15000,
  'cityId': 'city-1',
  'openTo': 'ANY',
  'status': status,
  'amenities': const ['WIFI', 'PARKING'],
  'photos': const [
    {'id': 'photo-1', 'objectKey': 'k1', 'listingId': 'listing-1'},
    {'id': 'photo-2', 'objectKey': 'k2', 'listingId': 'listing-1'},
  ],
  'propertyType': 'APARTMENT',
  'roomType': 'PRIVATE',
  'furnishing': 'SEMI_FURNISHED',
  'bedrooms': 3,
  'bathrooms': 2,
  'depositAmount': 30000,
  'availableFrom': '2026-09-01T00:00:00Z',
  'maxOccupants': 3,
  'city': const {'id': 'city-1', 'name': 'Pune', 'state': 'Maharashtra'},
  'owner': const {
    'id': 'owner-9',
    'fullName': 'Owner Person',
    'email': 'owner@example.com',
  },
  '_count': const {'enquiries': 4},
  'createdAt': '2026-08-01T00:00:00Z',
  'updatedAt': '2026-08-01T00:00:00Z',
});

FinderPostModel fixtureFinderPost({
  String id = 'post-1',
  String ownerId = 'owner-4',
  String status = 'ACTIVE',
}) => FinderPostModel.fromJson({
  'id': id,
  'ownerId': ownerId,
  'budgetMin': 8000,
  'budgetMax': 14000,
  'cityId': 'city-1',
  'genderPreference': 'ANY',
  'tier': 'SELF_SERVE',
  'status': status,
  'tags': const [
    {
      'tag': {'id': 'tag-1', 'label': 'Non-smoker', 'category': 'LIFESTYLE'},
    },
  ],
  'note': 'Looking for somewhere quiet near the metro from October.',
  'ageMin': 24,
  'ageMax': 34,
  'city': const {'id': 'city-1', 'name': 'Pune', 'state': 'Maharashtra'},
  'createdAt': '2026-08-02T00:00:00Z',
  'updatedAt': '2026-08-02T00:00:00Z',
});

EnquiryModel fixtureEnquiry({
  String id = 'enq-1',
  String status = 'PENDING',
  bool withContact = false,
}) => EnquiryModel.fromJson({
  'id': id,
  'status': status,
  'listing': const {
    'id': 'listing-1',
    'title': 'Sunny double room in Kothrud',
    'budget': 15000,
    'ownerId': 'owner-9',
    'photos': [
      {'id': 'photo-1', 'objectKey': 'k1', 'listingId': 'listing-1'},
    ],
  },
  'message': 'Hi — is the room still free from October?',
  'sender': const {
    'id': 'user-2',
    'fullName': 'Sender Person',
    'email': 'sender@example.com',
  },
  if (withContact)
    'senderContact': const {
      'fullName': 'Sender Person',
      'email': 'sender@example.com',
      'phone': '+919111111111',
    },
  if (withContact)
    'ownerContact': const {
      'fullName': 'Owner Person',
      'email': 'owner@example.com',
      'phone': '+919222222222',
    },
  'createdAt': '2026-08-10T00:00:00Z',
  'updatedAt': '2026-08-10T00:00:00Z',
});

// ── Repositories that answer from the fixtures above ──────────────────────
// Only the read paths are stubbed; anything that writes would need a real
// server to mean anything, and no test here presses those buttons.

class FakeSearchRepository extends SearchRepository {
  FakeSearchRepository(super.api);

  @override
  Future<List<TenantListingModel>> listings(
    ListingSearchFilters filters,
  ) async => [
    fixtureListing(),
    fixtureListing(id: 'listing-2'),
    fixtureListing(id: 'listing-3'),
  ];

  @override
  Future<List<FinderPostModel>> finderPosts(
    FinderSearchFilters filters,
  ) async => [fixtureFinderPost(), fixtureFinderPost(id: 'post-2')];
}

class FakeSavedRepository extends SavedRepository {
  FakeSavedRepository(super.api);

  @override
  Future<List<TenantListingModel>> listings() async => [fixtureListing()];

  @override
  Future<Set<String>> ids() async => {'listing-1'};

  @override
  Future<bool> save(String listingId) async => true;

  @override
  Future<bool> unsave(String listingId) async => false;
}

class FakeEnquiryRepository extends EnquiryRepository {
  FakeEnquiryRepository(super.api);

  @override
  Future<List<EnquiryModel>> received() async => [
    fixtureEnquiry(),
    fixtureEnquiry(id: 'enq-2', status: 'ACCEPTED', withContact: true),
    fixtureEnquiry(id: 'enq-3', status: 'DECLINED'),
  ];

  @override
  Future<List<EnquiryModel>> sent() async => [
    fixtureEnquiry(id: 'enq-4'),
    fixtureEnquiry(id: 'enq-5', status: 'ACCEPTED', withContact: true),
  ];

  @override
  Future<int> pendingCount() async => 2;
}

class FakeTenantListingRepository extends TenantListingRepository {
  FakeTenantListingRepository(super.api);

  /// The id the detail screen should treat as owned by the signed-in user, so
  /// the owner-only controls get rendered too.
  static const String ownedId = 'listing-owned';

  @override
  Future<TenantListingModel> byId(String id) async =>
      fixtureListing(id: id, ownerId: id == ownedId ? 'user-1' : 'owner-9');

  @override
  Future<List<TenantListingModel>> mine() async => [
    fixtureListing(ownerId: 'user-1'),
    fixtureListing(id: 'listing-2', ownerId: 'user-1', status: 'DRAFT'),
    fixtureListing(id: 'listing-3', ownerId: 'user-1', status: 'RENTED'),
  ];

  @override
  Future<void> remove(String id) async {}

  @override
  Future<TenantListingModel> uploadPhoto(String id, File file) async =>
      fixtureListing(id: id);
}

class FakeFinderPostRepository extends FinderPostRepository {
  FakeFinderPostRepository(super.api);

  static const String ownedId = 'post-owned';

  @override
  Future<FinderPostModel> byId(String id) async =>
      fixtureFinderPost(id: id, ownerId: id == ownedId ? 'user-1' : 'owner-4');

  @override
  Future<List<FinderPostModel>> mine() async => [
    fixtureFinderPost(ownerId: 'user-1'),
    fixtureFinderPost(id: 'post-2', ownerId: 'user-1', status: 'PAUSED'),
  ];

  @override
  Future<void> remove(String id) async {}
}
