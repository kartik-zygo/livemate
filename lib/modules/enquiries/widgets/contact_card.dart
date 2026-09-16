import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../data/models/user_model.dart';

/// The payoff of the whole loop: contact details, revealed only on an accepted
/// enquiry.
///
/// The caller is responsible for passing null when the enquiry is not accepted
/// — this widget renders nothing rather than an empty shell, so a null contact
/// can never leak as a blank row that looks like missing data.
class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact, required this.caption});

  final ContactModel? contact;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final c = contact;
    if (c == null || !c.hasAnything) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent100.withValues(alpha: 0.85),
            AppColors.accent100.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.accent500.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_open_rounded,
                size: 16,
                color: AppColors.accent700,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  caption,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent700,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if ((c.phone ?? '').isNotEmpty)
            _ContactRow(
              icon: Icons.phone_rounded,
              value: c.phone!,
              actionIcon: Icons.call_rounded,
              actionLabel: 'Call ${c.fullName}',
              onAction: () => _launch('tel:${c.phone}'),
            ),
          if ((c.phone ?? '').isNotEmpty && (c.email ?? '').isNotEmpty)
            const SizedBox(height: 9),
          if ((c.email ?? '').isNotEmpty)
            _ContactRow(
              icon: Icons.alternate_email_rounded,
              value: c.email!,
              actionIcon: Icons.mail_rounded,
              actionLabel: 'Email ${c.fullName}',
              onAction: () => _launch('mailto:${c.email}'),
            ),
        ],
      ),
    );
  }

  static Future<void> _launch(String uri) async {
    final parsed = Uri.parse(uri);
    if (!await launchUrl(parsed)) {
      AppFeedback.error('No app on this device can open that.');
    }
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.value,
    required this.actionIcon,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String value;
  final IconData actionIcon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: 13,
      blurSigma: Glass.blurChip,
      specular: false,
      shadows: const [],
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.accent700),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              value,
              maxLines: 1,
              style: AppTextStyles.bodyStrong.copyWith(fontSize: 13.5),
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              AppFeedback.success('Copied to clipboard.');
            },
            icon: const Icon(Icons.copy_rounded, size: 17),
            color: AppColors.inkTertiary,
            tooltip: 'Copy',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onAction,
            icon: Icon(actionIcon, size: 18),
            color: AppColors.accent700,
            tooltip: actionLabel,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Shown in place of [ContactCard] while an enquiry is still pending.
class ContactPendingNote extends StatelessWidget {
  const ContactPendingNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.lock_rounded, size: 15, color: AppColors.inkTertiary),
        const SizedBox(width: 9),
        Expanded(child: Text(message, style: AppTextStyles.caption)),
      ],
    ),
  );
}
