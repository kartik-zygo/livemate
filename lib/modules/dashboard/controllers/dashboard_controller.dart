import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/bindings/initial_binding.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/enquiry_badge_service.dart';
import '../../../core/services/shortlist_service.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/user_model.dart';

/// The dashboard's sections, so the rest of the app can say
/// `DashboardSection.enquiries` rather than remembering that Enquiries is 3.
///
/// Each carries its own presentation — there is exactly one nav model in the
/// app now, and both the section rail and the drawer read it from here rather
/// than each keeping a parallel list that can drift.
enum DashboardSection {
  home(
    'Home',
    'Everything at a glance',
    Icons.dashboard_rounded,
    Icons.dashboard_outlined,
  ),
  discover(
    'Discover',
    'Rooms and flatmates, city by city',
    Icons.explore_rounded,
    Icons.explore_outlined,
  ),
  search(
    'Search',
    'Narrow by budget, room type or amenities',
    Icons.search_rounded,
    Icons.search_outlined,
  ),
  enquiries(
    'Enquiries',
    'Where a room turns into a conversation',
    Icons.forum_rounded,
    Icons.forum_outlined,
  ),
  saved(
    'Shortlist',
    'Rooms you are keeping an eye on',
    Icons.favorite_rounded,
    Icons.favorite_border_rounded,
  ),
  profile(
    'Profile',
    'You, and everything you have posted',
    Icons.person_rounded,
    Icons.person_outline_rounded,
  );

  const DashboardSection(this.label, this.blurb, this.icon, this.iconOutline);

  final String label;
  final String blurb;
  final IconData icon;
  final IconData iconOutline;
}

/// The one shell controller. Owns which section is on screen, the drawer, and
/// every destination reachable from the dashboard.
class DashboardController extends GetxController {
  DashboardController(this._badge, this._shortlist, this._auth);

  final EnquiryBadgeService _badge;
  final ShortlistService _shortlist;
  final AuthService _auth;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final Rx<DashboardSection> section = DashboardSection.home.obs;

  /// Where back goes. Without this, leaving Home for Enquiries and pressing
  /// back would exit the app rather than returning where you came from.
  final List<DashboardSection> _history = <DashboardSection>[];

  int get index => section.value.index;

  RxInt get pendingEnquiries => _badge.pendingCount;

  RxSet<String> get savedIds => _shortlist.savedIds;

  Rxn<UserModel> get user => _auth.user;

  bool get canPopSection => _history.isNotEmpty;

  @override
  void onReady() {
    super.onReady();
    _badge.refresh();
  }

  void goTo(DashboardSection target) {
    if (target == section.value) {
      closeDrawer();
      return;
    }

    _history.add(section.value);
    // One screen back is all anyone means by "back" here; a deep stack of tab
    // switches would be worse than useless.
    if (_history.length > 8) _history.removeAt(0);

    section.value = target;
    closeDrawer();

    // Refresh the things that go stale while another section is on screen.
    switch (target) {
      case DashboardSection.enquiries:
        _badge.refresh();
      case DashboardSection.saved:
        _shortlist.refresh();
      case DashboardSection.home:
        _badge.refresh();
        _shortlist.refresh();
      default:
        break;
    }
  }

  void changeSection(int next) => goTo(DashboardSection.values[next]);

  /// Returns false when there is nothing left to go back to, so the caller can
  /// let the system handle the pop.
  bool popSection() {
    if (_history.isEmpty) {
      if (section.value == DashboardSection.home) return false;
      section.value = DashboardSection.home;
      return true;
    }
    section.value = _history.removeLast();
    return true;
  }

  void openDrawer() => scaffoldKey.currentState?.openDrawer();

  void closeDrawer() {
    final state = scaffoldKey.currentState;
    if (state != null && state.isDrawerOpen) state.closeDrawer();
  }

  void createListing() {
    closeDrawer();
    Get.toNamed(Routes.createListing);
  }

  void createFinderPost() {
    closeDrawer();
    Get.toNamed(Routes.createFinderPost);
  }

  void openMyListings() {
    closeDrawer();
    Get.toNamed(Routes.myListings);
  }

  void openMyFinderPosts() {
    closeDrawer();
    Get.toNamed(Routes.myFinderPosts);
  }

  void editProfile() {
    closeDrawer();
    Get.toNamed(Routes.editProfile)?.then((_) => _auth.refreshProfile());
  }

  Future<void> signOut() async {
    closeDrawer();
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
