import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/reference_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/city_model.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/finder_post_model.dart';
import '../../../data/models/tag_model.dart';
import '../../../data/repositories/finder_post_repository.dart';

enum FinderStep { brief, preferences, tier }

extension FinderStepMeta on FinderStep {
  String get title => switch (this) {
    FinderStep.brief => 'Your brief',
    FinderStep.preferences => 'Who you want to live with',
    FinderStep.tier => 'Choose your support',
  };

  String get blurb => switch (this) {
    FinderStep.brief =>
      'Where you are looking, what you can spend, and a line about you.',
    FinderStep.preferences => 'Optional, but it makes matches better.',
    FinderStep.tier => 'Pick how much help you want finding a room.',
  };
}

class CreateFinderPostController extends GetxController {
  CreateFinderPostController(this._repo, this._reference);

  final FinderPostRepository _repo;
  final ReferenceService _reference;

  final formKeys = {
    for (final step in FinderStep.values) step: GlobalKey<FormState>(),
  };

  final budgetMin = TextEditingController();
  final budgetMax = TextEditingController();
  final note = TextEditingController();
  final ageMin = TextEditingController();
  final ageMax = TextEditingController();

  final Rx<FinderStep> step = FinderStep.brief.obs;
  final Rxn<CityModel> city = Rxn<CityModel>();
  final Rx<Gender> genderPreference = Gender.any.obs;
  final Rx<PostTier> tier = PostTier.selfServe.obs;
  final RxSet<String> tagIds = <String>{}.obs;

  final RxBool submitting = false.obs;
  final RxnString formError = RxnString();
  final RxnString cityError = RxnString();

  List<TagModel> get tags => _reference.tags;

  int get stepIndex => step.value.index;

  int get totalSteps => FinderStep.values.length;

  double get progress => (stepIndex + 1) / totalSteps;

  bool get atTagLimit => tagIds.length >= Env.maxTagsPerFinderPost;

  @override
  void onInit() {
    super.onInit();
    city.value = _reference.selectedCity.value;
    // Tags drive step two; make sure they are loaded even on a cold start.
    _reference.ensureLoaded();
  }

  @override
  void onClose() {
    budgetMin.dispose();
    budgetMax.dispose();
    note.dispose();
    ageMin.dispose();
    ageMax.dispose();
    super.onClose();
  }

  int? _parse(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : int.tryParse(t);
  }

  bool _validateCurrentStep() {
    formError.value = null;

    if (step.value == FinderStep.brief) {
      if (city.value == null) {
        cityError.value = 'Choose the city you are looking in.';
        return false;
      }
      cityError.value = null;

      if (!(formKeys[FinderStep.brief]?.currentState?.validate() ?? false)) {
        return false;
      }

      final rangeError = Validators.budgetRange(
        _parse(budgetMin),
        _parse(budgetMax),
      );
      if (rangeError != null) {
        formError.value = rangeError;
        return false;
      }
      return true;
    }

    if (step.value == FinderStep.preferences) {
      if (!(formKeys[FinderStep.preferences]?.currentState?.validate() ??
          false)) {
        return false;
      }
      final ageError = Validators.ageRange(_parse(ageMin), _parse(ageMax));
      if (ageError != null) {
        formError.value = ageError;
        return false;
      }
      return true;
    }

    return true;
  }

  void next() {
    if (!_validateCurrentStep()) return;
    if (stepIndex >= totalSteps - 1) return;
    step.value = FinderStep.values[stepIndex + 1];
  }

  void back() {
    if (stepIndex == 0) {
      Get.back<void>();
      return;
    }
    step.value = FinderStep.values[stepIndex - 1];
  }

  void toggleTag(String id) {
    if (tagIds.contains(id)) {
      tagIds.remove(id);
      return;
    }
    if (atTagLimit) {
      AppFeedback.info('Pick up to ${Env.maxTagsPerFinderPost} tags.');
      return;
    }
    tagIds.add(id);
  }

  /// `POST /finder-posts` publishes straight to ACTIVE, so there is nothing to
  /// confirm before sending it.
  Future<void> submit() async {
    if (!_validateCurrentStep()) return;

    submitting.value = true;
    formError.value = null;

    try {
      final post = await _repo.create(
        FinderPostPayload(
          budgetMin: _parse(budgetMin),
          budgetMax: _parse(budgetMax),
          genderPreference: genderPreference.value,
          cityId: city.value?.id,
          note: note.text.trim().isEmpty ? null : note.text.trim(),
          ageMin: _parse(ageMin),
          ageMax: _parse(ageMax),
          tier: tier.value,
          tagIds: tagIds.isEmpty ? null : tagIds.toList(),
        ),
      );
      _onCreated(post);
    } on ApiException catch (e) {
      formError.value = e.messages.isEmpty ? e.message : e.messages.join('\n');
      if (e.isValidation) step.value = FinderStep.brief;
    } finally {
      submitting.value = false;
    }
  }

  void _onCreated(FinderPostModel post) {
    AppFeedback.success(
      post.status == FinderPostStatus.active
          ? 'Your post is live.'
          : 'Post created — status: ${post.status.label}.',
    );
    Get.offNamedUntil(
      Routes.finderPostDetail,
      (route) => route.isFirst,
      arguments: post.id,
    );
  }
}
