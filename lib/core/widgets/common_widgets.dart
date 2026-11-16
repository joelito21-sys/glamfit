import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../../models/gown_model.dart';
import 'glass_widgets.dart';
import 'gown_image.dart';
import 'gown_shop_map_action.dart';

class GoldButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;
  final double? width;

  const GoldButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.width,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  bool get _enabled => !widget.isLoading && widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOutlined) {
      // Use the luxury gold gradient button
      return LuxuryGoldButton(
        text: widget.text,
        onPressed: widget.onPressed,
        isLoading: widget.isLoading,
        icon: widget.icon,
        showArrow: false,
        width: widget.width,
      );
    }

    final child = widget.isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.roseRed,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: AppColors.roseRed),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.roseRed,
                ),
              ),
            ],
          );

    return SizedBox(
      width: widget.width ?? double.infinity,
      child: GestureDetector(
        onTapDown: (_) {
          if (_enabled) _pressController.forward();
        },
        onTapUp: (_) => _pressController.reverse(),
        onTapCancel: _pressController.reverse,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: OutlinedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.roseRed, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.roseRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.roseRed.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, color: AppColors.roseRed, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.mediumGray),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
            if (action == null && actionText != null && onAction != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: 200,
                child: GoldButton(text: actionText!, onPressed: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GownCard extends StatelessWidget {
  final dynamic gown;
  final VoidCallback? onTap;

  const GownCard({super.key, required this.gown, this.onTap});

  String _resolveImagePath(dynamic g) {
    try {
      final images = g.images;
      if (images is List && images.isNotEmpty) {
        final first = images.first?.toString() ?? '';
        if (first.trim().isNotEmpty) return first.trim();
      }
    } catch (_) {}
    try {
      final url = g.imageUrl?.toString() ?? '';
      if (url.trim().isNotEmpty) return url.trim();
    } catch (_) {}
    try {
      final url = g.image_url?.toString() ?? g.image?.toString() ?? '';
      if (url.trim().isNotEmpty) return url.trim();
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.rosePink.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.rosePink.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: SizedBox(
                width: double.infinity,
                child: GownImage(imagePath: _resolveImagePath(gown)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gown.name ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: (gown is GownModel && ((gown as GownModel).companyName?.isNotEmpty ?? false))
                              ? Text(
                                  (gown as GownModel).companyName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(fontSize: 10, color: AppColors.mediumGray),
                                )
                              : const SizedBox.shrink(),
                        ),
                        if (gown is GownModel)
                          GownMapIconButton(gown: gown as GownModel, size: 18),
                      ],
                    ),
                    if (gown is GownModel) ...[
                      const SizedBox(height: 2),
                      GownDistanceChip(gown: gown as GownModel, compact: true),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₱${gown.rentalPrice ?? 0}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.roseRed,
                          ),
                        ),
                        Text(
                          ' /day',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.champagneGold),
                        const SizedBox(width: 3),
                        Text(
                          '${gown.rating ?? 0}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.softGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GownPromoPrice extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final double? promotionalPrice;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final double fontSize;
  final double originalFontSize;

  const GownPromoPrice({
    super.key,
    required this.price,
    this.originalPrice,
    this.promotionalPrice,
    this.startsAt,
    this.endsAt,
    this.fontSize = 15,
    this.originalFontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final active =
        originalPrice != null &&
        startsAt != null &&
        endsAt != null &&
        !now.isBefore(startsAt!) &&
        now.isBefore(endsAt!);
    final displayPrice = active
        ? (promotionalPrice ?? price)
        : (originalPrice ?? price);

    final formatter = NumberFormat('#,###');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (active)
          Text(
            '₱${formatter.format(originalPrice!)}',
            style: TextStyle(
              color: AppColors.mediumGray,
              fontSize: originalFontSize,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          '₱${formatter.format(displayPrice)}',
          style: TextStyle(
            color: AppColors.roseRed,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
