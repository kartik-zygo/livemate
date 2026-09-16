import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass.dart';

/// The two things a person can post: a room they have, or a brief describing
/// the room they are looking for.
class CreateMenuSheet extends StatelessWidget {
  const CreateMenuSheet({super.key});

  static Future<void> show(BuildContext context) =>
      GlassSheet.show<void>(context, builder: (_) => const CreateMenuSheet());

  @override
  Widget build(BuildContext context) {
    return GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What would you like to post?', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text(
            'Offer a room you have, or tell the city what you are looking for.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 22),
          _Option(
            icon: Icons.meeting_room_rounded,
            gradient: AppColors.primaryGradient,
            tint: AppColors.brand500,
            title: 'I have a room',
            subtitle:
                'List your place, add three photos and it goes live to '
                'everyone searching your city.',
            onTap: () {
              Navigator.of(context).pop();
              Get.toNamed(Routes.createListing);
            },
          ),
          const SizedBox(height: 13),
          _Option(
            icon: Icons.travel_explore_rounded,
            gradient: AppColors.accentGradient,
            tint: AppColors.accent500,
            title: 'I am looking for a room',
            subtitle:
                'Post your budget and preferences so people with rooms can '
                'find you.',
            onTap: () {
              Navigator.of(context).pop();
              Get.toNamed(Routes.createFinderPost);
            },
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.gradient,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Gradient gradient;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassTapTarget(
      onTap: onTap,
      child: GlassSurface(
        radius: 20,
        blurSigma: Glass.blurChip,
        tint: tint,
        tintStrength: 0.1,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: tint.withValues(alpha: 0.36),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: 5),
                  Text(subtitle, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
