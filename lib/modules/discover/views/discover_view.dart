import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/city_picker_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/listing_card.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../data/models/enums.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/discover_controller.dart';
import '../widgets/finder_strip.dart';

/// The city feed. Lives inside the dashboard shell, which supplies the ambient
/// field, the title and the city control — so this section is only ever the
/// results themselves.
class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return RefreshIndicator(
      onRefresh: controller.reload,
      color: AppColors.brand600,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(controller: controller)),
          ..._buildBody(context),
          SliverToBoxAdapter(child: SizedBox(height: bottomInset + 28)),
        ],
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    return [
      Obx(() {
        if (!controller.hasCity) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: ChooseCityPrompt(onChoose: () => _pickCity(context)),
          );
        }

        if (controller.status.value.isLoading && controller.listings.isEmpty) {
          return const SliverToBoxAdapter(child: SkeletonList(count: 3));
        }

        if (controller.status.value.isError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorState(
              message: controller.error.value ?? 'Could not load listings.',
              onRetry: controller.load,
            ),
          );
        }

        if (controller.listings.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              illustration: AppIllustration.listings,
              title: 'No rooms listed here yet',
              message:
                  'Nobody has posted a room in '
                  '${controller.city.value?.name ?? 'this city'} yet. Try '
                  'another city, or be the first to list one.',
              actionLabel: 'Try another city',
              onAction: () => _pickCity(context),
              secondaryLabel: 'List a room',
              onSecondary: Get.find<DashboardController>().createListing,
            ),
          );
        }

        return SliverList.builder(
          itemCount: controller.listings.length,
          itemBuilder: (context, i) {
            final listing = controller.listings[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EntryAnimation(
                index: i,
                child: ListingCard(
                  listing: listing,
                  onTap: () => controller.openListing(listing),
                ),
              ),
            );
          },
        );
      }),
      Obx(
        () => controller.hitResultCap
            ? const SliverToBoxAdapter(child: _ResultCapNote())
            : const SliverToBoxAdapter(child: SizedBox.shrink()),
      ),
    ];
  }

  Future<void> _pickCity(BuildContext context) async {
    final picked = await CityPickerSheet.show(
      context,
      selectedId: controller.city.value?.id,
    );
    if (picked != null) await controller.setCity(picked);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final DiscoverController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (!controller.hasCity) return const SizedBox.shrink();
            final count = controller.listings.length;

            return Row(
              children: [
                Expanded(
                  child: Text(
                    'Newest in ${controller.city.value?.name ?? 'your city'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                  ),
                ),
                if (count > 0)
                  Text(
                    count >= 50
                        ? '50+ rooms'
                        : Fmt.plural(count, 'room', 'rooms'),
                    style: AppTextStyles.caption,
                  ),
              ],
            );
          }),
          Obx(
            () => controller.finderPosts.isEmpty
                ? const SizedBox(height: 14)
                : FinderStrip(
                    posts: controller.finderPosts,
                    cityName: controller.city.value?.name ?? '',
                    onTap: controller.openFinderPost,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Search returns at most 50 rows and there is no pagination, so the feed says
/// so rather than pretending more will arrive on scroll.
class _ResultCapNote extends StatelessWidget {
  const _ResultCapNote();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: GlassSurface(
      radius: 18,
      blurSigma: Glass.blurChip,
      specular: false,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          const TintedIcon(
            icon: Icons.filter_alt_rounded,
            size: 34,
            iconSize: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Showing the first 50 rooms. Use Search to narrow by budget, '
              'room type or amenities.',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    ),
  );
}
