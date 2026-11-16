import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/gown_model.dart';
import 'gown_visuals.dart';

/// Compact identity header: category avatar, title, rating, active color.
class GownHeader extends StatelessWidget {
  final GownModel gown;
  final int selectedColorIndex;

  const GownHeader({
    super.key,
    required this.gown,
    required this.selectedColorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorName = gown.colors[selectedColorIndex];
    final chipColor = GownVisuals.chipColorFor(colorName);
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.champagneMid.withValues(alpha: 0.5),
          ),
          child: Icon(
            GownVisuals.iconForCategory(gown.category),
            size: 40,
            color: AppColors.champagneDark.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gown.name,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${gown.rating}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    ' (${gown.rentalCount})',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: chipColor, width: 1),
                ),
                child: Text(
                  'Color: $colorName',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: chipColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Status badges ("NEW ARRIVAL" / "Currently Rented").
class GownBadges extends StatelessWidget {
  final GownModel gown;
  const GownBadges({super.key, required this.gown});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (gown.isNew) ...[
          const SizedBox(height: 8),
          _Badge(
            gradient: AppColors.primaryGradient,
            text: 'NEW ARRIVAL',
            textStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
        if (!gown.isAvailable) ...[
          const SizedBox(height: 8),
          _Badge(
            background: AppColors.warning.withValues(alpha: 0.12),
            borderColor: AppColors.warning.withValues(alpha: 0.3),
            text: 'Currently Rented',
            textStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Gradient? gradient;
  final Color? background;
  final Color? borderColor;

  const _Badge({
    required this.text,
    required this.textStyle,
    this.gradient,
    this.background,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(text, style: textStyle),
    );
  }
}

/// Category / style tags plus the rating summary row.
class GownTagsRow extends StatelessWidget {
  final GownModel gown;
  const GownTagsRow({super.key, required this.gown});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            gown.category.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            gown.style,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.darkGray,
            ),
          ),
        ),
        const Spacer(),
        const Icon(Icons.star_rounded, size: 18, color: AppColors.primaryLight),
        const SizedBox(width: 4),
        Text(
          '${gown.rating}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        Text(
          ' (${gown.rentalCount})',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }
}
