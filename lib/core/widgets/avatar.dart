import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Initials on a deterministic warm gradient.
///
/// The API exposes `avatarObjectKey` but no endpoint that serves it, so there
/// is nothing to fetch — initials are the avatar. When an avatar endpoint
/// lands, pass the resolved URL through [imageUrl] and this keeps working.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = 44,
    this.seed,
    this.borderColor,
  });

  final String initials;
  final String? imageUrl;
  final double size;

  /// Anything stable about the person — their id, their name — so the same
  /// person always gets the same colour pair.
  final String? seed;
  final Color? borderColor;

  static const List<List<Color>> _palettes = [
    [Color(0xFFF97316), Color(0xFFEA580C)],
    [Color(0xFF14B8A6), Color(0xFF0D9488)],
    [Color(0xFFFB7185), Color(0xFFE11D48)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    [Color(0xFF0EA5E9), Color(0xFF0369A1)],
  ];

  List<Color> get _colors {
    final key = seed ?? initials;
    var hash = 0;
    for (var i = 0; i < key.length; i++) {
      hash = (hash * 31 + key.codeUnitAt(i)) & 0x7fffffff;
    }
    return _palettes[hash % _palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 2),
        image: imageUrl == null
            ? null
            : DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              ),
      ),
      alignment: Alignment.center,
      child: imageUrl != null
          ? null
          : Text(
              initials,
              style: AppTextStyles.bodyStrong.copyWith(
                color: Colors.white,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
    );
  }
}

/// Avatar plus name and a supporting line — the person block used on listing
/// detail and in enquiry rows.
class PersonTile extends StatelessWidget {
  const PersonTile({
    super.key,
    required this.name,
    required this.initials,
    this.subtitle,
    this.seed,
    this.size = 46,
    this.trailing,
    this.onTap,
  });

  final String name;
  final String initials;
  final String? subtitle;
  final String? seed;
  final double size;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Avatar(initials: initials, seed: seed, size: size),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyStrong.copyWith(fontSize: 15),
              ),
              if ((subtitle ?? '').isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.all(4), child: row),
    );
  }
}
