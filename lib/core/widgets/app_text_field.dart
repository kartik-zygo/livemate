import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// A labelled field with an optional live character counter, wired to the
/// input theme so every form in the app looks identical.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofillHints,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.required = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final List<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.inkPrimary,
                fontWeight: FontWeight.w600,
              ),
              children: required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.brand600),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          enabled: enabled,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
          style: AppTextStyles.body.copyWith(
            color: AppColors.inkPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            helperStyle: AppTextStyles.caption,
            helperMaxLines: 2,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 19, color: AppColors.inkTertiary),
            suffixIcon: suffix,
            // The default counter competes with the helper line; keep it only
            // where a maxLength is genuinely constraining.
            counterStyle: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}

/// Digits-only field that renders a leading ₹ and strips anything else.
class RupeeField extends StatelessWidget {
  const RupeeField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.validator,
    this.onChanged,
    this.required = false,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool required;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: hint ?? '0',
      helper: helper,
      required: required,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      prefixIcon: Icons.currency_rupee_rounded,
    );
  }
}

/// A read-only field that opens a picker — city, date, tier.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = 'Select',
    this.icon,
    this.required = false,
    this.errorText,
    this.trailing,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final String placeholder;
  final IconData? icon;
  final bool required;
  final String? errorText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final hasValue = (value ?? '').isNotEmpty;
    final hasError = (errorText ?? '').isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.inkPrimary,
                fontWeight: FontWeight.w600,
              ),
              children: required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.brand600),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: '$label. ${hasValue ? value : placeholder}',
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError ? AppColors.rose400 : AppColors.line,
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 19, color: AppColors.inkTertiary),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      hasValue ? value! : placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        color: hasValue
                            ? AppColors.inkPrimary
                            : AppColors.inkFaint,
                      ),
                    ),
                  ),
                  trailing ??
                      const Icon(
                        Icons.expand_more_rounded,
                        size: 20,
                        color: AppColors.inkTertiary,
                      ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              errorText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.rose600),
            ),
          ),
      ],
    );
  }
}
