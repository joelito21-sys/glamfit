import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/gown_model.dart';
import '../../booking/booking_screen.dart';

/// Price & deposit panel.
///
/// The original computed `rentalPrice * (100 - discount) / 100` inline and
/// compared against the *list* price even when no promo was active,
/// contradicting the model's own `effectiveRentalPrice` / `isPromoActive`.
/// Delegating to the model keeps a single pricing rule (DRY + SRP).
class GownPricePanel extends StatelessWidget {
  final GownModel gown;
  const GownPricePanel({super.key, required this.gown});

  @override
  Widget build(BuildContext context) {
    final hasActivePromo = gown.isPromoActive;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.champagneMid.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rental Price',
                  style: _label,
                ),
                GownPromoPrice(
                  price: gown.rentalPrice,
                  originalPrice: hasActivePromo ? gown.rentalPrice : null,
                  promotionalPrice: hasActivePromo ? gown.effectiveRentalPrice : null,
                  startsAt: gown.promoStartsAt,
                  endsAt: gown.promoEndsAt,
                  fontSize: 26,
                  originalFontSize: 13,
                ),
                Text('for ${gown.rentalDays} days', style: _label),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.lightGray.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Security Deposit', style: _label),
                Text(
                  _formatPeso(gown.depositAmount),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                Text('refundable', style: _label),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _label => GoogleFonts.poppins(
        fontSize: 11,
        color: AppColors.mediumGray,
      );

  static String _formatPeso(double amount) =>
      '₱${NumberFormat('#,###').format(amount)}';
}

/// Sticky bottom bar: total + primary CTA.
class GownRentBar extends StatelessWidget {
  final GownModel gown;
  final VoidCallback onRentPressed;

  const GownRentBar({super.key, required this.gown, required this.onRentPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Rental',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.mediumGray,
                  ),
                ),
                Text(
                  '₱${NumberFormat('#,###').format(gown.effectiveRentalPrice + gown.depositAmount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoldButton(
              text: gown.isAvailable ? 'Rent Now' : 'Notify Me',
              icon: gown.isAvailable
                  ? Icons.calendar_today_rounded
                  : Icons.notifications_active_outlined,
              onPressed: onRentPressed,
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Rent Now" business rule, kept out of the widget tree so the
/// navigation decision lives in one testable place.
Future<void> handleRentAction(
  BuildContext context,
  GownModel gown,
  String selectedSize,
) async {
  if (!gown.isAvailable) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('We\'ll notify you when this gown becomes available!'),
      ),
    );
    return;
  }
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BookingScreen(gown: gown, selectedSize: selectedSize),
    ),
  );
}
