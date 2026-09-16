import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';

/// Composer for an enquiry.
///
/// The copy is explicit that contact details stay hidden until the owner
/// accepts — that gate is the product, so the UI should not let anyone be
/// surprised by it.
class EnquirySheet extends StatefulWidget {
  const EnquirySheet({
    super.key,
    required this.listingTitle,
    required this.onSend,
    this.sending = false,
  });

  final String listingTitle;
  final Future<bool> Function(String? message) onSend;
  final bool sending;

  static Future<bool?> show(
    BuildContext context, {
    required String listingTitle,
    required Future<bool> Function(String? message) onSend,
  }) => showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.ground,
    builder: (_) => EnquirySheet(listingTitle: listingTitle, onSend: onSend),
  );

  @override
  State<EnquirySheet> createState() => _EnquirySheetState();
}

class _EnquirySheetState extends State<EnquirySheet> {
  final TextEditingController _message = TextEditingController(
    text: 'Hi! Is the room still available?',
  );
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _sending = true);
    final ok = await widget.onSend(_message.text.trim());
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send an enquiry', style: AppTextStyles.h2),
                const SizedBox(height: 5),
                Text(
                  widget.listingTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Message',
                  controller: _message,
                  hint: 'Say hello and when you would like to move in.',
                  maxLines: 5,
                  minLines: 3,
                  maxLength: 500,
                  helper: 'Optional — but a short note gets more replies.',
                  validator: Validators.enquiryMessage,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 6),
                const _PrivacyNote(),
                const SizedBox(height: 18),
                AppButton(
                  label: 'Send enquiry',
                  icon: Icons.send_rounded,
                  loading: _sending || widget.sending,
                  onPressed: _send,
                ),
                const SizedBox(height: 8),
                AppButton.ghost(
                  label: 'Cancel',
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.accent100.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lock_rounded, size: 17, color: AppColors.accent700),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Your email and phone stay private. They are shared with the owner '
            'only if they accept your enquiry — and theirs are shared with you '
            'at the same moment.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accent700,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Confirmation shown after an enquiry lands.
class EnquirySentSheet extends StatelessWidget {
  const EnquirySentSheet({super.key, required this.onDone});

  final VoidCallback onDone;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onDone,
  }) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.ground,
    builder: (_) => EnquirySentSheet(onDone: onDone),
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmptyState(
            illustration: AppIllustration.success,
            compact: true,
            title: 'Enquiry sent',
            message:
                'The owner has been notified. As soon as they accept, their '
                'contact details appear under Enquiries.',
          ),
          const SizedBox(height: 4),
          AppButton(
            label: 'View my enquiries',
            icon: Icons.forum_rounded,
            onPressed: onDone,
          ),
          const SizedBox(height: 8),
          AppButton.ghost(
            label: 'Keep browsing',
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}
