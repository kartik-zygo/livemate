import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/city_picker_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/remote_image.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/tenant_listing_model.dart';
import '../../discover/controllers/discover_controller.dart';
import '../../discover/widgets/finder_strip.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/dashboard_controller.dart';

/// Home: the section that exists because the app no longer has a bottom bar.
///
/// It reads entirely from controllers the other sections already keep warm —
/// the discover feed, the shortlist, the enquiry badge, the profile — so
/// opening the dashboard costs no extra requests. Every tile is a way into a
/// section, which is what makes one page enough.
class DashboardOverview extends GetView<DashboardController> {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final discover = Get.find<DiscoverController>();

    return RefreshIndicator(
      onRefresh: discover.reload,
      color: AppColors.brand600,
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          EntryAnimation(child: _Hero(discover: discover)),
          const SizedBox(height: 14),
          EntryAnimation(index: 1, child: _StatRow(discover: discover)),
          const SizedBox(height: 14),
          const EntryAnimation(index: 2, child: _CompletenessNudge()),
          EntryAnimation(
            index: 3,
            child: _QuickActions(controller: controller),
          ),
          const SizedBox(height: 22),
          EntryAnimation(index: 4, child: _FreshRooms(discover: discover)),
          const SizedBox(height: 22),
          EntryAnimation(index: 5, child: _PeopleLooking(discover: discover)),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.discover});

  final DiscoverController discover;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: 26,
      blurSigma: Glass.blurPanel,
      tint: AppColors.brand500,
      tintStrength: 0.1,
      elevation: 1,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FIND YOUR PLACE', style: AppTextStyles.eyebrow),
          const SizedBox(height: 9),
          Obx(() {
            final city = discover.city.value;
            return Text(
              city == null
                  ? 'Pick a city to get started'
                  : 'Rooms and flatmates in ${city.name}',
              style: AppTextStyles.display.copyWith(fontSize: 25, height: 1.18),
            );
          }),
          const SizedBox(height: 8),
          Text(
            'Everything lives on this one page — switch sections from the rail '
            'above, or open the menu for the full map.',
            style: AppTextStyles.body.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final city = discover.city.value;
            return GlassPill(
              onTap: () async {
                final picked = await CityPickerSheet.show(
                  context,
                  selectedId: city?.id,
                );
                if (picked != null) await discover.setCity(picked);
              },
              semanticLabel: city == null
                  ? 'Choose a city'
                  : 'Browsing in ${city.displayName}. Change city.',
              padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
              tint: city == null ? AppColors.brand500 : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 17,
                    color: AppColors.brand600,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      city?.displayName ?? 'Choose a city',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong.copyWith(fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.expand_more_rounded,
                    size: 17,
                    color: AppColors.inkTertiary,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Three counts, each a door into the section it counts.
class _StatRow extends GetView<DashboardController> {
  const _StatRow({required this.discover});

  final DiscoverController discover;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _StatTile(
              icon: Icons.explore_rounded,
              value: discover.listings.length >= 50
                  ? '50+'
                  : '${discover.listings.length}',
              label: 'Rooms here',
              tint: AppColors.brand500,
              onTap: () => controller.goTo(DashboardSection.discover),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: _StatTile(
              icon: Icons.favorite_rounded,
              value: '${controller.savedIds.length}',
              label: 'Shortlisted',
              tint: AppColors.rose500,
              onTap: () => controller.goTo(DashboardSection.saved),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: _StatTile(
              icon: Icons.forum_rounded,
              value: '${controller.pendingEnquiries.value}',
              label: 'To answer',
              tint: AppColors.accent500,
              onTap: () => controller.goTo(DashboardSection.enquiries),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$value $label',
      child: GlassTapTarget(
        onTap: onTap,
        child: GlassSurface(
          radius: 20,
          tint: tint,
          tintStrength: 0.12,
          padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 19, color: tint),
              const SizedBox(height: 11),
              Text(
                value,
                maxLines: 1,
                style: AppTextStyles.display.copyWith(
                  fontSize: 23,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The profile nudge only earns its place while the profile is incomplete —
/// owners read it before accepting an enquiry.
class _CompletenessNudge extends GetView<DashboardController> {
  const _CompletenessNudge();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) return const SizedBox.shrink();
    final profile = Get.find<ProfileController>();

    return Obx(() {
      final user = profile.user.value;
      if (user == null || user.completeness >= 1) {
        return const SizedBox.shrink();
      }

      final percent = (user.completeness * 100).round();

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GlassTapTarget(
          onTap: controller.editProfile,
          child: GlassSurface(
            radius: 20,
            tint: AppColors.amber500,
            tintStrength: 0.16,
            rimColor: AppColors.brand200,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 19,
                      color: AppColors.amber700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your profile is $percent% complete',
                        style: AppTextStyles.bodyStrong.copyWith(
                          color: AppColors.brand700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.brand700,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Owners see this before they accept an enquiry.',
                  style: AppTextStyles.caption.copyWith(height: 1.4),
                ),
                const SizedBox(height: 13),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: user.completeness,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.65),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.brand500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Jump in'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.add_home_work_rounded,
                title: 'List a room',
                note: 'Owners',
                gradient: AppColors.primaryGradient,
                tint: AppColors.brand500,
                onTap: controller.createListing,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _ActionTile(
                icon: Icons.person_search_rounded,
                title: 'Post that you are looking',
                note: 'Seekers',
                gradient: AppColors.accentGradient,
                tint: AppColors.accent500,
                onTap: controller.createFinderPost,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.tune_rounded,
                title: 'Search with filters',
                note: 'Rooms',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.violet400, Color(0xFF6D28D9)],
                ),
                tint: AppColors.violet400,
                onTap: () => controller.goTo(DashboardSection.search),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _ActionTile(
                icon: Icons.meeting_room_rounded,
                title: 'My listings',
                note: 'Yours',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.sky400, Color(0xFF0369A1)],
                ),
                tint: AppColors.sky400,
                onTap: controller.openMyListings,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.note,
    required this.gradient,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String note;
  final Gradient gradient;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $note',
      child: GlassTapTarget(
        onTap: onTap,
        child: GlassSurface(
          radius: 20,
          tint: tint,
          tintStrength: 0.11,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: tint.withValues(alpha: 0.34),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 19, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    note,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyStrong.copyWith(
                  fontSize: 13.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreshRooms extends GetView<DashboardController> {
  const _FreshRooms({required this.discover});

  final DiscoverController discover;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!discover.hasCity) return const SizedBox.shrink();

      if (discover.status.value.isLoading && discover.listings.isEmpty) {
        return const SizedBox(height: 210, child: SkeletonList(count: 1));
      }

      if (discover.listings.isEmpty) return const SizedBox.shrink();

      final rooms = discover.listings.take(6).toList(growable: false);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            'Fresh in ${discover.city.value?.name ?? 'your city'}',
            actionLabel: 'See all',
            onAction: () => controller.goTo(DashboardSection.discover),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 216,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: rooms.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _RoomMiniCard(
                listing: rooms[i],
                onTap: () => discover.openListing(rooms[i]),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _RoomMiniCard extends StatelessWidget {
  const _RoomMiniCard({required this.listing, required this.onTap});

  final TenantListingModel listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${listing.title}, ${Fmt.money(listing.budget)} per month in '
          '${listing.city?.displayName ?? 'this city'}',
      child: GlassTapTarget(
        onTap: onTap,
        child: SizedBox(
          width: 210,
          child: GlassSurface(
            radius: 20,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                  child: SizedBox(
                    height: 118,
                    width: double.infinity,
                    child: RemoteImage(url: listing.coverPhoto?.url),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong.copyWith(
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            Fmt.money(listing.budget),
                            style: AppTextStyles.price.copyWith(fontSize: 15),
                          ),
                          Text('/mo', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeopleLooking extends GetView<DashboardController> {
  const _PeopleLooking({required this.discover});

  final DiscoverController discover;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (discover.finderPosts.isEmpty) {
        if (!discover.hasCity) {
          return EmptyState(
            illustration: AppIllustration.chooseCity,
            compact: true,
            title: 'Choose a city to fill this in',
            message:
                'MyFlat Homes matches city to city, so everything here starts '
                'with one.',
          );
        }
        return const SizedBox.shrink();
      }

      final posts = discover.finderPosts.take(8).toList(growable: false);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            'People looking here',
            actionLabel: 'Find people',
            onAction: () => controller.goTo(DashboardSection.search),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 11),
              itemBuilder: (context, i) => FinderMiniCard(
                post: posts[i],
                onTap: () => discover.openFinderPost(posts[i]),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title, {this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
        ),
        if (actionLabel != null && onAction != null)
          GlassPill(
            onTap: onAction,
            semanticLabel: actionLabel,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 12,
                    color: AppColors.brand700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: AppColors.brand700,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
