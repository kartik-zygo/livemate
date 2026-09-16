import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/enum_meta.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/pills.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/tenant_listing_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/listing_detail_controller.dart';
import '../widgets/enquiry_sheet.dart';
import '../widgets/photo_gallery.dart';

class ListingDetailView extends GetView<ListingDetailController> {
  const ListingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: Obx(() {
        if (controller.status.value.isLoading) return const _DetailSkeleton();

        if (controller.status.value.isError) {
          return AmbientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _BackBar(title: 'Listing'),
                  Expanded(
                    child: ErrorState(
                      message:
                          controller.error.value ?? 'Could not load listing.',
                      onRetry: controller.load,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final listing = controller.listing.value;
        if (listing == null) return const SizedBox.shrink();

        return _Content(listing: listing, controller: controller);
      }),
      bottomNavigationBar: Obx(() {
        final listing = controller.listing.value;
        if (listing == null) return const SizedBox.shrink();
        return _ActionBar(listing: listing, controller: controller);
      }),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.listing, required this.controller});

  final TenantListingModel listing;
  final ListingDetailController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Obx(
                () => PhotoGallery(
                  photos: listing.photos,
                  index: controller.photoIndex.value,
                  onIndexChanged: controller.setPhotoIndex,
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    GalleryActionButton(
                      icon: Icons.arrow_back_rounded,
                      semanticLabel: 'Back',
                      onPressed: Get.back<void>,
                    ),
                    const Spacer(),
                    if (controller.isOwner) ...[
                      GalleryActionButton(
                        icon: Icons.edit_rounded,
                        semanticLabel: 'Edit this listing',
                        onPressed: controller.editListing,
                      ),
                      const SizedBox(width: 8),
                      GalleryActionButton(
                        icon: Icons.delete_outline_rounded,
                        semanticLabel: 'Delete this listing',
                        onPressed: controller.deleteListing,
                      ),
                    ] else
                      Obx(
                        () => GalleryActionButton(
                          icon: controller.isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: controller.isSaved
                              ? AppColors.rose400
                              : Colors.white,
                          semanticLabel: controller.isSaved
                              ? 'Remove from shortlist'
                              : 'Save to shortlist',
                          onPressed: controller.toggleSave,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -26),
            child: AmbientBackground(
              intensity: 0.6,
              seed: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: Container(
                    color: AppColors.ground.withValues(alpha: 0.72),
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Headline(listing: listing),
                        const SizedBox(height: 20),
                        EntryAnimation(
                          index: 1,
                          child: _Facts(listing: listing),
                        ),
                        const SizedBox(height: 22),
                        EntryAnimation(
                          index: 2,
                          child: _About(listing: listing),
                        ),
                        if (listing.amenities.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          EntryAnimation(
                            index: 3,
                            child: _Amenities(listing: listing),
                          ),
                        ],
                        const SizedBox(height: 22),
                        EntryAnimation(
                          index: 4,
                          child: _Owner(listing: listing),
                        ),
                        const SizedBox(height: 22),
                        EntryAnimation(index: 5, child: const _PrivacyGate()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.listing});

  final TenantListingModel listing;

  @override
  Widget build(BuildContext context) {
    return EntryAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (listing.isAvailableNow)
                const Pill(
                  label: 'Available now',
                  icon: Icons.check_circle_rounded,
                  tone: PillTone.accent,
                )
              else
                Pill(
                  label: Fmt.availability(listing.availableFrom),
                  icon: Icons.event_rounded,
                  tone: PillTone.amber,
                ),
              const SizedBox(width: 8),
              if (listing.status != ListingStatus.active)
                StatusPill.listing(listing.status),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            listing.title,
            style: AppTextStyles.display.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: AppColors.inkTertiary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  listing.city?.displayName ?? 'City not set',
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // The price is the one thing that must never be clipped, so it takes
          // the room it needs and the deposit gives way — at a large text
          // scale a fixed Row here ran straight off the card.
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  Fmt.money(listing.budget),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.price.copyWith(fontSize: 28),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'per month',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),
              ),
              if (listing.depositAmount != null) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Deposit', style: AppTextStyles.caption),
                      Text(
                        Fmt.money(listing.depositAmount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.listing});

  final TenantListingModel listing;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];

    final room = listing.roomType;
    if (room != null) {
      tiles.add(FactTile(icon: room.icon, label: 'Room', value: room.label));
    }
    final property = listing.propertyType;
    if (property != null) {
      tiles.add(
        FactTile(icon: property.icon, label: 'Property', value: property.label),
      );
    }
    final furnishing = listing.furnishing;
    if (furnishing != null) {
      tiles.add(
        FactTile(
          icon: furnishing.icon,
          label: 'Furnishing',
          value: furnishing.label,
        ),
      );
    }
    if (listing.bedrooms != null) {
      tiles.add(
        FactTile(
          icon: Icons.king_bed_rounded,
          label: 'Bedrooms',
          value: '${listing.bedrooms}',
        ),
      );
    }
    if (listing.bathrooms != null) {
      tiles.add(
        FactTile(
          icon: Icons.bathtub_rounded,
          label: 'Bathrooms',
          value: '${listing.bathrooms}',
        ),
      );
    }
    if (listing.maxOccupants != null) {
      tiles.add(
        FactTile(
          icon: Icons.groups_rounded,
          label: 'Max occupants',
          value: '${listing.maxOccupants}',
        ),
      );
    }
    tiles.add(
      FactTile(
        icon: listing.openTo.icon,
        label: 'Open to',
        value: listing.openTo.label,
      ),
    );

    if (tiles.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 11) / 2;
        return Wrap(
          spacing: 11,
          runSpacing: 11,
          children: tiles
              .map((t) => SizedBox(width: width, child: t))
              .toList(growable: false),
        );
      },
    );
  }
}

class _About extends StatelessWidget {
  const _About({required this.listing});

  final TenantListingModel listing;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('About this place', style: AppTextStyles.h3),
      const SizedBox(height: 10),
      Text(
        listing.description,
        style: AppTextStyles.bodyLarge.copyWith(height: 1.62),
      ),
    ],
  );
}

class _Amenities extends StatelessWidget {
  const _Amenities({required this.listing});

  final TenantListingModel listing;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('What is included', style: AppTextStyles.h3),
      const SizedBox(height: 12),
      Wrap(
        spacing: 9,
        runSpacing: 9,
        children: listing.amenities
            .map(
              (a) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(a.icon, size: 17, color: AppColors.accent600),
                    const SizedBox(width: 8),
                    Text(a.label, style: AppTextStyles.label),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    ],
  );
}

class _Owner extends StatelessWidget {
  const _Owner({required this.listing});

  final TenantListingModel listing;

  @override
  Widget build(BuildContext context) {
    final owner = listing.owner;
    if (owner == null) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Listed by', style: AppTextStyles.h3),
          const SizedBox(height: 14),
          PersonTile(
            name: owner.fullName,
            initials: owner.initials,
            seed: owner.id,
            subtitle: owner.occupation,
            size: 52,
          ),
          if ((owner.bio ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(owner.bio!, style: AppTextStyles.body),
          ],
          if (listing.enquiryCount != null && listing.enquiryCount! > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 16,
                  color: AppColors.brand600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${Fmt.plural(listing.enquiryCount!, 'person has', 'people have')} '
                    'enquired about this room',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PrivacyGate extends StatelessWidget {
  const _PrivacyGate();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.accent100.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TintedIcon(
          icon: Icons.verified_user_rounded,
          color: AppColors.accent700,
          size: 40,
          iconSize: 19,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact details are protected',
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.accent700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Send an enquiry first. Phone numbers and emails are exchanged '
                'only once the owner accepts.',
                style: AppTextStyles.caption.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.listing, required this.controller});

  final TenantListingModel listing;
  final ListingDetailController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isOwner) {
      return StickyActionBar(
        child: Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Edit listing',
                icon: Icons.edit_rounded,
                onPressed: controller.editListing,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                label: 'View enquiries',
                icon: Icons.forum_rounded,
                onPressed: () {
                  Get.until((route) => route.isFirst);
                  Get.find<DashboardController>().goTo(
                    DashboardSection.enquiries,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    if (!controller.canEnquire) {
      return StickyActionBar(
        child: AppButton.secondary(
          label: 'This listing is not accepting enquiries',
          icon: Icons.lock_rounded,
          onPressed: null,
        ),
      );
    }

    return StickyActionBar(
      child: Row(
        children: [
          Obx(
            () => AppIconButton(
              icon: controller.isSaved
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: controller.isSaved
                  ? AppColors.rose500
                  : AppColors.inkSecondary,
              size: 52,
              iconSize: 22,
              semanticLabel: controller.isSaved
                  ? 'Remove from shortlist'
                  : 'Save to shortlist',
              onPressed: controller.toggleSave,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(
              () => AppButton(
                label: controller.enquirySent.value
                    ? 'Enquiry sent — send again'
                    : 'Send enquiry',
                icon: controller.enquirySent.value
                    ? Icons.check_rounded
                    : Icons.send_rounded,
                loading: controller.sendingEnquiry.value,
                onPressed: () => _openEnquirySheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEnquirySheet(BuildContext context) async {
    final sent = await EnquirySheet.show(
      context,
      listingTitle: listing.title,
      onSend: controller.sendEnquiry,
    );

    if (sent == true && context.mounted) {
      await EnquirySentSheet.show(
        context,
        onDone: () {
          Navigator.of(context).pop();
          Get.until((route) => route.isFirst);
          Get.find<DashboardController>().goTo(DashboardSection.enquiries);
        },
      );
    }
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(6, 6, 18, 0),
    child: Row(
      children: [
        IconButton(
          onPressed: Get.back<void>,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        Text(title, style: AppTextStyles.h3),
      ],
    ),
  );
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(width: double.infinity, height: 320, radius: 0),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 120, height: 24, radius: 12),
              SizedBox(height: 16),
              SkeletonBox(width: 250, height: 24),
              SizedBox(height: 12),
              SkeletonBox(width: 160, height: 14),
              SizedBox(height: 24),
              SkeletonBox(width: 140, height: 28),
              SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: SkeletonBox(height: 56, radius: 14)),
                  SizedBox(width: 11),
                  Expanded(child: SkeletonBox(height: 56, radius: 14)),
                ],
              ),
              SizedBox(height: 11),
              Row(
                children: [
                  Expanded(child: SkeletonBox(height: 56, radius: 14)),
                  SizedBox(width: 11),
                  Expanded(child: SkeletonBox(height: 56, radius: 14)),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
