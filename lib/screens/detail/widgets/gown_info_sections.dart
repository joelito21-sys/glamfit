import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/gown_model.dart';

/// Title + designer + description block.
class GownDescriptionSection extends StatelessWidget {
  final GownModel gown;
  const GownDescriptionSection({super.key, required this.gown});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gown.name,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'by ${gown.designer}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.mediumGray,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Description',
          style: _sectionTitle,
        ),
        const SizedBox(height: 8),
        Text(
          gown.description,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.darkGray,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// Key/value facts (event type, style, designer, rental period).
class GownDetailsTable extends StatelessWidget {
  final GownModel gown;
  const GownDetailsTable({super.key, required this.gown});

  static const _items = <_RowSpec>[
    _RowSpec('Event Type', Icons.event_rounded),
    _RowSpec('Style', Icons.style_rounded),
    _RowSpec('Designer', Icons.brush_rounded),
    _RowSpec('Rental Period', Icons.timer_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final (index, spec) in _items.indexed) ...[
            _DetailRow(
              icon: spec.icon,
              label: spec.label,
              value: _valueFor(spec.label),
            ),
            if (index < _items.length - 1) const Divider(height: 20),
          ],
        ],
      ),
    );
  }

  String _valueFor(String label) => switch (label) {
        'Event Type' => gown.eventType,
        'Style' => gown.style,
        'Designer' => gown.designer,
        'Rental Period' => '${gown.rentalDays} days',
        _ => '',
      };
}

class _RowSpec {
  final String label;
  final IconData icon;
  const _RowSpec(this.label, this.icon);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.mediumGray),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}

/// Included accessories as check chips.
class GownAccessoriesSection extends StatelessWidget {
  final List<String> accessories;
  const GownAccessoriesSection({super.key, required this.accessories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Included Accessories', style: _sectionTitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: accessories
              .map(
                (acc) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        acc,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Care-instructions notice box.
class GownCareNotice extends StatelessWidget {
  final String instructions;
  const GownCareNotice({super.key, required this.instructions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Care Instructions',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  instructions,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle get _sectionTitle => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.charcoal,
    );
