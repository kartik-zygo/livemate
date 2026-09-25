import 'package:flutter/material.dart';

import '../../data/models/enums.dart';

/// Icon vocabulary for the domain enums. Kept out of the models so the data
/// layer stays free of Flutter imports.
extension AmenityIcon on Amenity {
  IconData get icon => switch (this) {
    Amenity.wifi => Icons.wifi_rounded,
    Amenity.ac => Icons.ac_unit_rounded,
    Amenity.furnished => Icons.chair_rounded,
    Amenity.washingMachine => Icons.local_laundry_service_rounded,
    Amenity.fridge => Icons.kitchen_rounded,
    Amenity.geyser => Icons.hot_tub_rounded,
    Amenity.parking => Icons.local_parking_rounded,
    Amenity.lift => Icons.elevator_rounded,
    Amenity.powerBackup => Icons.bolt_rounded,
    Amenity.balcony => Icons.balcony_rounded,
  };
}

extension PropertyTypeIcon on PropertyType {
  IconData get icon => switch (this) {
    PropertyType.apartment => Icons.apartment_rounded,
    PropertyType.independentHouse => Icons.house_rounded,
    PropertyType.pg => Icons.hotel_rounded,
    PropertyType.studio => Icons.meeting_room_rounded,
    PropertyType.villa => Icons.villa_rounded,
  };
}

extension RoomTypeIcon on RoomType {
  IconData get icon => switch (this) {
    RoomType.private => Icons.bed_rounded,
    RoomType.shared => Icons.bedroom_parent_rounded,
    RoomType.entirePlace => Icons.holiday_village_rounded,
  };
}

extension FurnishingIcon on Furnishing {
  IconData get icon => switch (this) {
    Furnishing.fullyFurnished => Icons.weekend_rounded,
    Furnishing.semiFurnished => Icons.chair_alt_rounded,
    Furnishing.unfurnished => Icons.crop_square_rounded,
  };
}

extension GenderIcon on Gender {
  IconData get icon => switch (this) {
    Gender.male => Icons.male_rounded,
    Gender.female => Icons.female_rounded,
    Gender.any => Icons.groups_rounded,
  };

  /// Phrasing for the "open to" line on a listing.
  String get openToLabel => switch (this) {
    Gender.male => 'Open to men',
    Gender.female => 'Open to women',
    Gender.any => 'Open to anyone',
  };
}

extension ProfileGenderIcon on ProfileGender {
  IconData get icon => switch (this) {
    ProfileGender.male => Icons.male_rounded,
    ProfileGender.female => Icons.female_rounded,
    ProfileGender.other => Icons.person_rounded,
  };
}

extension TagCategoryIcon on TagCategory {
  IconData get icon => switch (this) {
    TagCategory.cleanliness => Icons.cleaning_services_rounded,
    TagCategory.petFriendly => Icons.pets_rounded,
    TagCategory.foodPreference => Icons.restaurant_rounded,
  };
}

extension PostTierMeta on PostTier {
  IconData get icon => switch (this) {
    PostTier.selfServe => Icons.rocket_launch_rounded,
    PostTier.managed => Icons.workspace_premium_rounded,
  };

  String get blurb => switch (this) {
    PostTier.selfServe =>
      'Your post goes live instantly. You browse and reach out yourself.',
    PostTier.managed =>
      'A MyFlat Homes manager shortlists rooms for you and coordinates '
          'viewings.',
  };

  List<String> get perks => switch (this) {
    PostTier.selfServe => const [
      'Live for 30 days',
      'Appears in every search for your city',
      'Unlimited enquiries to listings',
    ],
    PostTier.managed => const [
      'Everything in Self-serve',
      'A dedicated manager works your brief',
      'Curated shortlist and viewing coordination',
      'Priority placement in your city',
    ],
  };
}
