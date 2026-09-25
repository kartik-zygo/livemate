import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/glass.dart';
import '../controllers/dashboard_controller.dart';

/// The app drawer: the same six sections the rail carries, plus everything that
/// does not deserve a permanent slot — your own posts, profile editing, the two
/// create flows, and signing out.
///
/// The rail is for switching between sections you are working in; the drawer is
/// the full map. Both drive the one [DashboardController], so they can never
/// disagree about where you are.
class AppDrawer extends GetView<DashboardController> {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Drawer(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      width: width * 0.86 > 330 ? 330 : width * 0.86,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
        child: GlassSurface(
          radius: 30,
          blurSigma: Glass.blurOverlay,
          elevation: 2,
          rimWidth: 1.5,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DrawerHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    children: [
                      const _GroupLabel('Browse'),
                      Obx(
                        () => Column(
                          children: [
                            for (final section in DashboardSection.values)
                              _DrawerItem(
                                icon: section.icon,
                                label: section.label,
                                blurb: section.blurb,
                                selected: controller.section.value == section,
                                badge: _badgeFor(section),
                                onTap: () => controller.goTo(section),
                              ),
                          ],
                        ),
                      ),
                      const _GroupLabel('Your posts'),
                      _DrawerItem(
                        icon: Icons.meeting_room_rounded,
                        label: 'My listings',
                        blurb: 'Rooms you have posted',
                        onTap: controller.openMyListings,
                      ),
                      _DrawerItem(
                        icon: Icons.travel_explore_rounded,
                        label: 'My finder posts',
                        blurb: 'Where you are looking',
                        onTap: controller.openMyFinderPosts,
                      ),
                      _DrawerItem(
                        icon: Icons.tune_rounded,
                        label: 'Edit profile',
                        blurb: 'Owners see this before accepting',
                        onTap: controller.editProfile,
                      ),
                      const _GroupLabel('Post something'),
                      _DrawerAction(
                        icon: Icons.add_home_work_rounded,
                        label: 'List a room',
                        note: 'Owners',
                        gradient: AppColors.primaryGradient,
                        tint: AppColors.brand500,
                        onTap: controller.createListing,
                      ),
                      const SizedBox(height: 10),
                      _DrawerAction(
                        icon: Icons.person_search_rounded,
                        label: 'Post that you are looking',
                        note: 'Seekers',
                        gradient: AppColors.accentGradient,
                        tint: AppColors.accent500,
                        onTap: controller.createFinderPost,
                      ),
                    ],
                  ),
                ),
                const _DrawerFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _badgeFor(DashboardSection section) => switch (section) {
    DashboardSection.enquiries => controller.pendingEnquiries.value,
    DashboardSection.saved => controller.savedIds.length,
    _ => 0,
  };
}

class _DrawerHeader extends GetView<DashboardController> {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Obx(() {
        final user = controller.user.value;
        final name = (user?.fullName ?? '').trim();

        return GlassTapTarget(
          onTap: () => controller.goTo(DashboardSection.profile),
          scale: 0.98,
          child: Row(
            children: [
              Avatar(
                initials: user?.initials ?? '··',
                seed: user?.id,
                size: 52,
                borderColor: Colors.white,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name.isEmpty ? 'Your profile' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3.copyWith(fontSize: 16.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'Signed in',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkTertiary,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
    child: Row(
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.eyebrow),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lineStrong.withValues(alpha: 0.7),
                  AppColors.lineStrong.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.blurb,
    this.selected = false,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final String? blurb;
  final VoidCallback onTap;
  final bool selected;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.brand700 : AppColors.inkPrimary;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryGradient : null,
              color: selected
                  ? null
                  : AppColors.inkPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 19,
              color: selected ? Colors.white : AppColors.inkSecondary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (blurb != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    blurb!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          if (badge > 0) ...[
            const SizedBox(width: 8),
            GlassBadge(count: badge, compact: true),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: badge > 0 ? '$label, $badge' : label,
      child: GlassTapTarget(
        onTap: onTap,
        scale: 0.975,
        child: selected
            ? GlassSurface(
                radius: 16,
                blurSigma: Glass.blurChip,
                tint: AppColors.brand500,
                tintStrength: 0.16,
                rimColor: AppColors.brand200,
                specular: false,
                shadows: const [],
                child: row,
              )
            : row,
      ),
    );
  }
}

/// The two create flows get a heavier treatment than a nav row — they are the
/// only things in the drawer that make something rather than go somewhere.
class _DrawerAction extends StatelessWidget {
  const _DrawerAction({
    required this.icon,
    required this.label,
    required this.note,
    required this.gradient,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String note;
  final Gradient gradient;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $note',
      child: GlassTapTarget(
        onTap: onTap,
        scale: 0.97,
        child: GlassSurface(
          radius: 18,
          blurSigma: Glass.blurChip,
          tint: tint,
          tintStrength: 0.14,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong.copyWith(fontSize: 13.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                note,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends GetView<DashboardController> {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'MyFlat Homes',
            style: AppTextStyles.caption.copyWith(fontSize: 11),
          ),
        ),
        GlassPill(
          onTap: controller.signOut,
          semanticLabel: 'Sign out',
          rimColor: AppColors.rose400.withValues(alpha: 0.55),
          tint: AppColors.rose500,
          tintStrength: 0.1,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 15,
                color: AppColors.rose600,
              ),
              const SizedBox(width: 7),
              Text(
                'Sign out',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.rose600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
