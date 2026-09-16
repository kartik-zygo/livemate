import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'shimmer_skeleton.dart';

/// Listing photos come from `GET /media/photos/:id`, which is public and sends
/// a one-year immutable cache header — so this needs no auth header and the
/// disk cache never has to revalidate.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.radius,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final image = (url == null || url!.isEmpty)
        ? const _PhotoPlaceholder()
        : CachedNetworkImage(
            imageUrl: url!,
            fit: fit,
            width: width,
            height: height,
            fadeInDuration: const Duration(milliseconds: 260),
            fadeInCurve: Curves.easeOut,
            placeholder: (_, _) => const SkeletonShimmer(
              child: SkeletonBox(
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            ),
            errorWidget: (_, _, _) => const _PhotoPlaceholder(broken: true),
          );

    final sized = SizedBox(width: width, height: height, child: image);
    if (radius == null) return sized;
    return ClipRRect(borderRadius: radius!, child: sized);
  }
}

/// Shown when a listing has no photos yet, or one fails to load. A tinted house
/// glyph reads better than a grey box.
class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({this.broken = false});

  final bool broken;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brand100, Color(0xFFFDE8D3)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              broken
                  ? Icons.image_not_supported_rounded
                  : Icons.home_work_rounded,
              size: 30,
              color: AppColors.brand500.withValues(alpha: 0.55),
            ),
            if (broken) ...[
              const SizedBox(height: 6),
              Text(
                'Photo unavailable',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brand700.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
