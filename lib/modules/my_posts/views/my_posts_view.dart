import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/config/env.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/finder_post_card.dart';
import '../../../core/widgets/listing_card.dart';
import '../../../core/widgets/pills.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/tenant_listing_model.dart';
import '../controllers/my_posts_controller.dart';

class MyPostsView extends GetView<MyPostsController> {
  const MyPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    final showsListings = controller.showsListings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        seed: showsListings ? 0 : 2,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 18, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back<void>,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Text(
                        showsListings ? 'My listings' : 'My finder posts',
                        style: AppTextStyles.h2,
                      ),
                    ),
                    Obx(() {
                      if (controller.status.value.isLoading) {
                        return const SizedBox.shrink();
                      }
                      return Row(
                        children: [
                          if (controller.liveCount > 0)
                            Pill(
                              label: '${controller.liveCount} live',
                              tone: PillTone.accent,
                              dense: true,
                            ),
                          if (controller.draftCount > 0) ...[
                            const SizedBox(width: 6),
                            Pill(
                              label: '${controller.draftCount} draft',
                              tone: PillTone.amber,
                              dense: true,
                            ),
                          ],
                        ],
                      );
                    }),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.reload,
                  color: AppColors.brand600,
                  backgroundColor: Colors.white,
                  child: Obx(() => _buildBody(showsListings)),
                ),
              ),
              StickyActionBar(
                child: AppButton(
                  label: showsListings
                      ? 'List another room'
                      : 'New finder post',
                  icon: Icons.add_rounded,
                  onPressed: showsListings
                      ? controller.createListing
                      : controller.createFinderPost,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool showsListings) {
    if (controller.status.value.isLoading) {
      return SkeletonList(
        count: 3,
        builder: showsListings ? null : (_) => const ListRowSkeleton(),
      );
    }

    if (controller.status.value.isError) {
      return ListView(
        padding: const EdgeInsets.only(top: 30),
        children: [
          ErrorState(
            message: controller.error.value ?? 'Could not load these.',
            onRetry: controller.load,
          ),
        ],
      );
    }

    if (showsListings) {
      if (controller.listings.isEmpty) {
        return ListView(
          padding: const EdgeInsets.only(top: 10),
          children: [
            EmptyState(
              illustration: AppIllustration.listings,
              title: 'You have not listed a room yet',
              message:
                  'Post your room with three photos and it goes live to '
                  'everyone searching your city. Listing is free.',
              actionLabel: 'List a room',
              onAction: controller.createListing,
            ),
          ],
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        itemCount: controller.listings.length,
        itemBuilder: (context, i) {
          final listing = controller.listings[i];
          return EntryAnimation(
            index: i,
            child: ListingCard(
              listing: listing,
              showStatus: true,
              showSaveButton: false,
              onTap: () => controller.openListing(listing),
              trailing: _DraftHint(listing: listing),
            ),
          );
        },
      );
    }

    if (controller.posts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 10),
        children: [
          EmptyState(
            illustration: AppIllustration.chooseCity,
            title: 'No finder posts yet',
            message:
                'Tell a city what you are looking for and people with rooms '
                'can find you.',
            actionLabel: 'Create a finder post',
            onAction: controller.createFinderPost,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      itemCount: controller.posts.length,
      itemBuilder: (context, i) {
        final post = controller.posts[i];
        return EntryAnimation(
          index: i,
          child: FinderPostCard(
            post: post,
            showStatus: true,
            onTap: () => controller.openPost(post),
          ),
        );
      },
    );
  }
}

/// A draft listing needs photos before it will appear in search — say exactly
/// how many are missing rather than just badging it "Draft".
class _DraftHint extends StatelessWidget {
  const _DraftHint({required this.listing});

  final TenantListingModel listing;

  @override
  Widget build(BuildContext context) {
    if (listing.status != ListingStatus.draft) return const SizedBox.shrink();

    final missing = Env.minPhotosToPublish - listing.photos.length;
    if (missing <= 0) return const SizedBox.shrink();

    return Pill(
      label: '$missing more photo${missing == 1 ? '' : 's'}',
      icon: Icons.add_a_photo_rounded,
      tone: PillTone.amber,
      dense: true,
    );
  }
}
