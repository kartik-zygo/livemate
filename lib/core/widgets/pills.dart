import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/enums.dart';
import 'glass.dart';

/// A small tinted label. [tone] picks the colour role.
enum PillTone { neutral, brand, accent, rose, amber }

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.tone = PillTone.neutral,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final PillTone tone;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (tone) {
      PillTone.brand => (AppColors.brand700, AppColors.brand100),
      PillTone.accent => (AppColors.accent700, AppColors.accent100),
      PillTone.rose => (AppColors.rose600, const Color(0xFFFFE4E6)),
      PillTone.amber => (AppColors.amber700, const Color(0xFFFEF3C7)),
      PillTone.neutral => (AppColors.inkSecondary, AppColors.surfaceMuted),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: dense ? 10.5 : 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The status of a listing, finder post or enquiry, coloured by meaning rather
/// than by a generic palette ramp.
class StatusPill extends StatelessWidget {
  const StatusPill.listing(ListingStatus status, {super.key})
    : label = null,
      _listing = status,
      _enquiry = null,
      _finder = null;

  const StatusPill.enquiry(EnquiryStatus status, {super.key})
    : label = null,
      _listing = null,
      _enquiry = status,
      _finder = null;

  const StatusPill.finder(FinderPostStatus status, {super.key})
    : label = null,
      _listing = null,
      _enquiry = null,
      _finder = status;

  final String? label;
  final ListingStatus? _listing;
  final EnquiryStatus? _enquiry;
  final FinderPostStatus? _finder;

  @override
  Widget build(BuildContext context) {
    final (text, tone, icon) = _resolve();
    return Pill(label: text, tone: tone, icon: icon, dense: true);
  }

  (String, PillTone, IconData) _resolve() {
    if (_listing != null) {
      return switch (_listing) {
        ListingStatus.active => ('Live', PillTone.accent, Icons.bolt_rounded),
        ListingStatus.draft => (
          'Draft',
          PillTone.amber,
          Icons.edit_note_rounded,
        ),
        ListingStatus.rented => (
          'Rented',
          PillTone.neutral,
          Icons.done_all_rounded,
        ),
        ListingStatus.inactive => (
          'Paused',
          PillTone.neutral,
          Icons.pause_rounded,
        ),
      };
    }
    if (_enquiry != null) {
      return switch (_enquiry) {
        EnquiryStatus.pending => (
          'Pending',
          PillTone.amber,
          Icons.schedule_rounded,
        ),
        EnquiryStatus.accepted => (
          'Accepted',
          PillTone.accent,
          Icons.check_circle_rounded,
        ),
        EnquiryStatus.declined => (
          'Declined',
          PillTone.rose,
          Icons.cancel_rounded,
        ),
      };
    }
    return switch (_finder!) {
      FinderPostStatus.active => ('Live', PillTone.accent, Icons.bolt_rounded),
      FinderPostStatus.draft => (
        'Draft',
        PillTone.amber,
        Icons.edit_note_rounded,
      ),
      FinderPostStatus.paused => (
        'Paused',
        PillTone.neutral,
        Icons.pause_rounded,
      ),
      FinderPostStatus.closed => (
        'Closed',
        PillTone.neutral,
        Icons.lock_rounded,
      ),
      FinderPostStatus.expired => (
        'Expired',
        PillTone.rose,
        Icons.event_busy_rounded,
      ),
    };
  }
}

/// A selectable filter chip used across filters, amenities and tags.
class SelectChip extends StatelessWidget {
  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 44),
            child: GlassSurface(
              radius: 13,
              blurSigma: Glass.blurChip,
              specular: false,
              tint: selected ? AppColors.brand500 : null,
              tintStrength: 0.2,
              rimColor: selected ? AppColors.brand500 : null,
              rimWidth: selected ? 1.5 : 1,
              shadows: const [],
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16,
                      color: selected
                          ? AppColors.brand700
                          : AppColors.inkTertiary,
                    ),
                    const SizedBox(width: 7),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      color: selected
                          ? AppColors.brand700
                          : AppColors.inkSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: AppColors.brand700,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
