import 'package:livemate/core/utils/formatters.dart';
import 'package:livemate/data/models/enquiry_model.dart';
import 'package:livemate/data/models/enums.dart';
import 'package:livemate/data/models/search_filters.dart';
import 'package:livemate/data/models/tenant_listing_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('enums', () {
    test('decode wire values verbatim', () {
      expect(Gender.fromWire('FEMALE'), Gender.female);
      expect(PlatformRole.fromWire('admin'), PlatformRole.admin);
      expect(ListingStatus.fromWire('RENTED'), ListingStatus.rented);
      expect(PostTier.fromWire('MANAGED'), PostTier.managed);
    });

    test('unknown values fall back instead of throwing', () {
      expect(Gender.fromWire('NONBINARY'), Gender.any);
      expect(EnquiryStatus.fromWire(null), EnquiryStatus.pending);
      expect(Amenity.listFromWire(['WIFI', 'TELEPORTER']), [Amenity.wifi]);
    });

    test('nullable enums stay null when the field is absent', () {
      expect(PropertyType.fromWire(null), isNull);
      expect(RoomType.fromWire(null), isNull);
      expect(ProfileGender.fromWire(null), isNull);
    });
  });

  group('currency', () {
    test('formats with Indian digit grouping', () {
      expect(Fmt.money(15000), '₹15,000');
      expect(Fmt.money(120000), '₹1,20,000');
      expect(Fmt.money(999), '₹999');
    });

    test('renders a range and an open-ended range', () {
      expect(Fmt.moneyRange(10000, 20000), '₹10,000 – ₹20,000');
      expect(Fmt.moneyRange(null, 20000), 'Up to ₹20,000');
      expect(Fmt.moneyRange(10000, null), '₹10,000+');
    });
  });

  group('availability', () {
    TenantListingModel listingWith(DateTime? availableFrom) =>
        TenantListingModel.fromJson({
          'id': 'l1',
          'ownerId': 'o1',
          'title': 'Room',
          'description': 'A room',
          'budget': 15000,
          'cityId': 'c1',
          'openTo': 'ANY',
          'status': 'ACTIVE',
          'amenities': <String>[],
          'photos': <Map<String, dynamic>>[],
          'availableFrom': availableFrom?.toIso8601String(),
        });

    test('a null date means available now', () {
      expect(listingWith(null).isAvailableNow, isTrue);
      expect(Fmt.availability(null), 'Available now');
    });

    test('a past date also means available now', () {
      final past = DateTime.now().subtract(const Duration(days: 30));
      expect(listingWith(past).isAvailableNow, isTrue);
      expect(Fmt.availability(past), 'Available now');
    });

    test('a future date is not available now', () {
      final future = DateTime.now().add(const Duration(days: 30));
      expect(listingWith(future).isAvailableNow, isFalse);
      expect(Fmt.availability(future), startsWith('From'));
    });
  });

  group('enquiry contact gate', () {
    Map<String, dynamic> enquiryJson({
      required String status,
      Map<String, dynamic>? ownerContact,
    }) => {
      'id': 'e1',
      'status': status,
      'message': 'Hi',
      'listing': {
        'id': 'l1',
        'title': 'Room',
        'budget': 15000,
        'ownerId': 'o1',
        'photos': <Map<String, dynamic>>[],
      },
      'ownerContact': ownerContact,
    };

    test('a pending enquiry exposes no contact', () {
      final enquiry = EnquiryModel.fromJson(enquiryJson(status: 'PENDING'));
      expect(enquiry.contact, isNull);
      expect(enquiry.ownerContact, isNull);
    });

    test('a declined enquiry exposes no contact', () {
      final enquiry = EnquiryModel.fromJson(enquiryJson(status: 'DECLINED'));
      expect(enquiry.contact, isNull);
    });

    test('an accepted enquiry exposes the contact the API sent', () {
      final enquiry = EnquiryModel.fromJson(
        enquiryJson(
          status: 'ACCEPTED',
          ownerContact: {
            'id': 'o1',
            'fullName': 'Asha R',
            'email': 'a@b.com',
            'phone': '+919876543210',
          },
        ),
      );
      expect(enquiry.contact, isNotNull);
      expect(enquiry.contact!.email, 'a@b.com');
      expect(enquiry.contact!.hasAnything, isTrue);
    });
  });

  group('search filters', () {
    test('cityId and sort are always sent', () {
      final query = const ListingSearchFilters(cityId: 'c1').toQuery();
      expect(query['cityId'], 'c1');
      expect(query['sort'], 'NEWEST');
    });

    test('multi-select filters serialise as csv', () {
      final query = const ListingSearchFilters(
        cityId: 'c1',
        propertyTypes: {PropertyType.pg, PropertyType.studio},
        roomTypes: {RoomType.private},
      ).toQuery();
      expect(query['propertyTypes'], 'PG,STUDIO');
      expect(query['roomTypes'], 'PRIVATE');
    });

    test('unset filters are omitted entirely', () {
      final query = const ListingSearchFilters(cityId: 'c1').toQuery();
      expect(query.containsKey('budgetMin'), isFalse);
      expect(query.containsKey('gender'), isFalse);
      expect(query.containsKey('availableBy'), isFalse);
    });

    test('clearing keeps the city and sort but drops the narrowing', () {
      const filters = ListingSearchFilters(
        cityId: 'c1',
        budgetMax: 20000,
        minBedrooms: 2,
        sort: ListingSort.priceAsc,
      );
      expect(filters.activeCount, 2);

      final cleared = filters.cleared();
      expect(cleared.cityId, 'c1');
      expect(cleared.sort, ListingSort.priceAsc);
      expect(cleared.activeCount, 0);
    });

    test('copyWith can explicitly clear a nullable filter', () {
      const filters = ListingSearchFilters(cityId: 'c1', budgetMax: 20000);
      expect(filters.copyWith(clearBudgetMax: true).budgetMax, isNull);
      // Passing null alone must not clear it — that is what the flag is for.
      expect(filters.copyWith().budgetMax, 20000);
    });
  });

  group('payload pruning', () {
    test('omits every field the user did not set', () {
      final json = const TenantListingPayload(
        title: 'Room',
        cityId: 'c1',
      ).toJson();
      expect(json.keys, containsAll(['title', 'cityId']));
      expect(json.containsKey('bedrooms'), isFalse);
      expect(json.containsKey('depositAmount'), isFalse);
    });

    test('serialises enums to their wire values', () {
      final json = const TenantListingPayload(
        openTo: Gender.female,
        roomType: RoomType.entirePlace,
        amenities: [Amenity.wifi, Amenity.parking],
      ).toJson();
      expect(json['openTo'], 'FEMALE');
      expect(json['roomType'], 'ENTIRE_PLACE');
      expect(json['amenities'], ['WIFI', 'PARKING']);
    });
  });
}
