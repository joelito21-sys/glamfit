import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_motion.dart';
import '../../../core/widgets/gown_image.dart';
import '../../../models/gown_model.dart';
import 'gown_media.dart';
import 'gown_visuals.dart';

/// "Available Colors" section: preview card + selectable color chips.
class GownColorSelector extends StatelessWidget {
  final GownModel gown;
  final int selectedIndex;
  final ValueChanged<int> onColorSelected;

  const GownColorSelector({
    super.key,
    required this.gown,
    required this.selectedIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = gown.colors[selectedIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Colors',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _ColorPreviewCard(
            key: ValueKey(selectedIndex),
            imagePath: GownMedia.imageForColor(gown, selectedIndex),
            colorName: color,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: gown.colors.asMap().entries.map((entry) {
            final i = entry.key;
            return _ColorChip(
              label: entry.value,
              imagePath: GownMedia.imageForColor(gown, i),
              isSelected: selectedIndex == i,
              onTap: () => onColorSelected(i),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ColorPreviewCard extends StatelessWidget {
  final String imagePath;
  final String colorName;

  const _ColorPreviewCard({super.key, required this.imagePath, required this.colorName});

  @override
  Widget build(BuildContext context) {
    final chipColor = GownVisuals.chipColorFor(colorName);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 105,
              height: 105,
              child: GownImage(imagePath: imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected color',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  colorName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: chipColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.lightGray),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap a color to preview',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorChip({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                width: 42,
                height: 42,
                child: GownImage(imagePath: imagePath, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.charcoal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
