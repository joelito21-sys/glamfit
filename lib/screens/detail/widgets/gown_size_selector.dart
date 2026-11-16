import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_motion.dart';
import '../../../models/gown_model.dart';
import '../../size_guide/size_guide_flow_screen.dart';

/// Launches the size-guide flow and reports back the chosen recommendation.
///
/// Extracted because the exact same `Navigator.push` + result-application
/// block was duplicated in two places (app bar and body). One flow, one
/// home: OCP-friendly if the routing ever changes.
typedef SizeGuideResultHandler = void Function(SizeGuideResult result);

Future<void> launchSizeGuide(
  BuildContext context,
  List<String> availableSizes,
  SizeGuideResultHandler onResult,
) async {
  final result = await Navigator.push<SizeGuideResult>(
    context,
    MaterialPageRoute(
      builder: (_) => SizeGuideFlowScreen(availableSizes: availableSizes),
    ),
  );
  if (!context.mounted || result == null) return;
  onResult(result);
}

/// A single selectable size chip (selection state injected by parent →
/// pure presentational widget, easily testable/reusable).
class SizeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SizeChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}

/// "Select Size" section: chips row + "Find my size" CTA + measurement hint.
class GownSizeSelector extends StatelessWidget {
  final GownModel gown;
  final int selectedIndex;
  final ValueChanged<int> onSizeSelected;
  final SizeGuideResult? sizeGuideResult;
  final ValueChanged<SizeGuideResult> onSizeGuideResult;

  const GownSizeSelector({
    super.key,
    required this.gown,
    required this.selectedIndex,
    required this.onSizeSelected,
    required this.sizeGuideResult,
    required this.onSizeGuideResult,
  });

  @override
  Widget build(BuildContext context) {
    final recommendation =
        sizeGuideResult?.recommendedSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Size',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: gown.sizes.asMap().entries.map((entry) {
            return SizeChip(
              label: entry.value,
              isSelected: selectedIndex == entry.key,
              onTap: () => onSizeSelected(entry.key),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () =>
              launchSizeGuide(context, gown.sizes, onSizeGuideResult),
          icon: const Icon(Icons.straighten_rounded, size: 18),
          label: Text(recommendation == null
              ? 'Find my size'
              : 'Size guide: $recommendation'),
        ),
        if (sizeGuideResult != null) ...[
          const SizedBox(height: 8),
          Text(
            'Recommended from your measurements: '
            '${sizeGuideResult!.measurements.bust.toStringAsFixed(0)} '
            '${sizeGuideResult!.measurements.unit} bust, '
            '${sizeGuideResult!.measurements.waist.toStringAsFixed(0)} '
            '${sizeGuideResult!.measurements.unit} waist, '
            '${sizeGuideResult!.measurements.hips.toStringAsFixed(0)} '
            '${sizeGuideResult!.measurements.unit} hips',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ],
    );
  }
}
