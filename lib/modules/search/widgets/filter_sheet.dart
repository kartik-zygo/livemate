import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/reference_service.dart';
import '../../../core/utils/enum_meta.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/search_filters.dart';

/// The room filter set, matching the `GET /search/tenant-listings` params
/// exactly. There is no radius control because there is no radius.
class ListingFilterSheet extends StatefulWidget {
  const ListingFilterSheet({super.key, required this.initial});

  final ListingSearchFilters initial;

  static Future<ListingSearchFilters?> show(
    BuildContext context,
    ListingSearchFilters initial,
  ) => GlassSheet.show<ListingSearchFilters>(
    context,
    builder: (_) => ListingFilterSheet(initial: initial),
  );

  @override
  State<ListingFilterSheet> createState() => _ListingFilterSheetState();
}

class _ListingFilterSheetState extends State<ListingFilterSheet> {
  late ListingSearchFilters _draft = widget.initial;

  late final TextEditingController _budgetMin = TextEditingController(
    text: widget.initial.budgetMin?.toString() ?? '',
  );
  late final TextEditingController _budgetMax = TextEditingController(
    text: widget.initial.budgetMax?.toString() ?? '',
  );

  String? _budgetError;

  @override
  void dispose() {
    _budgetMin.dispose();
    _budgetMax.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : int.tryParse(t);
  }

  void _apply() {
    final min = _parse(_budgetMin);
    final max = _parse(_budgetMax);
    if (min != null && max != null && min > max) {
      setState(() => _budgetError = 'Minimum cannot exceed maximum');
      return;
    }

    Navigator.of(context).pop(
      _draft.copyWith(
        budgetMin: min,
        budgetMax: max,
        clearBudgetMin: min == null,
        clearBudgetMax: max == null,
      ),
    );
  }

  void _reset() {
    setState(() {
      _draft = _draft.cleared();
      _budgetMin.clear();
      _budgetMax.clear();
      _budgetError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Filter rooms',
      subtitle: 'Everything narrows within your chosen city.',
      onReset: _reset,
      onApply: _apply,
      applyLabel: 'Show rooms',
      children: [
        _Section(
          title: 'Monthly budget',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MoneyInput(
                      controller: _budgetMin,
                      label: 'Minimum',
                      onChanged: (_) => setState(() => _budgetError = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MoneyInput(
                      controller: _budgetMax,
                      label: 'Maximum',
                      onChanged: (_) => setState(() => _budgetError = null),
                    ),
                  ),
                ],
              ),
              if (_budgetError != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _budgetError!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.rose600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [10000, 20000, 30000, 50000].map((cap) {
                  final selected = _parse(_budgetMax) == cap;
                  return SelectChip(
                    label: 'Under ${Fmt.moneyCompact(cap)}',
                    selected: selected,
                    onTap: () => setState(() {
                      _budgetError = null;
                      _budgetMax.text = selected ? '' : '$cap';
                    }),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        _Section(
          title: 'Open to',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Gender.values
                .map(
                  (g) => SelectChip(
                    label: g.label,
                    icon: g.icon,
                    selected: _draft.gender == g,
                    onTap: () => setState(
                      () => _draft = _draft.gender == g
                          ? _draft.copyWith(clearGender: true)
                          : _draft.copyWith(gender: g),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        _Section(
          title: 'Room type',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RoomType.values
                .map(
                  (r) => SelectChip(
                    label: r.label,
                    icon: r.icon,
                    selected: _draft.roomTypes.contains(r),
                    onTap: () => setState(() {
                      final next = {..._draft.roomTypes};
                      next.contains(r) ? next.remove(r) : next.add(r);
                      _draft = _draft.copyWith(roomTypes: next);
                    }),
                  ),
                )
                .toList(),
          ),
        ),
        _Section(
          title: 'Property type',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PropertyType.values
                .map(
                  (p) => SelectChip(
                    label: p.label,
                    icon: p.icon,
                    selected: _draft.propertyTypes.contains(p),
                    onTap: () => setState(() {
                      final next = {..._draft.propertyTypes};
                      next.contains(p) ? next.remove(p) : next.add(p);
                      _draft = _draft.copyWith(propertyTypes: next);
                    }),
                  ),
                )
                .toList(),
          ),
        ),
        _Section(
          title: 'Furnishing',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Furnishing.values
                .map(
                  (f) => SelectChip(
                    label: f.label,
                    icon: f.icon,
                    selected: _draft.furnishings.contains(f),
                    onTap: () => setState(() {
                      final next = {..._draft.furnishings};
                      next.contains(f) ? next.remove(f) : next.add(f);
                      _draft = _draft.copyWith(furnishings: next);
                    }),
                  ),
                )
                .toList(),
          ),
        ),
        _Section(
          title: 'Bedrooms',
          subtitle: 'At least',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [1, 2, 3, 4]
                .map(
                  (n) => SelectChip(
                    label: '$n+',
                    icon: Icons.king_bed_rounded,
                    selected: _draft.minBedrooms == n,
                    onTap: () => setState(
                      () => _draft = _draft.minBedrooms == n
                          ? _draft.copyWith(clearMinBedrooms: true)
                          : _draft.copyWith(minBedrooms: n),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        _Section(
          title: 'Available by',
          subtitle: 'Rooms with no date set count as available now.',
          child: Row(
            children: [
              Expanded(
                child: SelectChip(
                  label: _draft.availableBy == null
                      ? 'Any date'
                      : Fmt.date(_draft.availableBy),
                  icon: Icons.event_rounded,
                  selected: _draft.availableBy != null,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _draft.availableBy ?? now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(
                        () => _draft = _draft.copyWith(availableBy: picked),
                      );
                    }
                  },
                ),
              ),
              if (_draft.availableBy != null) ...[
                const SizedBox(width: 8),
                AppIconButton(
                  icon: Icons.close_rounded,
                  semanticLabel: 'Clear the available-by date',
                  onPressed: () => setState(
                    () => _draft = _draft.copyWith(clearAvailableBy: true),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Finder-post filters: city, an overlapping budget range and lifestyle tags.
class FinderFilterSheet extends StatefulWidget {
  const FinderFilterSheet({super.key, required this.initial});

  final FinderSearchFilters initial;

  static Future<FinderSearchFilters?> show(
    BuildContext context,
    FinderSearchFilters initial,
  ) => GlassSheet.show<FinderSearchFilters>(
    context,
    builder: (_) => FinderFilterSheet(initial: initial),
  );

  @override
  State<FinderFilterSheet> createState() => _FinderFilterSheetState();
}

class _FinderFilterSheetState extends State<FinderFilterSheet> {
  late FinderSearchFilters _draft = widget.initial;
  late final TextEditingController _min = TextEditingController(
    text: widget.initial.budgetMin?.toString() ?? '',
  );
  late final TextEditingController _max = TextEditingController(
    text: widget.initial.budgetMax?.toString() ?? '',
  );
  String? _budgetError;

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : int.tryParse(t);
  }

  void _apply() {
    final min = _parse(_min);
    final max = _parse(_max);
    if (min != null && max != null && min > max) {
      setState(() => _budgetError = 'Minimum cannot exceed maximum');
      return;
    }
    Navigator.of(context).pop(
      _draft.copyWith(
        budgetMin: min,
        budgetMax: max,
        clearBudgetMin: min == null,
        clearBudgetMax: max == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reference = Get.find<ReferenceService>();
    final tags = reference.tags;

    return _SheetFrame(
      title: 'Filter people',
      subtitle: 'A post matches when its budget range overlaps yours.',
      onReset: () => setState(() {
        _draft = _draft.cleared();
        _min.clear();
        _max.clear();
        _budgetError = null;
      }),
      onApply: _apply,
      applyLabel: 'Show people',
      children: [
        _Section(
          title: 'Budget overlap',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MoneyInput(
                      controller: _min,
                      label: 'Minimum',
                      onChanged: (_) => setState(() => _budgetError = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MoneyInput(
                      controller: _max,
                      label: 'Maximum',
                      onChanged: (_) => setState(() => _budgetError = null),
                    ),
                  ),
                ],
              ),
              if (_budgetError != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _budgetError!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.rose600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (tags.isNotEmpty)
          for (final category in TagCategory.values)
            if (tags.any((t) => t.category == category))
              _Section(
                title: category.label,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .where((t) => t.category == category)
                      .map(
                        (t) => SelectChip(
                          label: t.label,
                          icon: category.icon,
                          selected: _draft.tagIds.contains(t.id),
                          onTap: () => setState(() {
                            final next = {..._draft.tagIds};
                            next.contains(t.id)
                                ? next.remove(t.id)
                                : next.add(t.id);
                            _draft = _draft.copyWith(tagIds: next);
                          }),
                        ),
                      )
                      .toList(),
                ),
              ),
      ],
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.onReset,
    required this.onApply,
    required this.applyLabel,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback onReset;
  final VoidCallback onApply;
  final String applyLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.88,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.h2),
                      const SizedBox(height: 3),
                      Text(subtitle, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                AppButton.ghost(
                  label: 'Reset',
                  size: AppButtonSize.compact,
                  onPressed: onReset,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.line),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              children: children,
            ),
          ),
          StickyActionBar(
            child: AppButton(label: applyLabel, onPressed: onApply),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 15.5)),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: AppTextStyles.caption),
        ],
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _MoneyInput extends StatelessWidget {
  const _MoneyInput({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    onChanged: onChanged,
    style: AppTextStyles.body.copyWith(
      color: AppColors.inkPrimary,
      fontSize: 15,
    ),
    decoration: InputDecoration(
      labelText: label,
      hintText: 'Any',
      prefixIcon: const Icon(
        Icons.currency_rupee_rounded,
        size: 17,
        color: AppColors.inkTertiary,
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 34),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
  );
}
