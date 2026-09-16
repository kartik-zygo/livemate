import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/listing_card.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/saved_controller.dart';

class SavedView extends GetView<SavedController> {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
          child: Obx(
            () => Text(
              controller.listings.isEmpty
                  ? 'Rooms you save show up here.'
                  : '${Fmt.plural(controller.listings.length, 'room', 'rooms')} saved.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.inkTertiary,
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.reload,
            color: AppColors.brand600,
            backgroundColor: Colors.white,
            child: Obx(() {
              if (controller.status.value.isLoading &&
                  controller.listings.isEmpty) {
                return const SkeletonList(count: 3);
              }

              if (controller.status.value.isError) {
                return ListView(
                  padding: const EdgeInsets.only(top: 30),
                  children: [
                    ErrorState(
                      message:
                          controller.error.value ??
                          'Could not load your shortlist.',
                      onRetry: controller.load,
                    ),
                  ],
                );
              }

              if (controller.listings.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    EmptyState(
                      illustration: AppIllustration.saved,
                      title: 'Nothing saved yet',
                      message:
                          'Tap the heart on any room to keep it here '
                          'while you compare.',
                      actionLabel: 'Browse rooms',
                      onAction: () => Get.find<DashboardController>().goTo(
                        DashboardSection.discover,
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
                itemCount: controller.listings.length,
                itemBuilder: (context, i) {
                  final listing = controller.listings[i];
                  return EntryAnimation(
                    index: i,
                    child: ListingCard(
                      listing: listing,
                      onTap: () => controller.openListing(listing),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
