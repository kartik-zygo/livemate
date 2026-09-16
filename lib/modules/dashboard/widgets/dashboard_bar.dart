import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/reference_service.dart';
import '../../../core/widgets/city_picker_sheet.dart';
import '../../../core/widgets/glass.dart';
import '../controllers/dashboard_controller.dart';
import 'create_menu_sheet.dart';

/// The dashboard's chrome: one floating glass panel carrying the drawer button,
/// the current section, the city you are browsing, the create action, and the
/// section rail.
///
/// This replaced a bottom nav bar. Putting navigation up here rather than along
/// the bottom edge means one piece of chrome instead of two, and it leaves the
/// whole lower half of the screen to content.
class DashboardBar extends GetView<DashboardController> {
  const DashboardBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      radius: 28,
      blurSigma: Glass.blurPanel,
      elevation: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            child: Row(
              children: [
                GlassIconButton(
                  icon: Icons.menu_rounded,
                  semanticLabel: 'Open menu',
                  size: 42,
                  iconSize: 20,
                  onTap: controller.openDrawer,
                ),
                const SizedBox(width: 10),
                const Expanded(child: _SectionTitle()),
                const SizedBox(width: 8),
                const _CityPill(),
                const SizedBox(width: 6),
                _CreateButton(onTap: () => CreateMenuSheet.show(context)),
              ],
            ),
          ),
          const _Hairline(),
          const SectionRail(),
        ],
      ),
    );
  }
}

/// The section name, cross-faded on change. On Home it greets you by name
/// instead — the one section that is about you rather than about rooms.
class _SectionTitle extends GetView<DashboardController> {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final section = controller.section.value;
      final first = (controller.user.value?.fullName ?? '')
          .trim()
          .split(' ')
          .firstOrNull;

      final text = section == DashboardSection.home && (first ?? '').isNotEmpty
          ? 'Hi $first'
          : section.label;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: Text(
          text,
          key: ValueKey(text),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h2.copyWith(fontSize: 19, letterSpacing: -0.5),
        ),
      );
    });
  }
}

/// City only matters where results are city-scoped, so it appears on Home,
/// Discover and Search and folds away everywhere else.
class _CityPill extends StatelessWidget {
  const _CityPill();

  static const Set<DashboardSection> _shownOn = {
    DashboardSection.home,
    DashboardSection.discover,
    DashboardSection.search,
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final reference = Get.find<ReferenceService>();

    return Obx(() {
      if (!_shownOn.contains(controller.section.value)) {
        return const SizedBox.shrink();
      }

      final city = reference.selectedCity.value;

      return GlassPill(
        onTap: () async {
          final picked = await CityPickerSheet.show(
            context,
            selectedId: city?.id,
          );
          if (picked != null) await reference.selectCity(picked);
        },
        semanticLabel: city == null
            ? 'Choose a city'
            : 'Browsing in ${city.displayName}. Change city.',
        tint: city == null ? AppColors.brand500 : null,
        rimColor: city == null ? AppColors.brand200 : null,
        padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 15,
              color: city == null ? AppColors.brand700 : AppColors.brand600,
            ),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 84),
              child: Text(
                city?.name ?? 'City',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.expand_more_rounded,
              size: 15,
              color: AppColors.inkTertiary,
            ),
          ],
        ),
      );
    });
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Create a listing or a finder post',
      child: GlassTapTarget(
        onTap: onTap,
        scale: 0.9,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4DEA580C),
                blurRadius: 18,
                offset: Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 23),
        ),
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0),
        ],
      ),
    ),
  );
}

/// The horizontal rail of sections. Scrolls, so it can carry six destinations
/// where a bottom bar tops out at five, and keeps the selected one in view when
/// the section is changed from the drawer instead of from here.
class SectionRail extends StatefulWidget {
  const SectionRail({super.key});

  @override
  State<SectionRail> createState() => _SectionRailState();
}

class _SectionRailState extends State<SectionRail> {
  final DashboardController _controller = Get.find<DashboardController>();
  final Map<DashboardSection, GlobalKey> _keys = {
    for (final s in DashboardSection.values) s: GlobalKey(),
  };

  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _worker = ever<DashboardSection>(_controller.section, _reveal);
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  void _reveal(DashboardSection section) {
    // After the frame, so the pill has been laid out at its selected width.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _keys[section]?.currentContext;
      if (target == null || !mounted) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.5,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Obx(() {
        final active = _controller.section.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          itemCount: DashboardSection.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: 7),
          itemBuilder: (context, i) {
            final section = DashboardSection.values[i];
            return _RailPill(
              key: _keys[section],
              section: section,
              selected: section == active,
              badge: switch (section) {
                DashboardSection.enquiries =>
                  _controller.pendingEnquiries.value,
                DashboardSection.saved => _controller.savedIds.length,
                _ => 0,
              },
              onTap: () => _controller.goTo(section),
            );
          },
        );
      }),
    );
  }
}

class _RailPill extends StatelessWidget {
  const _RailPill({
    super.key,
    required this.section,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final DashboardSection section;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: selected ? 15 : 12),
      decoration: BoxDecoration(
        gradient: selected ? AppColors.primaryGradient : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x40EA580C),
                  blurRadius: 16,
                  offset: Offset(0, 7),
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? section.icon : section.iconOutline,
            size: 18,
            color: selected ? Colors.white : AppColors.inkSecondary,
          ),
          // Unselected pills keep their icon only until there is room; the
          // label is what makes the rail readable, so it always stays.
          const SizedBox(width: 7),
          Text(
            section.label,
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
              color: selected ? Colors.white : AppColors.inkSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (badge > 0) ...[
            const SizedBox(width: 7),
            _RailBadge(count: badge, onBrand: selected),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: badge > 0 ? '${section.label}, $badge' : section.label,
      child: GlassTapTarget(
        onTap: onTap,
        scale: 0.94,
        child: selected
            ? content
            : GlassSurface(
                radius: 18,
                blurSigma: Glass.blurChip,
                specular: false,
                rimWidth: 1,
                shadows: const [],
                child: content,
              ),
      ),
    );
  }
}

/// On a selected pill the rose badge would fight the brand gradient it sits on,
/// so it goes white-on-brand there instead.
class _RailBadge extends StatelessWidget {
  const _RailBadge({required this.count, required this.onBrand});

  final int count;
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    if (!onBrand) return GlassBadge(count: count, compact: true);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      constraints: const BoxConstraints(minWidth: 17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.brand700,
          height: 1.3,
        ),
      ),
    );
  }
}
