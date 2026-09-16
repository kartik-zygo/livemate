import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/enum_meta.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/finder_post_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/finder_post_detail_controller.dart';

/// A person's brief. There is no enquiry endpoint pointed at finder posts — the
/// loop runs the other way, so the call to action is "list a room they can
/// enquire about", not "message them".
class FinderPostDetailView extends GetView<FinderPostDetailController> {
  const FinderPostDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        seed: 2,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back<void>,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Text(
                        'Looking for a room',
                        style: AppTextStyles.h3,
                      ),
                    ),
                    Obx(
                      () => controller.isOwner
                          ? IconButton(
                              onPressed: controller.deletePost,
                              icon: const Icon(Icons.delete_outline_rounded),
                              tooltip: 'Delete this post',
                              color: AppColors.rose600,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.status.value.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.status.value.isError) {
                    return ErrorState(
                      message: controller.error.value ?? 'Could not load post.',
                      onRetry: controller.load,
                    );
                  }

                  final post = controller.post.value;
                  if (post == null) return const SizedBox.shrink();

                  return _Body(post: post, isOwner: controller.isOwner);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.post, required this.isOwner});

  final FinderPostModel post;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
      children: [
        EntryAnimation(child: _Hero(post: post)),
        const SizedBox(height: 16),
        if ((post.note ?? '').isNotEmpty)
          EntryAnimation(
            index: 1,
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Their note', style: AppTextStyles.h3),
                  const SizedBox(height: 10),
                  Text(
                    post.note!,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        EntryAnimation(index: 2, child: _Preferences(post: post)),
        if (post.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          EntryAnimation(index: 3, child: _Tags(post: post)),
        ],
        const SizedBox(height: 20),
        if (!isOwner)
          EntryAnimation(index: 4, child: const _HowToConnect())
        else
          EntryAnimation(index: 4, child: _OwnerNote(post: post)),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.post});

  final FinderPostModel post;

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.person_search_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Looking in ${post.city?.name ?? 'a city'}',
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    post.city?.displayName ?? 'City not set',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            StatusPill.finder(post.status),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(height: 1, color: AppColors.line),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Their budget', style: AppTextStyles.caption),
                  const SizedBox(height: 3),
                  Text(
                    Fmt.moneyRange(post.budgetMin, post.budgetMax),
                    style: AppTextStyles.price.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            Pill(
              label: post.tier.label,
              icon: post.tier.icon,
              tone: post.tier == PostTier.managed
                  ? PillTone.brand
                  : PillTone.neutral,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Posted ${Fmt.relative(post.createdAt)}',
          style: AppTextStyles.caption,
        ),
      ],
    ),
  );
}

class _Preferences extends StatelessWidget {
  const _Preferences({required this.post});

  final FinderPostModel post;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferences', style: AppTextStyles.h3),
        const SizedBox(height: 14),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            Pill(
              label: 'Flatmates: ${post.genderPreference.label}',
              icon: post.genderPreference.icon,
            ),
            if (post.hasAgeRange)
              Pill(
                label: Fmt.ageRange(post.ageMin, post.ageMax),
                icon: Icons.cake_rounded,
              ),
          ],
        ),
      ],
    ),
  );
}

class _Tags extends StatelessWidget {
  const _Tags({required this.post});

  final FinderPostModel post;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lifestyle', style: AppTextStyles.h3),
        const SizedBox(height: 14),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: post.tags
              .map(
                (t) => Pill(
                  label: t.label,
                  icon: t.category.icon,
                  tone: PillTone.accent,
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}

class _HowToConnect extends StatelessWidget {
  const _HowToConnect();

  @override
  Widget build(BuildContext context) => GlassCard(
    fill: AppColors.brand100.withValues(alpha: 0.6),
    borderColor: AppColors.brand200,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const TintedIcon(
              icon: Icons.swap_horiz_rounded,
              size: 42,
              iconSize: 20,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                'Have a room that fits?',
                style: AppTextStyles.h3.copyWith(color: AppColors.brand700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          'Enquiries always flow from a person to a room. List your room in '
          'this city and it will appear in their search — then they can '
          'enquire and you decide whether to share contact details.',
          style: AppTextStyles.body.copyWith(height: 1.55),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'List a room',
          icon: Icons.add_home_rounded,
          onPressed: () {
            Get.until((route) => route.isFirst);
            Get.find<DashboardController>().createListing();
          },
        ),
      ],
    ),
  );
}

class _OwnerNote extends StatelessWidget {
  const _OwnerNote({required this.post});

  final FinderPostModel post;

  @override
  Widget build(BuildContext context) => GlassCard(
    fill: AppColors.accent100.withValues(alpha: 0.55),
    borderColor: AppColors.accent500.withValues(alpha: 0.3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TintedIcon(
          icon: Icons.visibility_rounded,
          color: AppColors.accent700,
          size: 42,
          iconSize: 19,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This is your post',
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.accent700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.status == FinderPostStatus.active
                    ? 'It is live and visible to anyone searching '
                          '${post.city?.name ?? 'this city'}.'
                    : 'Status: ${post.status.label}.',
                style: AppTextStyles.caption.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
