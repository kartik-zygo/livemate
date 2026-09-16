/// Named routes. Navigation is always `Get.toNamed(Routes.x, arguments: …)` —
/// never a raw MaterialPageRoute.
abstract class Routes {
  Routes._();

  static const String splash = '/';

  /// The one-time intro, shown between the splash and sign-in on a fresh
  /// install. See [OnboardingService] for how "once" is remembered.
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  /// The dashboard shell — one page holding Home, Discover, Search,
  /// Enquiries, Shortlist and Profile, navigated from its own section rail and
  /// from the app drawer.
  static const String root = '/home';

  static const String listingDetail = '/listing';
  static const String createListing = '/listing/create';
  static const String editListing = '/listing/edit';
  static const String myListings = '/listing/mine';

  static const String finderPostDetail = '/finder-post';
  static const String createFinderPost = '/finder-post/create';
  static const String myFinderPosts = '/finder-post/mine';

  static const String editProfile = '/profile/edit';
}
