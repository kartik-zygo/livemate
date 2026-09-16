import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/reference_service.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/city_model.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/tenant_listing_model.dart';
import '../../../data/repositories/tenant_listing_repository.dart';

/// Steps in the create flow. Edit mode reuses the same form minus photos, which
/// are managed on their own step against an already-created listing.
enum ListingStep { basics, location, property, amenities, photos }

extension ListingStepMeta on ListingStep {
  String get title => switch (this) {
    ListingStep.basics => 'The basics',
    ListingStep.location => 'Where is it',
    ListingStep.property => 'About the place',
    ListingStep.amenities => 'What is included',
    ListingStep.photos => 'Photos',
  };

  String get blurb => switch (this) {
    ListingStep.basics => 'Give it a name, a description and a monthly rent.',
    ListingStep.location =>
      'Discovery is city to city, so this decides who sees your listing.',
    ListingStep.property => 'The details people filter on.',
    ListingStep.amenities => 'Tick everything the room comes with.',
    ListingStep.photos =>
      'Three photos publish your listing. Four is the maximum.',
  };
}

class CreateListingController extends GetxController {
  CreateListingController(this._repo, this._reference);

  final TenantListingRepository _repo;
  final ReferenceService _reference;

  final formKeys = {
    for (final step in ListingStep.values) step: GlobalKey<FormState>(),
  };

  final title = TextEditingController();
  final description = TextEditingController();
  final budget = TextEditingController();
  final deposit = TextEditingController();
  final bedrooms = TextEditingController();
  final bathrooms = TextEditingController();
  final maxOccupants = TextEditingController();

  final Rx<ListingStep> step = ListingStep.basics.obs;
  final Rxn<CityModel> city = Rxn<CityModel>();
  final Rx<Gender> openTo = Gender.any.obs;
  final Rxn<PropertyType> propertyType = Rxn<PropertyType>();
  final Rxn<RoomType> roomType = Rxn<RoomType>();
  final Rxn<Furnishing> furnishing = Rxn<Furnishing>();
  final Rxn<DateTime> availableFrom = Rxn<DateTime>();
  final RxSet<Amenity> amenities = <Amenity>{}.obs;

  final RxList<File> pendingPhotos = <File>[].obs;
  final RxBool submitting = false.obs;
  final RxBool uploadingPhotos = false.obs;
  final RxInt uploadedCount = 0.obs;
  final RxnString formError = RxnString();
  final RxnString cityError = RxnString();

  /// Non-null in edit mode.
  TenantListingModel? existing;

  /// The listing once created, so photo uploads have something to attach to.
  final Rxn<TenantListingModel> created = Rxn<TenantListingModel>();

  bool get isEditing => existing != null;

  int get stepIndex => step.value.index;

  int get totalSteps => ListingStep.values.length;

  double get progress => (stepIndex + 1) / totalSteps;

  int get existingPhotoCount =>
      created.value?.photos.length ?? existing?.photos.length ?? 0;

  int get totalPhotoCount => existingPhotoCount + pendingPhotos.length;

  int get photosRemaining => Env.maxPhotosPerListing - totalPhotoCount;

  bool get meetsPublishThreshold => totalPhotoCount >= Env.minPhotosToPublish;

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg is TenantListingModel) {
      existing = arg;
      created.value = arg;
      _hydrateFrom(arg);
    } else {
      // Seed the city from wherever the user is browsing.
      city.value = _reference.selectedCity.value;
    }
  }

  @override
  void onClose() {
    title.dispose();
    description.dispose();
    budget.dispose();
    deposit.dispose();
    bedrooms.dispose();
    bathrooms.dispose();
    maxOccupants.dispose();
    super.onClose();
  }

  void _hydrateFrom(TenantListingModel listing) {
    title.text = listing.title;
    description.text = listing.description;
    budget.text = '${listing.budget}';
    deposit.text = listing.depositAmount?.toString() ?? '';
    bedrooms.text = listing.bedrooms?.toString() ?? '';
    bathrooms.text = listing.bathrooms?.toString() ?? '';
    maxOccupants.text = listing.maxOccupants?.toString() ?? '';
    city.value = listing.city ?? _reference.cityById(listing.cityId);
    openTo.value = listing.openTo;
    propertyType.value = listing.propertyType;
    roomType.value = listing.roomType;
    furnishing.value = listing.furnishing;
    availableFrom.value = listing.availableFrom;
    amenities.assignAll(listing.amenities);
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  bool _validateCurrentStep() {
    formError.value = null;

    if (step.value == ListingStep.location) {
      if (city.value == null) {
        cityError.value = 'Choose a city — it decides who sees this listing.';
        return false;
      }
      cityError.value = null;
      return true;
    }

    return formKeys[step.value]?.currentState?.validate() ?? true;
  }

  void next() {
    if (!_validateCurrentStep()) return;
    if (stepIndex >= totalSteps - 1) return;
    step.value = ListingStep.values[stepIndex + 1];
  }

  void back() {
    if (stepIndex == 0) {
      Get.back<void>();
      return;
    }
    step.value = ListingStep.values[stepIndex - 1];
  }

  void goToStep(ListingStep target) {
    // Only allow jumping backwards; forward jumps would skip validation.
    if (target.index <= stepIndex) step.value = target;
  }

  // ── Photos ──────────────────────────────────────────────────────────────

  Future<void> pickPhotos({required bool fromCamera}) async {
    if (photosRemaining <= 0) {
      AppFeedback.info(
        'Four photos is the maximum. Remove one to add another.',
      );
      return;
    }

    final picker = ImagePicker();
    try {
      if (fromCamera) {
        final shot = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 82,
          maxWidth: 1920,
        );
        if (shot != null) await _stagePhoto(File(shot.path));
        return;
      }

      final picked = await picker.pickMultiImage(
        imageQuality: 82,
        maxWidth: 1920,
        limit: photosRemaining,
      );
      for (final image in picked.take(photosRemaining)) {
        await _stagePhoto(File(image.path));
      }
    } catch (e) {
      AppFeedback.error('Could not open your photos. $e');
    }
  }

  /// Checks the 2 MB ceiling before staging, so an oversized file is caught
  /// here rather than after an upload attempt.
  Future<void> _stagePhoto(File file) async {
    final bytes = await file.length();
    if (bytes > Env.maxPhotoBytes) {
      AppFeedback.error(
        'That photo is over 2 MB. Pick a smaller one or crop it first.',
      );
      return;
    }
    pendingPhotos.add(file);
  }

  void removePendingPhoto(int index) {
    if (index >= 0 && index < pendingPhotos.length) {
      pendingPhotos.removeAt(index);
    }
  }

  // ── Submit ──────────────────────────────────────────────────────────────

  TenantListingPayload _payload() => TenantListingPayload(
    title: title.text.trim(),
    description: description.text.trim(),
    budget: int.tryParse(budget.text.trim()) ?? 0,
    cityId: city.value?.id,
    openTo: openTo.value,
    amenities: amenities.toList(),
    propertyType: propertyType.value,
    roomType: roomType.value,
    furnishing: furnishing.value,
    bedrooms: int.tryParse(bedrooms.text.trim()),
    bathrooms: int.tryParse(bathrooms.text.trim()),
    depositAmount: int.tryParse(deposit.text.trim()),
    availableFrom: availableFrom.value,
    maxOccupants: int.tryParse(maxOccupants.text.trim()),
  );

  Future<void> submit() async {
    if (!_validateCurrentStep()) return;
    if (city.value == null) {
      step.value = ListingStep.location;
      cityError.value = 'Choose a city before publishing.';
      return;
    }

    submitting.value = true;
    formError.value = null;

    try {
      // Create (or update) first — photos need a listing id to attach to.
      final target = created.value == null
          ? await _repo.create(_payload())
          : await _repo.update(created.value!.id, _payload());
      created.value = target;

      if (pendingPhotos.isNotEmpty) {
        await _uploadPending(target.id);
      }

      final finished = created.value!;
      AppFeedback.success(
        finished.status == ListingStatus.active
            ? 'Your listing is live.'
            : 'Saved as a draft. Add '
                  '${Env.minPhotosToPublish - finished.photos.length} more '
                  'photo(s) to publish it.',
      );
      Get.offNamedUntil(
        Routes.listingDetail,
        (route) => route.isFirst,
        arguments: finished.id,
      );
    } on ApiException catch (e) {
      formError.value = e.messages.isEmpty ? e.message : e.messages.join('\n');
      // Send the user back to the step most likely to hold the bad field.
      if (e.isValidation && created.value == null) {
        step.value = ListingStep.basics;
      }
    } finally {
      submitting.value = false;
    }
  }

  /// Uploads staged photos one at a time — the API takes a single file per
  /// request and returns the updated listing each time.
  Future<void> _uploadPending(String listingId) async {
    uploadingPhotos.value = true;
    uploadedCount.value = 0;

    final failures = <String>[];
    final staged = List<File>.from(pendingPhotos);

    for (final file in staged) {
      try {
        created.value = await _repo.uploadPhoto(listingId, file);
        pendingPhotos.remove(file);
        uploadedCount.value++;
      } on ApiException catch (e) {
        failures.add(e.message);
      }
    }

    uploadingPhotos.value = false;

    if (failures.isNotEmpty) {
      AppFeedback.error(
        failures.length == 1
            ? failures.first
            : '${failures.length} photos could not be uploaded.',
      );
    }
  }

  /// Adds photos to a listing that already exists, without re-submitting the
  /// whole form.
  Future<void> uploadPhotosNow() async {
    final target = created.value;
    if (target == null || pendingPhotos.isEmpty) return;
    await _uploadPending(target.id);
  }

  Future<void> pickAvailableFrom(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: availableFrom.value ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Available from',
    );
    if (picked != null) availableFrom.value = picked;
  }

  void clearAvailableFrom() => availableFrom.value = null;

  void toggleAmenity(Amenity amenity) {
    if (amenities.contains(amenity)) {
      amenities.remove(amenity);
    } else {
      amenities.add(amenity);
    }
  }
}
