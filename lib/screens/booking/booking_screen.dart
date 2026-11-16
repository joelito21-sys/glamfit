import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/gown_image.dart';
import '../../models/gown_model.dart';
import '../auth/auth_flow_screen.dart';
import '../payment/payment_upload_screen.dart';

/// Screen 5: Booking — calendar-based rental date selection and summary.
/// Connects to the existing Laravel `POST /rentals` endpoint via payment flow.
class BookingScreen extends StatefulWidget {
  final GownModel gown;
  final String selectedSize;

  const BookingScreen({super.key, required this.gown, this.selectedSize = 'M'});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _rentalDays = 3;
  bool _isConfirming = false;

  double get _dailyPrice => widget.gown.effectiveRentalPrice;
  double get _rentalFee => _dailyPrice * _rentalDays;
  double get _total => _rentalFee + widget.gown.depositAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blushPink,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.roseRed.withValues(alpha: 0.12),
                    AppColors.roseRed.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Pressable(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.glassWhite,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16, color: AppColors.charcoal),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Booking',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Gown preview card ──
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.ivory,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.rosePink.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: 86,
                                  height: 108,
                                  child: GownImage(
                                    imagePath: widget.gown.images.isNotEmpty
                                        ? widget.gown.images.first
                                        : '',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.gown.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₱${NumberFormat('#,###').format(_dailyPrice)} /day',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.roseRed,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.successLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.gown.isAvailable
                                            ? 'Available'
                                            : 'Currently Rented',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: widget.gown.isAvailable
                                              ? AppColors.success
                                              : AppColors.warning,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Rental dates ──
                        Text(
                          'Select Rental Dates',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _dateField(
                                label: 'Start date',
                                value: _startDate,
                                icon: Icons.calendar_today_rounded,
                                onTap: () => _pickDate(isStart: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dateField(
                                label: 'End date',
                                value: _endDate,
                                icon: Icons.event_available_rounded,
                                onTap: () => _pickDate(isStart: false),
                              ),
                            ),
                          ],
                        ),

                        // ── Mini calendar strip ──
                        const SizedBox(height: 20),
                        _buildCalendarStrip(),
                        const SizedBox(height: 24),

                        // ── Rental period summary ──
                        Text(
                          'Rental Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.ivory,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.rosePink.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _summaryRow('Rental period',
                                  '${_startDate != null ? DateFormat('MMM d').format(_startDate!) : '—'} — ${_endDate != null ? DateFormat('MMM d, yyyy').format(_endDate!) : '—'}'),
                              const SizedBox(height: 10),
                              _summaryRow('Duration',
                                  '$_rentalDays day${_rentalDays > 1 ? 's' : ''}'),
                              const SizedBox(height: 10),
                              _summaryRow('Size', widget.selectedSize),
                              const SizedBox(height: 14),
                              Divider(color: AppColors.lightGray),
                              const SizedBox(height: 10),
                              _summaryRow('Rental fee',
                                  '₱${NumberFormat('#,###').format(_rentalFee)}'),
                              const SizedBox(height: 8),
                              _summaryRow('Security deposit',
                                  '₱${NumberFormat('#,###').format(widget.gown.depositAmount)}'),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Amount',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ivory,
                                      ),
                                    ),
                                    Text(
                                      '₱${NumberFormat('#,###').format(_total)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ivory,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        GoldButton(
                          text: 'Confirm Booking',
                          icon: Icons.check_circle_outline_rounded,
                          isLoading: _isConfirming,
                          onPressed: _startDate == null || _endDate == null
                              ? null
                              : _confirmBooking,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value != null ? AppColors.roseRed : AppColors.lightGray,
            width: value != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: AppColors.roseRed),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value != null ? DateFormat('MMM d, yyyy').format(value) : 'Select',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: value != null ? AppColors.charcoal : AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    final today = DateTime.now();
    final days = List.generate(14, (i) => today.add(Duration(days: i + 1)));
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelectedStart = _startDate != null &&
              _sameDay(day, _startDate!);
          final isSelectedEnd =
              _endDate != null && _sameDay(day, _endDate!);
          final isSelected = isSelectedStart || isSelectedEnd;
          return GestureDetector(
            onTap: () {
              if (_startDate == null ||
                  (_startDate != null && _endDate != null)) {
                setState(() {
                  _startDate = day;
                  _endDate = null;
                  _rentalDays = 3;
                });
              } else if (!day.isBefore(_startDate!)) {
                final diff = day.difference(_startDate!).inDays + 1;
                setState(() {
                  _endDate = day;
                  _rentalDays = diff < 1 ? 1 : diff;
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.ivory,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.deepRose
                      : AppColors.rosePink.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rosePink.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day).toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.ivory.withValues(alpha: 0.8)
                          : AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.ivory : AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.softGray,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now().add(const Duration(days: 1)))
          : (_endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 2))),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: AppColors.roseRed),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;
    if (isStart) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) _endDate = null;
        _rentalDays = 3;
      });
    } else if (_startDate != null && !date.isBefore(_startDate!)) {
      setState(() {
        _endDate = date;
        _rentalDays = date.difference(_startDate!).inDays + 1;
      });
    }
  }

  Future<void> _confirmBooking() async {
    final loggedIn = await AuthGate.requireLogin(
      context,
      prompt: 'Sign in to confirm your booking',
    );
    if (!loggedIn || !mounted) return;
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isConfirming = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentUploadScreen(
          bookingRef: 'NEW-${DateFormat('yyyyMMdd').format(DateTime.now())}',
          gownName: widget.gown.name,
          amount: _total,
          paymentType: 'Rental Booking',
        ),
      ),
    );
  }
}

