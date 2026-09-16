import 'package:get/get.dart';

import '../../../data/repositories/finder_post_repository.dart';
import '../../../data/repositories/tenant_listing_repository.dart';
import '../controllers/my_posts_controller.dart';

/// One binding serving two routes. [showsListings] is set here rather than read
/// from `Get.arguments`, because these routes also carry arguments of their own
/// in other flows and the mode must never depend on that.
class MyPostsBinding extends Bindings {
  MyPostsBinding({required this.showsListings});

  final bool showsListings;

  @override
  void dependencies() {
    // Deleted eagerly so switching between the two routes never reuses a
    // controller still pointed at the other resource.
    Get.delete<MyPostsController>(force: true);
    Get.put(
      MyPostsController(
        Get.find<TenantListingRepository>(),
        Get.find<FinderPostRepository>(),
      )..showsListings = showsListings,
    );
  }
}
