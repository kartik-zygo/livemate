import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/city_picker_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/finder_post_card.dart';
import '../../../core/widgets/listing_card.dart';
import '../../../core/widgets/pills.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../data/models/enums.dart';
import '../controllers/listing_search_controller.dart';
import '../widgets/filter_sheet.dart';

class SearchView extends GetView<ListingSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchHeader(controller: controller),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.reload,
            color: AppColors.brand600,
            backgroundColor: Colors.white,
            child: Obx(() => _buildResults(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context) {
    if (!controller.hasCity) {
      return ChooseCityPrompt(
        onChoose: () => _pickCity(context),
        title: 'Pick a city to search',
        message:
            'MyFlat Homes matches city to city. Choose one and every filter '
            'below narrows within it.',
      );
    }

    if (controller.status.value.isLoading) {
      return SkeletonList(
        count: 3,
        builder: controller.mode.value == SearchMode.people
            ? (_) => const ListRowSkeleton(hasThumbnail: false)
            : null,
      );
    }

    if (controller.status.value.isError) {
      return ListView(
        padding: const EdgeInsets.only(top: 40),
        children: [
          ErrorState(
            message: controller.error.value ?? 'Search failed.',
            onRetry: controller.run,
          ),
        ],
      );
    }

    final isRooms = controller.mode.value == SearchMode.rooms;
    final count = isRooms
        ? controller.listings.length
        : controller.posts.length;

    if (count == 0) {
      return ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          EmptyState(
            illustration: isRooms
                ? AppIllustration.search
                : AppIllustration.enquiries,
            title: isRooms
                ? 'No rooms match these filters'
                : 'Nobody is looking here with these filters',
            message: controller.activeFilterCount > 0
                ? 'Try loosening a filter — or search a different city.'
                : 'Nothing is live in ${controller.city?.name ?? 'this city'} '
                      'right now. Try another city.',
            actionLabel: controller.activeFilterCount > 0
                ? 'Clear filters'
                : 'Change city',
            onAction: controller.activeFilterCount > 0
                ? controller.clearFilters
                : () => _pickCity(context),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        18,
        14,
        18,
        MediaQuery.paddingOf(context).bottom + 32,
      ),
      itemCount: count + (controller.hitResultCap ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == count) return const _CapNote();

        if (isRooms) {
          final listing = controller.listings[i];
          return EntryAnimation(
            index: i,
            child: ListingCard(
              listing: listing,
              onTap: () => controller.openListing(listing),
            ),
          );
        }

        final post = controller.posts[i];
        return EntryAnimation(
          index: i,
          child: FinderPostCard(
            post: post,
            onTap: () => controller.openPost(post),
          ),
        );
      },
    );
  }

  Future<void> _pickCity(BuildContext context) async {
    final picked = await CityPickerSheet.show(
      context,
      selectedId: controller.city?.id,
    );
    if (picked != null) await controller.setCity(picked);
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.controller});

  final ListingSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => _ModeToggle(
              mode: controller.mode.value,
              onChanged: controller.switchMode,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _FilterButton(controller: controller),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  if (controller.mode.value != SearchMode.rooms ||
                      !controller.hasCity) {
                    return const SizedBox(height: 44);
                  }
                  return SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ListingSort.values
                          .map(
                            (sort) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _SortChip(
                                label: sort.label,
                                selected:
                                    controller.listingFilters.value.sort ==
                                    sort,
                                onTap: () => controller.setSort(sort),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final SearchMode mode;
  final ValueChanged<SearchMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: GlassSurface(
        radius: 16,
        blurSigma: Glass.blurChip,
        specular: false,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _ModeTab(
              label: 'Rooms',
              icon: Icons.meeting_room_rounded,
              selected: mode == SearchMode.rooms,
              onTap: () => onChanged(SearchMode.rooms),
            ),
            _ModeTab(
              label: 'People',
              icon: Icons.person_search_rounded,
              selected: mode == SearchMode.people,
              onTap: () => onChanged(SearchMode.people),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.inkTertiary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: selected ? Colors.white : AppColors.inkSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.controller});

  final ListingSearchController controller;

  Future<void> _open(BuildContext context) async {
    if (controller.mode.value == SearchMode.rooms) {
      final result = await ListingFilterSheet.show(
        context,
        controller.listingFilters.value,
      );
      if (result != null) controller.applyListingFilters(result);
    } else {
      final result = await FinderFilterSheet.show(
        context,
        controller.finderFilters.value,
      );
      if (result != null) controller.applyFinderFilters(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.activeFilterCount;
      return GlassPill(
        onTap: controller.hasCity ? () => _open(context) : null,
        semanticLabel: count > 0 ? 'Filters, $count active' : 'Filters',
        selected: count > 0,
        tint: count > 0 ? AppColors.brand500 : null,
        tintStrength: 0.2,
        rimColor: count > 0 ? AppColors.brand500 : null,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: count > 0 ? AppColors.brand700 : AppColors.inkSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              count > 0 ? 'Filters · $count' : 'Filters',
              style: AppTextStyles.label.copyWith(
                color: count > 0 ? AppColors.brand700 : AppColors.inkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      SelectChip(label: label, selected: selected, onTap: onTap);
}

/// Search is capped at 50 rows with no pagination — say so instead of letting
/// the user scroll waiting for more.
class _CapNote extends StatelessWidget {
  const _CapNote();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 18),
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
            'That is the first 50 results. Narrow your filters to see the rest.',
            style: AppTextStyles.caption,
          ),
        ),
      ],
    ),
  );
}
