import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/config/env.dart';
import '../../../core/utils/enum_meta.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/city_picker_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pills.dart';
import '../../../core/widgets/remote_image.dart';
import '../../../data/models/enums.dart';
import '../controllers/create_listing_controller.dart';

class BasicsStep extends StatelessWidget {
  const BasicsStep({super.key, required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) => Form(
    key: controller.formKeys[ListingStep.basics],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Listing title',
          controller: controller.title,
          hint: 'Sunny 2BHK near the metro',
          prefixIcon: Icons.title_rounded,
          maxLength: 120,
          required: true,
          textCapitalization: TextCapitalization.sentences,
          validator: Validators.listingTitle,
        ),
        const SizedBox(height: 6),
        AppTextField(
          label: 'Description',
          controller: controller.description,
          hint:
              'Furnished room in a quiet building, ten minutes from the tech '
              'park. Looking for someone tidy and easy-going.',
          maxLines: 6,
          minLines: 4,
          maxLength: 2000,
          required: true,
          textCapitalization: TextCapitalization.sentences,
          validator: Validators.listingDescription,
        ),
        const SizedBox(height: 6),
        RupeeField(
          label: 'Monthly rent',
          controller: controller.budget,
          required: true,
          validator: Validators.budget,
          helper: 'What one flatmate pays each month.',
        ),
        const SizedBox(height: 16),
        RupeeField(
          label: 'Security deposit',
          controller: controller.deposit,
          helper: 'Optional.',
        ),
      ],
    ),
  );
}

class LocationStep extends StatelessWidget {
  const LocationStep({super.key, required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Obx(
        () => CityPickerField(
          city: controller.city.value,
          errorText: controller.cityError.value,
          onPicked: (city) {
            controller.city.value = city;
            controller.cityError.value = null;
          },
        ),
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accent100.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TintedIcon(
              icon: Icons.map_rounded,
              color: AppColors.accent700,
              size: 38,
              iconSize: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Livemate matches city to city — there is no map, radius or '
                'locality. Anyone searching this city will see your listing.',
                style: AppTextStyles.caption.copyWith(height: 1.45),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Open to',
        style: AppTextStyles.label.copyWith(
          color: AppColors.inkPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 9),
      Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Gender.values
              .map(
                (g) => SelectChip(
                  label: g.label,
                  icon: g.icon,
                  selected: controller.openTo.value == g,
                  onTap: () => controller.openTo.value = g,
                ),
              )
              .toList(),
        ),
      ),
    ],
  );
}

class PropertyStep extends StatelessWidget {
  const PropertyStep({super.key, required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) => Form(
    key: controller.formKeys[ListingStep.property],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Property type'),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PropertyType.values
                .map(
                  (p) => SelectChip(
                    label: p.label,
                    icon: p.icon,
                    selected: controller.propertyType.value == p,
                    onTap: () => controller.propertyType.value =
                        controller.propertyType.value == p ? null : p,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        _Label('Room type'),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RoomType.values
                .map(
                  (r) => SelectChip(
                    label: r.label,
                    icon: r.icon,
                    selected: controller.roomType.value == r,
                    onTap: () => controller.roomType.value =
                        controller.roomType.value == r ? null : r,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        _Label('Furnishing'),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Furnishing.values
                .map(
                  (f) => SelectChip(
                    label: f.label,
                    icon: f.icon,
                    selected: controller.furnishing.value == f,
                    onTap: () => controller.furnishing.value =
                        controller.furnishing.value == f ? null : f,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Bedrooms',
                controller: controller.bedrooms,
                hint: '2',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.optionalRange(
                  v,
                  min: 0,
                  max: 20,
                  unit: 'number',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Bathrooms',
                controller: controller.bathrooms,
                hint: '2',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.optionalRange(
                  v,
                  min: 0,
                  max: 20,
                  unit: 'number',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Maximum occupants',
          controller: controller.maxOccupants,
          hint: '3',
          keyboardType: TextInputType.number,
          helper: 'How many people live here in total.',
          validator: (v) =>
              Validators.optionalRange(v, min: 1, max: 20, unit: 'number'),
        ),
        const SizedBox(height: 18),
        Obx(
          () => PickerField(
            label: 'Available from',
            icon: Icons.event_rounded,
            value: controller.availableFrom.value == null
                ? null
                : Fmt.date(controller.availableFrom.value),
            placeholder: 'Available now',
            onTap: () => controller.pickAvailableFrom(context),
            trailing: controller.availableFrom.value == null
                ? null
                : IconButton(
                    onPressed: controller.clearAvailableFrom,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    tooltip: 'Clear date — available now',
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Leave this empty and the listing shows as "Available now".',
          style: AppTextStyles.caption,
        ),
      ],
    ),
  );
}

class AmenitiesStep extends StatelessWidget {
  const AmenitiesStep({super.key, required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Obx(
        () => Text(
          controller.amenities.isEmpty
              ? 'Nothing selected yet'
              : '${controller.amenities.length} selected',
          style: AppTextStyles.caption,
        ),
      ),
      const SizedBox(height: 14),
      Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Amenity.values
              .map(
                (a) => SelectChip(
                  label: a.label,
                  icon: a.icon,
                  selected: controller.amenities.contains(a),
                  onTap: () => controller.toggleAmenity(a),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );
}

class PhotosStep extends StatelessWidget {
  const PhotosStep({super.key, required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final existingPhotos = controller.created.value?.photos ?? const [];
      final pending = controller.pendingPhotos;
      final total = controller.totalPhotoCount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhotoProgress(count: total),
          const SizedBox(height: 16),
          if (total == 0)
            _PhotoDropZone(controller: controller)
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              childAspectRatio: 1.15,
              children: [
                for (final photo in existingPhotos)
                  _PhotoTile(
                    badge: 'Uploaded',
                    child: RemoteImage(
                      url: photo.url,
                      radius: BorderRadius.circular(14),
                    ),
                  ),
                for (var i = 0; i < pending.length; i++)
                  _PhotoTile(
                    badge: 'Ready',
                    onRemove: () => controller.removePendingPhoto(i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(pending[i], fit: BoxFit.cover),
                    ),
                  ),
                if (controller.photosRemaining > 0)
                  _AddPhotoTile(controller: controller),
              ],
            ),
          const SizedBox(height: 18),
          if (controller.uploadingPhotos.value) ...[
            LinearProgressIndicator(
              value: pending.isEmpty
                  ? null
                  : controller.uploadedCount.value /
                        (controller.uploadedCount.value + pending.length),
              minHeight: 5,
              backgroundColor: AppColors.brand100,
            ),
            const SizedBox(height: 8),
            Text(
              'Uploading ${controller.uploadedCount.value + 1} of '
              '${controller.uploadedCount.value + pending.length}…',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: 'Gallery',
                  icon: Icons.photo_library_rounded,
                  size: AppButtonSize.compact,
                  onPressed: controller.photosRemaining > 0
                      ? () => controller.pickPhotos(fromCamera: false)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.secondary(
                  label: 'Camera',
                  icon: Icons.photo_camera_rounded,
                  size: AppButtonSize.compact,
                  onPressed: controller.photosRemaining > 0
                      ? () => controller.pickPhotos(fromCamera: true)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'JPEG, PNG or WebP · up to 2 MB each · '
            '${Env.minPhotosToPublish} to publish, '
            '${Env.maxPhotosPerListing} maximum.',
            style: AppTextStyles.caption,
          ),
        ],
      );
    });
  }
}

/// Three dots that fill as photos are added — the publish threshold made
/// visible rather than explained in a sentence nobody reads.
class _PhotoProgress extends StatelessWidget {
  const _PhotoProgress({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ready = count >= Env.minPhotosToPublish;

    return Row(
      children: [
        ...List.generate(Env.maxPhotosPerListing, (i) {
          final filled = i < count;
          final required = i < Env.minPhotosToPublish;
          return Container(
            margin: const EdgeInsets.only(right: 7),
            width: 30,
            height: 6,
            decoration: BoxDecoration(
              color: filled
                  ? (required ? AppColors.accent500 : AppColors.brand500)
                  : AppColors.line,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            ready
                ? 'Ready to publish'
                : '${Env.minPhotosToPublish - count} more to publish',
            style: AppTextStyles.caption.copyWith(
              color: ready ? AppColors.accent700 : AppColors.amber700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoDropZone extends StatelessWidget {
  const _PhotoDropZone({required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => controller.pickPhotos(fromCamera: false),
    borderRadius: BorderRadius.circular(18),
    child: Container(
      height: 168,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.brand100.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.brand200, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TintedIcon(
            icon: Icons.add_photo_alternate_rounded,
            size: 56,
            iconSize: 26,
          ),
          const SizedBox(height: 12),
          Text('Add your first photo', style: AppTextStyles.bodyStrong),
          const SizedBox(height: 4),
          Text(
            'Listings with photos get far more enquiries.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    ),
  );
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.badge, this.onRemove, required this.child});

  final Widget child;
  final String badge;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
      Positioned(
        left: 8,
        bottom: 8,
        child: Pill(
          label: badge,
          tone: badge == 'Uploaded' ? PillTone.accent : PillTone.amber,
          dense: true,
        ),
      ),
      if (onRemove != null)
        Positioned(
          right: 4,
          top: 4,
          child: AppIconButton(
            icon: Icons.close_rounded,
            semanticLabel: 'Remove this photo',
            size: 32,
            iconSize: 16,
            background: Colors.white,
            onPressed: onRemove,
          ),
        ),
    ],
  );
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.controller});

  final CreateListingController controller;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => controller.pickPhotos(fromCamera: false),
    borderRadius: BorderRadius.circular(14),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.brand100.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brand200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_rounded, size: 28, color: AppColors.brand600),
          const SizedBox(height: 6),
          Text(
            '${controller.photosRemaining} left',
            style: AppTextStyles.caption.copyWith(color: AppColors.brand700),
          ),
        ],
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: AppColors.inkPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
