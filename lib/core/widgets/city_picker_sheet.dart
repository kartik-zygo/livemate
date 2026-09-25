import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/city_model.dart';
import '../services/reference_service.dart';
import 'app_button.dart';
import 'empty_state.dart';
import 'glass.dart';

/// The one location input in the app.
///
/// Location is city-only: no map, no coordinates, no localities, no radius. All
/// 652 cities are cached after the first fetch and filtered in memory, so the
/// typeahead never hits the network. Every row shows "name, state" because city
/// names repeat across states.
class CityPickerSheet extends StatefulWidget {
  const CityPickerSheet({super.key, this.selectedId, this.title});

  final String? selectedId;
  final String? title;

  /// Opens the picker and resolves to the chosen city, or null if dismissed.
  static Future<CityModel?> show(
    BuildContext context, {
    String? selectedId,
    String? title,
  }) => GlassSheet.show<CityModel>(
    context,
    builder: (_) => CityPickerSheet(selectedId: selectedId, title: title),
  );

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  final TextEditingController _query = TextEditingController();
  final ReferenceService _reference = Get.find<ReferenceService>();

  List<CityModel> _results = const [];

  @override
  void initState() {
    super.initState();
    _results = _reference.search('');
    // If reference data never loaded (offline first run), try again here rather
    // than stranding the user on an empty list.
    if (!_reference.isReady) {
      _reference.ensureLoaded().then((_) {
        if (mounted) setState(() => _results = _reference.search(_query.text));
      });
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) =>
      setState(() => _results = _reference.search(value));

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: GlassSheet(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? 'Choose a city',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MyFlat Homes covers 652 cities across every state and '
                      'union territory.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _query,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: _onQueryChanged,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.inkPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search city or state',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.inkTertiary,
                        ),
                        suffixIcon: _query.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _query.clear();
                                  _onQueryChanged('');
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_reference.loading.value && _reference.cities.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = _reference.loadError.value;
      if (error != null && _reference.cities.isEmpty) {
        return ErrorState(
          title: 'Could not load cities',
          message: error,
          compact: true,
          onRetry: () => _reference.ensureLoaded(force: true),
        );
      }

      if (_results.isEmpty) {
        return EmptyState(
          illustration: AppIllustration.chooseCity,
          compact: true,
          title: 'No city matches "${_query.text.trim()}"',
          message: 'Try the state name, or a different spelling.',
          actionLabel: 'Clear search',
          onAction: () {
            _query.clear();
            _onQueryChanged('');
          },
        );
      }

      return ListView.separated(
        padding: EdgeInsets.fromLTRB(
          12,
          0,
          12,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: _results.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, indent: 60, color: AppColors.line),
        itemBuilder: (context, i) {
          final city = _results[i];
          final selected = city.id == widget.selectedId;

          return ListTile(
            onTap: () => Navigator.of(context).pop(city),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? AppColors.brand100 : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.location_city_rounded,
                size: 18,
                color: selected ? AppColors.brand700 : AppColors.inkTertiary,
              ),
            ),
            title: Text(
              city.name,
              style: AppTextStyles.bodyStrong.copyWith(
                color: selected ? AppColors.brand700 : AppColors.inkPrimary,
              ),
            ),
            subtitle: Text(city.state, style: AppTextStyles.caption),
            trailing: selected
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.brand600,
                    size: 21,
                  )
                : null,
          );
        },
      );
    });
  }
}

/// Full-bleed prompt shown wherever a city is required before anything can
/// load — search, discover, the create flows.
class ChooseCityPrompt extends StatelessWidget {
  const ChooseCityPrompt({
    super.key,
    required this.onChoose,
    this.title = 'Choose a city to start browsing',
    this.message =
        'MyFlat Homes matches city to city, so pick where you want to live and '
        'we will show you every room open there.',
  });

  final VoidCallback onChoose;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => EmptyState(
    illustration: AppIllustration.chooseCity,
    title: title,
    message: message,
    actionLabel: 'Choose a city',
    onAction: onChoose,
  );
}

/// A labelled row that opens the picker — used inside forms.
class CityPickerField extends StatelessWidget {
  const CityPickerField({
    super.key,
    required this.city,
    required this.onPicked,
    this.label = 'City',
    this.required = true,
    this.errorText,
  });

  final CityModel? city;
  final ValueChanged<CityModel> onPicked;
  final String label;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => _Field(
        label: label,
        required: required,
        errorText: errorText,
        value: city?.displayName,
        onTap: () async {
          final picked = await CityPickerSheet.show(
            context,
            selectedId: city?.id,
          );
          if (picked != null) onPicked(picked);
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.onTap,
    required this.required,
    this.errorText,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool required;
  final String? errorText;

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
        InkWell(
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
                const Icon(
                  Icons.location_on_rounded,
                  size: 19,
                  color: AppColors.inkTertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasValue ? value! : 'Search 652 cities',
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
                const Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: AppColors.inkTertiary,
                ),
              ],
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

/// Small helper so screens can open the picker without importing the sheet.
Future<CityModel?> pickCity(BuildContext context, {String? selectedId}) =>
    CityPickerSheet.show(context, selectedId: selectedId);

/// Used by [AppButton] consumers that need a compact "change city" affordance.
class ChangeCityButton extends StatelessWidget {
  const ChangeCityButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppButton.ghost(
    label: 'Change city',
    icon: Icons.swap_horiz_rounded,
    size: AppButtonSize.compact,
    onPressed: onTap,
  );
}
