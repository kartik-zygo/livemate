import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../data/models/enums.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/enquiries_controller.dart';
import '../widgets/enquiry_card.dart';

class EnquiriesView extends GetView<EnquiriesController> {
  const EnquiriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 12),
          child: Obx(
            () => _Tabs(
              index: controller.tabIndex.value,
              pending: controller.pendingReceived,
              sentCount: controller.sent.length,
              onChanged: controller.setTab,
            ),
          ),
        ),
        Expanded(
          child: Obx(
            () => controller.tabIndex.value == 0
                ? _ReceivedList(controller: controller)
                : _SentList(controller: controller),
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.index,
    required this.pending,
    required this.sentCount,
    required this.onChanged,
  });

  final int index;
  final int pending;
  final int sentCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: GlassSurface(
        radius: 16,
        blurSigma: Glass.blurChip,
        specular: false,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _Tab(
              label: 'Received',
              badge: pending,
              selected: index == 0,
              onTap: () => onChanged(0),
            ),
            _Tab(
              label: 'Sent',
              badge: 0,
              selected: index == 1,
              onTap: () => onChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: selected ? Colors.white : AppColors.inkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : AppColors.rose500,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.brand700 : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _ReceivedList extends StatelessWidget {
  const _ReceivedList({required this.controller});

  final EnquiriesController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadReceived,
      color: AppColors.brand600,
      backgroundColor: Colors.white,
      child: Obx(() {
        if (controller.receivedStatus.value.isLoading &&
            controller.received.isEmpty) {
          return SkeletonList(
            count: 3,
            builder: (_) => const ListRowSkeleton(hasThumbnail: false),
          );
        }

        if (controller.receivedStatus.value.isError) {
          return ListView(
            padding: const EdgeInsets.only(top: 30),
            children: [
              ErrorState(
                message:
                    controller.receivedError.value ??
                    'Could not load enquiries.',
                onRetry: controller.loadReceived,
              ),
            ],
          );
        }

        if (controller.received.isEmpty) {
          return ListView(
            padding: const EdgeInsets.only(top: 10),
            children: [
              EmptyState(
                illustration: AppIllustration.enquiries,
                title: 'No enquiries yet',
                message:
                    'When someone is interested in a room you listed, their '
                    'enquiry lands here. List a room to start receiving them.',
                actionLabel: 'List a room',
                onAction: Get.find<DashboardController>().createListing,
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
          itemCount: controller.received.length,
          itemBuilder: (context, i) {
            final enquiry = controller.received[i];
            return EntryAnimation(
              index: i,
              child: Obx(
                () => ReceivedEnquiryCard(
                  enquiry: enquiry,
                  busy: controller.isResponding(enquiry.id),
                  onAccept: () =>
                      controller.respond(enquiry, EnquiryStatus.accepted),
                  onDecline: () =>
                      controller.respond(enquiry, EnquiryStatus.declined),
                  onOpenListing: () =>
                      controller.openListing(enquiry.listing.id),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SentList extends StatelessWidget {
  const _SentList({required this.controller});

  final EnquiriesController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadSent,
      color: AppColors.brand600,
      backgroundColor: Colors.white,
      child: Obx(() {
        if (controller.sentStatus.value.isLoading && controller.sent.isEmpty) {
          return const SkeletonList(count: 3, builder: _rowSkeleton);
        }

        if (controller.sentStatus.value.isError) {
          return ListView(
            padding: const EdgeInsets.only(top: 30),
            children: [
              ErrorState(
                message: controller.sentError.value ?? 'Could not load these.',
                onRetry: controller.loadSent,
              ),
            ],
          );
        }

        if (controller.sent.isEmpty) {
          return ListView(
            padding: const EdgeInsets.only(top: 10),
            children: [
              EmptyState(
                illustration: AppIllustration.search,
                title: 'You have not enquired yet',
                message:
                    'Find a room you like and send the owner a note. Their '
                    'contact details unlock as soon as they accept.',
                actionLabel: 'Browse rooms',
                onAction: () => Get.find<DashboardController>().goTo(
                  DashboardSection.discover,
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
          itemCount: controller.sent.length,
          itemBuilder: (context, i) {
            final enquiry = controller.sent[i];
            return EntryAnimation(
              index: i,
              child: SentEnquiryCard(
                enquiry: enquiry,
                onOpenListing: () => controller.openListing(enquiry.listing.id),
              ),
            );
          },
        );
      }),
    );
  }
}

Widget _rowSkeleton(int _) => const ListRowSkeleton();
