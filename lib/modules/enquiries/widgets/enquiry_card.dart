import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/pills.dart';
import '../../../core/widgets/remote_image.dart';
import '../../../data/models/enquiry_model.dart';
import 'contact_card.dart';

/// An enquiry someone sent you. Accept or decline while pending; once answered,
/// the card either reveals their contact details or records the decline.
class ReceivedEnquiryCard extends StatelessWidget {
  const ReceivedEnquiryCard({
    super.key,
    required this.enquiry,
    required this.onAccept,
    required this.onDecline,
    required this.onOpenListing,
    this.busy = false,
  });

  final EnquiryModel enquiry;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onOpenListing;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final sender = enquiry.sender;

    return GlassCard(
      radius: AppTheme.radiusLg,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: PersonTile(
                  name: sender?.fullName ?? 'A Livemate member',
                  initials: sender?.initials ?? '?',
                  seed: sender?.id,
                  subtitle: sender?.occupation,
                ),
              ),
              StatusPill.enquiry(enquiry.status),
            ],
          ),
          if ((sender?.bio ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              sender!.bio!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body,
            ),
          ],
          if ((enquiry.message ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            _MessageBubble(message: enquiry.message!),
          ],
          const SizedBox(height: 13),
          _ListingStrip(enquiry: enquiry, onTap: onOpenListing),
          if (enquiry.isAccepted)
            ContactCard(
              contact: enquiry.senderContact,
              caption: 'Their contact details',
            )
          else if (enquiry.isPending)
            const ContactPendingNote(
              message:
                  'Accept to swap contact details with them. Decline to close '
                  'the enquiry.',
            )
          else
            const ContactPendingNote(
              message: 'You declined this enquiry. No details were shared.',
            ),
          if (enquiry.isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppButton.danger(
                    label: 'Decline',
                    size: AppButtonSize.compact,
                    onPressed: busy ? null : onDecline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: 'Accept',
                    icon: Icons.handshake_rounded,
                    size: AppButtonSize.compact,
                    loading: busy,
                    onPressed: busy ? null : onAccept,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Received ${Fmt.relative(enquiry.createdAt)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// An enquiry you sent. Contact details appear only once the owner accepts.
class SentEnquiryCard extends StatelessWidget {
  const SentEnquiryCard({
    super.key,
    required this.enquiry,
    required this.onOpenListing,
  });

  final EnquiryModel enquiry;
  final VoidCallback onOpenListing;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: AppTheme.radiusLg,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      onTap: onOpenListing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RemoteImage(
                url: enquiry.listing.coverPhoto?.url,
                width: 68,
                height: 68,
                radius: BorderRadius.circular(13),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enquiry.listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong.copyWith(fontSize: 14.5),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            Fmt.money(enquiry.listing.budget),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.price.copyWith(fontSize: 15),
                          ),
                        ),
                        Text('/mo', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              StatusPill.enquiry(enquiry.status),
            ],
          ),
          if ((enquiry.message ?? '').isNotEmpty) ...[
            const SizedBox(height: 13),
            _MessageBubble(message: enquiry.message!, outgoing: true),
          ],
          if (enquiry.isAccepted)
            ContactCard(
              contact: enquiry.ownerContact,
              caption: 'Owner contact details',
            )
          else if (enquiry.isPending)
            const ContactPendingNote(
              message:
                  'Waiting on the owner. Their contact details unlock the '
                  'moment they accept.',
            )
          else
            const ContactPendingNote(
              message: 'The owner declined. Try another room in the same city.',
            ),
          const SizedBox(height: 10),
          Text(
            enquiry.isPending
                ? 'Sent ${Fmt.relative(enquiry.createdAt)}'
                : 'Answered ${Fmt.relative(enquiry.updatedAt)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.outgoing = false});

  final String message;
  final bool outgoing;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: outgoing ? AppColors.brand100 : AppColors.surfaceMuted,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(14),
        topRight: const Radius.circular(14),
        bottomLeft: Radius.circular(outgoing ? 14 : 4),
        bottomRight: Radius.circular(outgoing ? 4 : 14),
      ),
    ),
    child: Text(
      message,
      style: AppTextStyles.body.copyWith(
        color: outgoing ? AppColors.brand700 : AppColors.inkSecondary,
        height: 1.5,
      ),
    ),
  );
}

class _ListingStrip extends StatelessWidget {
  const _ListingStrip({required this.enquiry, required this.onTap});

  final EnquiryModel enquiry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            RemoteImage(
              url: enquiry.listing.coverPhoto?.url,
              width: 44,
              height: 44,
              radius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    enquiry.listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.inkPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Fmt.money(enquiry.listing.budget)} / month',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.inkTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
