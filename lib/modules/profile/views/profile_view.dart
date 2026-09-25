import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/enum_meta.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/user_model.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.reload,
      color: AppColors.brand600,
      backgroundColor: Colors.white,
      child: Obx(() {
        final user = controller.user.value;
        if (user == null) {
          return ListView(
            padding: const EdgeInsets.only(top: 40),
            children: [
              ErrorState(
                title: 'Could not load your profile',
                message:
                    controller.error.value ??
                    'Pull down to try again, or sign out and back in.',
                onRetry: controller.load,
              ),
            ],
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(
            18,
            4,
            18,
            MediaQuery.paddingOf(context).bottom + 36,
          ),
          children: [
            EntryAnimation(child: _Header(user: user)),
            const SizedBox(height: 16),
            if (user.completeness < 1)
              EntryAnimation(
                index: 1,
                child: _CompletenessCard(
                  user: user,
                  onTap: controller.editProfile,
                ),
              ),
            const SizedBox(height: 16),
            EntryAnimation(index: 2, child: _AboutCard(user: user)),
            const SizedBox(height: 16),
            EntryAnimation(index: 3, child: _PostsCard(controller: controller)),
            const SizedBox(height: 16),
            EntryAnimation(index: 4, child: const _AboutAppCard()),
            const SizedBox(height: 16),
            EntryAnimation(
              index: 5,
              child: _PrivacyCard(controller: controller),
            ),
            const SizedBox(height: 20),
            EntryAnimation(
              index: 6,
              child: AppButton.danger(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                onPressed: controller.signOut,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Avatar(
                initials: user.initials,
                seed: user.id,
                size: 68,
                borderColor: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isEmpty ? 'Your profile' : user.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                    if (user.isAdmin) ...[
                      const SizedBox(height: 7),
                      Pill(
                        label: user.role.label,
                        icon: Icons.shield_rounded,
                        tone: PillTone.brand,
                        dense: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppButton.secondary(
            label: 'Edit profile',
            icon: Icons.edit_rounded,
            size: AppButtonSize.compact,
            onPressed: controller.editProfile,
          ),
        ],
      ),
    );
  }
}

/// A filled-in profile gets more enquiries accepted, so the nudge is concrete
/// about what is still missing rather than showing a bare percentage.
class _CompletenessCard extends StatelessWidget {
  const _CompletenessCard({required this.user, required this.onTap});

  final UserModel user;
  final VoidCallback onTap;

  List<String> get _missing => [
    if ((user.phone ?? '').isEmpty) 'phone',
    if ((user.bio ?? '').isEmpty) 'a short bio',
    if ((user.occupation ?? '').isEmpty) 'your occupation',
    if (user.gender == null) 'gender',
    if (user.dateOfBirth == null) 'date of birth',
  ];

  @override
  Widget build(BuildContext context) {
    final missing = _missing;
    if (missing.isEmpty) return const SizedBox.shrink();

    final percent = (user.completeness * 100).round();

    return GlassCard(
      onTap: onTap,
      fill: AppColors.brand100.withValues(alpha: 0.75),
      borderColor: AppColors.brand200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TintedIcon(
                icon: Icons.auto_awesome_rounded,
                size: 40,
                iconSize: 19,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile $percent% complete',
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.brand700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Owners see this before accepting. Add '
                      '${missing.take(2).join(' and ')}.',
                      style: AppTextStyles.caption.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.brand700,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: user.completeness,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.7),
              valueColor: const AlwaysStoppedAnimation(AppColors.brand500),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if ((user.occupation ?? '').isNotEmpty)
        _InfoRow(
          icon: Icons.work_rounded,
          label: 'Occupation',
          value: user.occupation!,
        ),
      if (user.gender != null)
        _InfoRow(
          icon: user.gender!.icon,
          label: 'Gender',
          value: user.gender!.label,
        ),
      if (user.age != null)
        _InfoRow(
          icon: Icons.cake_rounded,
          label: 'Age',
          value: '${user.age} years',
        ),
      if ((user.phone ?? '').isNotEmpty)
        _InfoRow(icon: Icons.phone_rounded, label: 'Phone', value: user.phone!),
      _InfoRow(
        icon: Icons.event_available_rounded,
        label: 'Member since',
        value: Fmt.date(user.createdAt),
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About you', style: AppTextStyles.h3),
          const SizedBox(height: 6),
          if ((user.bio ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(user.bio!, style: AppTextStyles.body),
            const SizedBox(height: 14),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              'No bio yet. A couple of lines about your routine helps owners '
              'decide.',
              style: AppTextStyles.body.copyWith(color: AppColors.inkTertiary),
            ),
            const SizedBox(height: 14),
          ],
          ...rows,
        ],
      ),
    );
  }
}

class _PostsCard extends StatelessWidget {
  const _PostsCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      children: [
        _NavRow(
          icon: Icons.meeting_room_rounded,
          title: 'My listings',
          subtitle: 'Rooms you have posted',
          onTap: controller.openMyListings,
        ),
        const Divider(height: 1, indent: 62, color: AppColors.line),
        _NavRow(
          icon: Icons.travel_explore_rounded,
          title: 'My finder posts',
          subtitle: 'Where you are looking',
          onTap: controller.openMyFinderPosts,
        ),
      ],
    ),
  );
}

/// The support contact, privacy policy link and in-app account deletion both
/// App Store and Play review look for.
class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      children: [
        Obx(
          () => _NavRow(
            icon: Icons.support_agent_rounded,
            title: 'Help & support',
            subtitle: controller.legal.value.contactEmail,
            onTap: controller.openSupport,
          ),
        ),
        const Divider(height: 1, indent: 62, color: AppColors.line),
        Obx(() {
          final updated = controller.legal.value.policyLastUpdated;
          return _NavRow(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy policy',
            subtitle: updated == null
                ? 'How MyFlat Homes handles your data'
                : 'Last updated $updated',
            onTap: controller.openPrivacyPolicy,
          );
        }),
        const Divider(height: 1, indent: 62, color: AppColors.line),
        _NavRow(
          icon: Icons.person_remove_rounded,
          title: 'Delete account',
          subtitle: 'Permanently erase your account and posts',
          onTap: controller.deleteAccount,
        ),
      ],
    ),
  );
}

class _AboutAppCard extends StatelessWidget {
  const _AboutAppCard();

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About MyFlat Homes', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.location_city_rounded,
          label: 'Coverage',
          value: '652 cities, 36 states and union territories',
        ),
        _InfoRow(
          icon: Icons.lock_rounded,
          label: 'Privacy',
          value: 'Contact details shared only on an accepted enquiry',
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.inkTertiary),
        const SizedBox(width: 12),
        SizedBox(width: 96, child: Text(label, style: AppTextStyles.caption)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.inkPrimary,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    leading: TintedIcon(icon: icon, size: 40, iconSize: 19),
    title: Text(title, style: AppTextStyles.bodyStrong),
    subtitle: Text(subtitle, style: AppTextStyles.caption),
    trailing: const Icon(
      Icons.chevron_right_rounded,
      color: AppColors.inkTertiary,
    ),
  );
}
