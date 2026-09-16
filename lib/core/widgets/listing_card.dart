import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/tenant_listing_model.dart';
import '../services/shortlist_service.dart';
import '../utils/enum_meta.dart';
import '../utils/formatters.dart';
import 'app_feedback.dart';
import 'glass_card.dart';
import 'pills.dart';
import 'remote_image.dart';

/// The listing card used across Discover, Search and Saved.
///
/// There is no distance anywhere in this product, so the card leads with the
/// city and the price instead of a "…km away" line.
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.showSaveButton = true,
    this.showStatus = false,
    this.trailing,
  });

  final TenantListingModel listing;
  final VoidCallback? onTap;
  final bool showSaveButton;

  /// Owners need to see DRAFT / RENTED on their own listings; browsers only
  /// ever see ACTIVE ones, so the badge would be noise there.
  final bool showStatus;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cityLabel = listing.city?.displayName ?? 'City not set';

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 16),
      semanticLabel:
          '${listing.title}, ${Fmt.money(listing.budget)} per month in '
          '$cityLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Cover(
            listing: listing,
            showSaveButton: showSaveButton,
            showStatus: showStatus,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h3.copyWith(height: 1.28),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 10),
                      trailing!,
                    ],
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.inkTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        cityLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                _Attributes(listing: listing),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.line),
                const SizedBox(height: 13),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              Fmt.money(listing.budget),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.price,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text('/mo', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Pill(
                        label: listing.openTo.openToLabel,
                        icon: listing.openTo.icon,
                        tone: PillTone.neutral,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({
    required this.listing,
    required this.showSaveButton,
    required this.showStatus,
  });

  final TenantListingModel listing;
  final bool showSaveButton;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteImage(url: listing.coverPhoto?.url),
          // A bottom scrim so white chips stay legible over any photo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Color(0x59000000), Colors.transparent],
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            right: 60,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (listing.isAvailableNow)
                  const _GlassChip(
                    label: 'Available now',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.accent700,
                  )
                else
                  _GlassChip(
                    label: Fmt.availability(listing.availableFrom),
                    icon: Icons.event_rounded,
                    color: AppColors.amber700,
                  ),
                if (listing.photos.length > 1)
                  _GlassChip(
                    label: '${listing.photos.length}',
                    icon: Icons.photo_library_rounded,
                    color: AppColors.inkSecondary,
                  ),
              ],
            ),
          ),
          if (showStatus)
            Positioned(
              left: 12,
              top: 12,
              child: StatusPill.listing(listing.status),
            ),
          if (showSaveButton)
            Positioned(
              right: 10,
              top: 10,
              child: SaveHeartButton(listingId: listing.id),
            ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => GlassSurface(
    radius: 10,
    blurSigma: Glass.blurChip,
    specular: false,
    shadows: const [],
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
          ),
        ),
      ],
    ),
  );
}

class _Attributes extends StatelessWidget {
  const _Attributes({required this.listing});

  final TenantListingModel listing;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    final room = listing.roomType;
    if (room != null) {
      chips.add(Pill(label: room.label, icon: room.icon, dense: true));
    }
    final property = listing.propertyType;
    if (property != null) {
      chips.add(Pill(label: property.label, icon: property.icon, dense: true));
    }
    final bedrooms = listing.bedrooms;
    if (bedrooms != null) {
      chips.add(
        Pill(
          label: Fmt.plural(bedrooms, 'bed', 'beds'),
          icon: Icons.king_bed_rounded,
          dense: true,
        ),
      );
    }
    final furnishing = listing.furnishing;
    if (furnishing != null && chips.length < 3) {
      chips.add(
        Pill(label: furnishing.label, icon: furnishing.icon, dense: true),
      );
    }

    if (chips.isEmpty) {
      return Text(
        listing.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.body,
      );
    }

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: chips.take(3).toList(growable: false),
    );
  }
}

/// The heart. Reads and writes [ShortlistService], so every instance of a
/// listing across the app flips together.
class SaveHeartButton extends StatelessWidget {
  const SaveHeartButton({super.key, required this.listingId, this.size = 38});

  final String listingId;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShortlistService>()) return const SizedBox.shrink();
    final shortlist = Get.find<ShortlistService>();

    return Obx(() {
      final saved = shortlist.isSaved(listingId);
      return Semantics(
        button: true,
        label: saved ? 'Remove from shortlist' : 'Save to shortlist',
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: GlassTapTarget(
              scale: 0.86,
              onTap: () async {
                try {
                  await shortlist.toggle(listingId);
                } catch (_) {
                  AppFeedback.error('Could not update your shortlist.');
                }
              },
              child: GlassSurface(
                radius: size / 2,
                blurSigma: Glass.blurChip,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      saved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(saved),
                      size: 20,
                      color: saved ? AppColors.rose500 : AppColors.inkSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// A denser listing row for the Saved tab and owner lists.
class ListingRow extends StatelessWidget {
  const ListingRow({
    super.key,
    required this.listing,
    this.onTap,
    this.showStatus = false,
    this.trailing,
  });

  final TenantListingModel listing;
  final VoidCallback? onTap;
  final bool showStatus;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      radius: AppTheme.radiusMd,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RemoteImage(
            url: listing.coverPhoto?.url,
            width: 84,
            height: 84,
            radius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong.copyWith(fontSize: 14.5),
                ),
                const SizedBox(height: 5),
                Text(
                  listing.city?.displayName ?? 'City not set',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Text(
                      Fmt.money(listing.budget),
                      style: AppTextStyles.price.copyWith(fontSize: 15),
                    ),
                    Text('/mo', style: AppTextStyles.caption),
                    const Spacer(),
                    if (showStatus) StatusPill.listing(listing.status),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
