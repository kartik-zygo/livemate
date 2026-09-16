import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// Wraps children in the app's warm shimmer. Skeletons are always shaped like
/// the real card they replace — never a bare spinner.
class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.shimmerBase,
    highlightColor: AppColors.shimmerHighlight,
    period: const Duration(milliseconds: 1400),
    child: child,
  );
}

/// A single grey block. Only meaningful inside a [SkeletonShimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 8,
    this.margin,
  });

  const SkeletonBox.circle({super.key, required double size, this.margin})
    : width = size,
      height = size,
      radius = size / 2;

  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    margin: margin,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Placeholder shaped like a listing card in the discover/search feed.
class ListingCardSkeleton extends StatelessWidget {
  const ListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 176, radius: AppTheme.radiusLg),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 210, height: 15),
                SizedBox(height: 10),
                SkeletonBox(width: 130, height: 12),
                SizedBox(height: 16),
                Row(
                  children: [
                    SkeletonBox(width: 68, height: 24, radius: 12),
                    SizedBox(width: 8),
                    SkeletonBox(width: 78, height: 24, radius: 12),
                    Spacer(),
                    SkeletonBox(width: 74, height: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Placeholder for a compact row — enquiries, finder posts, saved items.
class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key, this.hasThumbnail = true});

  final bool hasThumbnail;

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasThumbnail) ...[
            const SkeletonBox(width: 74, height: 74, radius: 14),
            const SizedBox(width: 14),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 14),
                SizedBox(height: 9),
                SkeletonBox(width: 110, height: 11),
                SizedBox(height: 14),
                SkeletonBox(width: 90, height: 22, radius: 11),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// A shimmering list of [count] skeletons, used while a feed loads.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 4,
    this.builder,
    this.padding = const EdgeInsets.fromLTRB(18, 4, 18, 24),
  });

  final int count;
  final Widget Function(int index)? builder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: padding,
    physics: const NeverScrollableScrollPhysics(),
    // Sizes to its rows rather than to the viewport, so the same widget works
    // both as the body of a bounded Expanded and inside a SliverToBoxAdapter,
    // where an unshrunk vertical ListView would be handed unbounded height and
    // assert. There are only ever a handful of rows, so it costs nothing.
    shrinkWrap: true,
    itemCount: count,
    itemBuilder: (context, i) =>
        builder?.call(i) ?? const ListingCardSkeleton(),
  );
}
