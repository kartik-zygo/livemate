import 'package:get/get.dart';

import '../../modules/auth/bindings/login_binding.dart';
import '../../modules/auth/bindings/signup_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/signup_view.dart';
import '../../modules/create_finder_post/bindings/create_finder_post_binding.dart';
import '../../modules/create_finder_post/views/create_finder_post_view.dart';
import '../../modules/create_listing/bindings/create_listing_binding.dart';
import '../../modules/create_listing/views/create_listing_view.dart';
import '../../modules/finder_post_detail/bindings/finder_post_detail_binding.dart';
import '../../modules/finder_post_detail/views/finder_post_detail_view.dart';
import '../../modules/listing_detail/bindings/listing_detail_binding.dart';
import '../../modules/listing_detail/views/listing_detail_view.dart';
import '../../modules/my_posts/bindings/my_posts_binding.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_view.dart';
import '../../modules/my_posts/views/my_posts_view.dart';
import '../../modules/profile/bindings/edit_profile_binding.dart';
import '../../modules/profile/views/edit_profile_view.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static const String initial = Routes.splash;

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: Routes.root,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.listingDetail,
      page: () => const ListingDetailView(),
      binding: ListingDetailBinding(),
    ),
    GetPage(
      name: Routes.createListing,
      page: () => const CreateListingView(),
      binding: CreateListingBinding(),
      fullscreenDialog: true,
    ),
    // Edit reuses the create flow, hydrated from the listing passed as an
    // argument.
    GetPage(
      name: Routes.editListing,
      page: () => const CreateListingView(),
      binding: CreateListingBinding(),
      fullscreenDialog: true,
    ),
    GetPage(
      name: Routes.myListings,
      page: () => const MyPostsView(),
      binding: MyPostsBinding(showsListings: true),
    ),
    GetPage(
      name: Routes.finderPostDetail,
      page: () => const FinderPostDetailView(),
      binding: FinderPostDetailBinding(),
    ),
    GetPage(
      name: Routes.createFinderPost,
      page: () => const CreateFinderPostView(),
      binding: CreateFinderPostBinding(),
      fullscreenDialog: true,
    ),
    GetPage(
      name: Routes.myFinderPosts,
      page: () => const MyPostsView(),
      binding: MyPostsBinding(showsListings: false),
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
  ];
}
