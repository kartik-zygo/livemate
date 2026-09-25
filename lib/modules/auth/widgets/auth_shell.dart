import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../core/widgets/glass_card.dart';

/// Shared chrome for Login and Sign up: ambient field, brand mark, hero
/// illustration, then a frosted card holding the form.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
    this.showHero = true,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;
  final bool showHero;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AmbientBackground(
        seed: showHero ? 0 : 2,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (onBack != null)
                            IconButton(
                              onPressed: onBack,
                              icon: const Icon(Icons.arrow_back_rounded),
                              tooltip: 'Back',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            )
                          else
                            SvgPicture.asset(
                              AppIllustration.logo.asset,
                              width: 40,
                              height: 40,
                              semanticsLabel: 'MyFlat Homes',
                            ),
                          const SizedBox(width: 11),
                          const BrandWordmark(fontSize: 19),
                        ],
                      ),
                      if (showHero) ...[
                        const SizedBox(height: 6),
                        Center(
                          child: PopIn(
                            child: SvgPicture.asset(
                              AppIllustration.authHero.asset,
                              height: 158,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                      ] else
                        const SizedBox(height: 20),
                      const SizedBox(height: 18),
                      EntryAnimation(
                        child: Text(title, style: AppTextStyles.display),
                      ),
                      const SizedBox(height: 7),
                      EntryAnimation(
                        index: 1,
                        child: Text(
                          subtitle,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.inkTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      EntryAnimation(
                        index: 2,
                        child: GlassCard(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                          child: form,
                        ),
                      ),
                      const SizedBox(height: 20),
                      EntryAnimation(index: 3, child: footer),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The inline error banner both auth forms share.
class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: text == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.rose400.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_rounded,
                    size: 18,
                    color: AppColors.rose600,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.rose600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
