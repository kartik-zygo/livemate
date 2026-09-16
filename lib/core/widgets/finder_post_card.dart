import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/enums.dart';
import '../../data/models/finder_post_model.dart';
import '../utils/enum_meta.dart';
import '../utils/formatters.dart';
import 'avatar.dart';
import 'glass_card.dart';
import 'pills.dart';

/// A person looking for a room. Finder posts have no photos, so the card leads
/// with the budget range and the lifestyle tags instead of a cover image.
class FinderPostCard extends StatelessWidget {
  const FinderPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.showStatus = false,
  });

  final FinderPostModel post;
  final VoidCallback? onTap;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final city = post.city?.displayName ?? 'City not set';

    return GlassCard(
      onTap: onTap,
      radius: AppTheme.radiusLg,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      semanticLabel:
          'Looking for a room in $city, budget '
          '${Fmt.moneyRange(post.budgetMin, post.budgetMax)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.travel_explore_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Looking in ${post.city?.name ?? 'a city'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (showStatus) StatusPill.finder(post.status),
            ],
          ),
          if ((post.note ?? '').isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              post.note!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body,
            ),
          ],
          const SizedBox(height: 13),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Pill(
                label: post.genderPreference.label,
                icon: post.genderPreference.icon,
                tone: PillTone.neutral,
                dense: true,
              ),
              if (post.hasAgeRange)
                Pill(
                  label: Fmt.ageRange(post.ageMin, post.ageMax),
                  icon: Icons.cake_rounded,
                  tone: PillTone.neutral,
                  dense: true,
                ),
              ...post.tags
                  .take(2)
                  .map(
                    (t) => Pill(
                      label: t.label,
                      icon: t.category.icon,
                      tone: PillTone.accent,
                      dense: true,
                    ),
                  ),
              if (post.tags.length > 2)
                Pill(
                  label: '+${post.tags.length - 2}',
                  tone: PillTone.neutral,
                  dense: true,
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      Fmt.moneyRange(post.budgetMin, post.budgetMax),
                      style: AppTextStyles.price.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              if (post.tier == PostTier.managed)
                Pill(
                  label: 'Managed',
                  icon: post.tier.icon,
                  tone: PillTone.brand,
                  dense: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A compact person block used on the finder post detail screen.
class FinderPostAuthor extends StatelessWidget {
  const FinderPostAuthor({super.key, required this.name, this.subtitle});

  final String name;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => PersonTile(
    name: name,
    initials: name.isEmpty ? '?' : name[0].toUpperCase(),
    subtitle: subtitle,
    seed: name,
  );
}
