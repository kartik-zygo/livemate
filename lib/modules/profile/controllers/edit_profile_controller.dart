import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/user_repository.dart';

class EditProfileController extends GetxController {
  EditProfileController(this._users, this._auth);

  final UserRepository _users;
  final AuthService _auth;

  final formKey = GlobalKey<FormState>();
  final fullName = TextEditingController();
  final phone = TextEditingController();
  final bio = TextEditingController();
  final occupation = TextEditingController();

  final Rxn<ProfileGender> gender = Rxn<ProfileGender>();
  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();
  final RxBool saving = false.obs;
  final RxnString formError = RxnString();

  @override
  void onInit() {
    super.onInit();
    final user = _auth.profile;
    if (user != null) {
      fullName.text = user.fullName;
      phone.text = user.phone ?? '';
      bio.text = user.bio ?? '';
      occupation.text = user.occupation ?? '';
      gender.value = user.gender;
      dateOfBirth.value = user.dateOfBirth;
    }
  }

  @override
  void onClose() {
    fullName.dispose();
    phone.dispose();
    bio.dispose();
    occupation.dispose();
    super.onClose();
  }

  /// The oldest and youngest dates the picker will offer. 18 is the platform
  /// minimum used elsewhere in the product.
  DateTime get latestDob =>
      DateTime.now().subtract(const Duration(days: 365 * 18));
  DateTime get earliestDob =>
      DateTime.now().subtract(const Duration(days: 365 * 100));

  Future<void> pickDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth.value ?? DateTime(1998),
      firstDate: earliestDob,
      lastDate: latestDob,
      helpText: 'Your date of birth',
    );
    if (picked != null) dateOfBirth.value = picked;
  }

  Future<void> save() async {
    formError.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;

    saving.value = true;
    try {
      // Every field is optional on the API; empty strings are still sent so a
      // user can deliberately clear a bio or occupation.
      final updated = await _users.updateMe(
        fullName: fullName.text.trim(),
        phone: phone.text.trim(),
        bio: bio.text.trim(),
        occupation: occupation.text.trim(),
        gender: gender.value,
        dateOfBirth: dateOfBirth.value,
      );
      _auth.setProfile(updated);
      AppFeedback.success('Profile updated.');
      Get.back<void>();
    } on ApiException catch (e) {
      // Validation failures can carry several field errors at once.
      formError.value = e.messages.isEmpty ? e.message : e.messages.join('\n');
    } finally {
      saving.value = false;
    }
  }
}
