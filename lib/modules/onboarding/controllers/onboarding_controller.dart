import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/onboarding_service.dart';

/// One slide of the intro.
///
/// Each carries its own accent so the whole screen — the ambient field, the
/// hero art, the progress dots, the button — shifts colour as you move
/// through, rather than three identical pages with different words on them.
class OnboardingSlide {
  const OnboardingSlide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
    required this.gradient,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  final Gradient gradient;

  static const List<OnboardingSlide> all = [
    OnboardingSlide(
      eyebrow: 'FIND YOUR PLACE',
      title: 'Rooms, flats and PGs,\ncity by city',
      body:
          'Browse what is actually available where you are moving — with the '
          'rent, the deposit and the move-in date on the card, before you ask '
          'anyone anything.',
      icon: Icons.meeting_room_rounded,
      accent: AppColors.brand500,
      gradient: AppColors.primaryGradient,
    ),
    OnboardingSlide(
      eyebrow: 'FIND YOUR PEOPLE',
      title: 'Flatmates who live\nthe way you do',
      body:
          'Filter by budget, room type and the things that actually decide it '
          'day to day. Or post what you are looking for and let the people '
          'with rooms come to you.',
      icon: Icons.people_alt_rounded,
      accent: AppColors.accent500,
      gradient: AppColors.accentGradient,
    ),
    OnboardingSlide(
      eyebrow: 'SHARE ON YOUR TERMS',
      title: 'Your number stays\nyours until you say so',
      body:
          'Send an enquiry with a note, not your phone number. Contact '
          'details are exchanged only when the other person accepts — never '
          'before, and never to anyone else.',
      icon: Icons.lock_rounded,
      accent: AppColors.violet400,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.violet400, Color(0xFF6D28D9)],
      ),
    ),
  ];
}

class OnboardingController extends GetxController {
  OnboardingController(this._onboarding);

  final OnboardingService _onboarding;

  final PageController pageController = PageController();

  final RxInt index = 0.obs;

  /// Fractional page position, so the hero art and the ambient field can move
  /// with the drag rather than snapping when the page settles.
  final RxDouble offset = 0.0.obs;

  List<OnboardingSlide> get slides => OnboardingSlide.all;

  int get lastIndex => slides.length - 1;

  bool get isLast => index.value == lastIndex;

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(_onScroll);
  }

  @override
  void onClose() {
    pageController.removeListener(_onScroll);
    pageController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!pageController.hasClients) return;
    offset.value = pageController.page ?? index.value.toDouble();
  }

  void onPageChanged(int next) => index.value = next;

  void next() {
    if (isLast) {
      finish();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void goTo(int page) => pageController.animateToPage(
    page,
    duration: const Duration(milliseconds: 420),
    curve: Curves.easeOutCubic,
  );

  /// Skip and Get started land in the same place — the intro is never shown
  /// again either way, because a skipped intro is still a seen one.
  ///
  /// The navigation is deliberately not awaited: `offAllNamed` completes only
  /// when the route it pushed is itself popped, which for sign-in never
  /// happens, so awaiting it would leave this future pending forever.
  Future<void> finish() async {
    await _onboarding.markSeen();
    unawaited(Get.offAllNamed<void>(Routes.login));
  }
}
