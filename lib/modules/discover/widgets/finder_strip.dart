import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/enum_meta.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/finder_post_model.dart';

/// A horizontal strip of people currently looking for a room in this city.
///
/// Finder posts carry no photos, so they get a compact card that
/// leads with the budget range rather than competing with the listing feed.
class FinderStrip extends StatelessWidget {
  const FinderStrip({
    super.key,
    required this.posts,
    required this.cityName,
    required this.onTap,
  });

  final List<FinderPostModel> posts;
  final String cityName;
  final ValueChanged<FinderPostModel> onTap;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Row(
          children: [
            const Icon(
              Icons.travel_explore_rounded,
              size: 18,
              color: AppColors.accent600,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                cityName.isEmpty
                    ? 'People looking right now'
                    : 'Looking in $cityName',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
            ),
            Text(
              Fmt.plural(posts.length, 'person', 'people'),
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: 11),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: posts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 11),
            itemBuilder: (context, i) =>
                FinderMiniCard(post: posts[i], onTap: () => onTap(posts[i])),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Text(
              'Rooms available',
              style: AppTextStyles.h3.copyWith(fontSize: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lineStrong.withValues(alpha: 0.8),
                      AppColors.lineStrong.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// One person's finder post, sized for a horizontal strip. Public because the
/// dashboard's Home section shows the same strip without the surrounding
/// Discover chrome.
class FinderMiniCard extends StatelessWidget {
  const FinderMiniCard({super.key, required this.post, required this.onTap});

  final FinderPostModel post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          'Someone looking in ${post.city?.displayName ?? 'this city'} with a '
          'budget of ${Fmt.moneyRange(post.budgetMin, post.budgetMax)}',
      child: GlassTapTarget(
        onTap: onTap,
        child: SizedBox(
          width: 216,
          child: GlassSurface(
            radius: 20,
            tint: AppColors.accent500,
            tintStrength: 0.1,
            rimColor: AppColors.accent100,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4014B8A6),
                            blurRadius: 12,
                            offset: Offset(0, 5),
                            spreadRadius: -3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_search_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Fmt.moneyRange(post.budgetMin, post.budgetMax),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong.copyWith(
                          fontSize: 13.5,
                          color: AppColors.accent700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Expanded(
                  child: Text(
                    (post.note ?? '').isEmpty
                        ? 'Looking for a place in '
                              '${post.city?.name ?? 'this city'}.'
                        : post.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Pill(
                      label: post.genderPreference.label,
                      icon: post.genderPreference.icon,
                      dense: true,
                    ),
                    if (post.tags.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Pill(
                          label: post.tags.first.label,
                          tone: PillTone.accent,
                          dense: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
