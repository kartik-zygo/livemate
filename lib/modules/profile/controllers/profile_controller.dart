import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/bindings/initial_binding.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/legal_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/reference_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this._auth, this._reference);

  final AuthService _auth;
  final ReferenceRepository _reference;

  final Rx<ViewStatus> status = ViewStatus.idle.obs;
  final RxnString error = RxnString();

  /// Starts on the fallback URLs — the same pages — and is replaced by
  /// `GET /legal` once that answers.
  final Rx<LegalInfo> legal = LegalInfo.fallback().obs;

  Rxn<UserModel> get user => _auth.user;

  UserModel? get profile => _auth.profile;

  @override
  void onReady() {
    super.onReady();
    if (profile == null) load();
    _loadLegal();
  }

  Future<void> load() async {
    status.value = ViewStatus.loading;
    error.value = null;
    try {
      await _auth.refreshProfile();
      status.value = ViewStatus.success;
    } on ApiException catch (e) {
      error.value = e.message;
      status.value = ViewStatus.error;
    }
  }

  Future<void> reload() => load();

  Future<void> _loadLegal() async {
    try {
      legal.value = await _reference.legal();
    } on ApiException {
      // The fallback already points at the same pages.
    }
  }

  void editProfile() =>
      Get.toNamed(Routes.editProfile)?.then((_) => _auth.refreshProfile());

  void openMyListings() => Get.toNamed(Routes.myListings);

  void openMyFinderPosts() => Get.toNamed(Routes.myFinderPosts);

  Future<void> openPrivacyPolicy() async {
    final uri = Uri.tryParse(legal.value.privacyPolicyUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      AppFeedback.error('The privacy policy could not be opened.');
    }
  }

  /// App Store guideline 5.1.1(v): an app that lets people create an account
  /// must let them delete it from inside the app.
  Future<void> deleteAccount() async {
    final confirmed = await AppFeedback.confirm(
      title: 'Delete your account?',
      message:
          'Your profile and everything you have posted will be permanently '
          'deleted. This cannot be undone.',
      confirmLabel: 'Delete account',
      destructive: true,
      icon: Icons.person_remove_rounded,
    );
    if (!confirmed) return;

    try {
      await _auth.deleteAccount();
      InitialBinding.clearSignedInState();
      Get.offAllNamed(Routes.login);
      AppFeedback.success('Your account has been deleted.');
    } on ApiException catch (e) {
      AppFeedback.error(e.message);
    }
  }

  Future<void> signOut() async {
    final confirmed = await AppFeedback.confirm(
      title: 'Sign out?',
      message: 'You will need your email and password to sign back in.',
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await _auth.signOut();
      InitialBinding.clearSignedInState();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      AppFeedback.error(AuthService.describeAuthError(e).message);
    }
  }
}
