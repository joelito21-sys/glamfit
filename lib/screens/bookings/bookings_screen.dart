import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/auth/auth_session.dart';
import '../../core/state/booking_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/gown_image.dart';
import '../../data/gown_catalog.dart';
import '../../models/booking_model.dart';
import '../auth/auth_flow_screen.dart';
import '../payment/payment_upload_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _loadedToken;
  final List<String> _tabs = ['Upcoming', 'History'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    BookingStore.instance.addListener(_refreshBookings);
  }

  void _refreshBookings() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = AuthScope.of(context).accessToken;
    if (token != null && token != _loadedToken) {
      _loadedToken = token;
      unawaited(BookingStore.instance.load(token));
    } else if (token == null && _loadedToken != null) {
      _loadedToken = null;
      BookingStore.instance.clear();
    }
  }

  @override
  void dispose() {
    BookingStore.instance.removeListener(_refreshBookings);
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> _getFilteredBookings(int tabIndex) {
    switch (tabIndex) {
      case 0: // Upcoming
        return BookingStore.instance.bookings
            .where(
              (b) =>
                  b.status == BookingStatus.pending ||
                  b.status == BookingStatus.approved ||
                  b.status == BookingStatus.awaitingPayment ||
                  b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.readyForPickup ||
                  b.status == BookingStatus.rentedOut,
            )
            .toList();
      case 1: // History
        return BookingStore.instance.bookings
            .where(
              (b) =>
                  b.status == BookingStatus.completed ||
                  b.status == BookingStatus.returned ||
                  b.status == BookingStatus.cancelled,
            )
            .toList();
      default:
        return BookingStore.instance.bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context);
    if (!session.isLoggedIn) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'My Rentals',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              Expanded(
                child: EmptyState(
                  icon: Icons.calendar_month_outlined,
                  title: 'Sign in to see bookings',
                  subtitle:
                      'Browse gowns as a guest. Create an account when you are ready to book.',
                  actionText: 'Sign In',
                  onAction: () => AuthGate.requireLogin(
                    context,
                    prompt: 'Sign in to view your bookings',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'My Rentals',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.mediumGray,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: _tabs.map((t) => Tab(text: t, height: 40)).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.asMap().entries.map((entry) {
                  final bookings = _getFilteredBookings(entry.key);
                  if (BookingStore.instance.isLoading && bookings.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (BookingStore.instance.error != null && bookings.isEmpty) {
                    return EmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Could not load bookings',
                      subtitle: BookingStore.instance.error!,
                      actionText: 'Retry',
                      onAction: () {
                        final token = AuthScope.read(context).accessToken;
                        if (token != null) {
                          unawaited(
                            BookingStore.instance.load(token, refresh: true),
                          );
                        }
                      },
                    );
                  }
                  if (bookings.isEmpty) {
                    return const EmptyState(
                      icon: Icons.calendar_month_outlined,
                      title: 'No bookings yet',
                      subtitle: 'Your rental bookings will appear here',
                      actionText: 'Browse Gowns',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _BookingCard(
                        booking: bookings[index],
                        onTap: () =>
                            _showBookingDetail(context, bookings[index]),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDetail(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailSheet(booking: booking),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const _BookingCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
            // Top row
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 52,
                    child: GownImage(
                      imagePath: booking.gownImage.isNotEmpty
                          ? booking.gownImage
                          : (GownCatalog.instance.gowns
                                    .where((g) => g.name == booking.gownName)
                                    .map(
                                      (g) => g.images.isNotEmpty
                                          ? g.images.first
                                          : '',
                                    )
                                    .where((p) => p.isNotEmpty)
                                    .cast<String?>()
                                    .firstWhere(
                                      (_) => true,
                                      orElse: () => null,
                                    ) ??
                                ''),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.gownName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(booking.bookingRef),
                    ],
                  ),
                ),
                StatusBadge(
                  label: booking.status.label,
                  color: _getStatusColor(booking.status),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Info row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _infoChip(
                    Icons.calendar_today_rounded,
                    '${DateFormat('MMM d').format(booking.rentalStart)} - ${DateFormat('MMM d').format(booking.rentalEnd)}',
                  ),
                  const SizedBox(width: 16),
                  _infoChip(Icons.straighten_rounded, booking.gownSize),
                  const SizedBox(width: 16),
                  _infoChip(Icons.access_time_rounded, '${booking.rentalDays} days'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.mediumGray,
                      ),
                    ),
                    Text(
                      '₱${NumberFormat('#,###').format(booking.totalAmount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.roseRed,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldButtonGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forest,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mediumGray),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.statusPending;
      case BookingStatus.approved:
        return AppColors.statusApproved;
      case BookingStatus.rejected:
        return AppColors.statusRejected;
      case BookingStatus.awaitingPayment:
        return AppColors.statusAwaitingPayment;
      case BookingStatus.confirmed:
        return AppColors.statusConfirmed;
      case BookingStatus.readyForPickup:
        return AppColors.statusReady;
      case BookingStatus.rentedOut:
        return AppColors.statusRented;
      case BookingStatus.returned:
        return AppColors.statusReturned;
      case BookingStatus.completed:
        return AppColors.statusCompleted;
      case BookingStatus.cancelled:
        return AppColors.statusCancelled;
      case BookingStatus.overdue:
        return AppColors.statusOverdue;
      case BookingStatus.inspectionPending:
        return AppColors.info;
    }
  }
}

class _BookingDetailSheet extends StatelessWidget {
  final BookingModel booking;
  const _BookingDetailSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Booking Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: booking.status.label,
                        color: _getStatusColor(booking.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Gown Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: 64,
                            child: GownImage(
                              imagePath: booking.gownImage.isNotEmpty
                                  ? booking.gownImage
                                  : (GownCatalog.instance.gowns
                                            .where(
                                              (g) => g.name == booking.gownName,
                                            )
                                            .map(
                                              (g) => g.images.isNotEmpty
                                                  ? g.images.first
                                                  : '',
                                            )
                                            .where((p) => p.isNotEmpty)
                                            .cast<String?>()
                                            .firstWhere(
                                              (_) => true,
                                              orElse: () => null,
                                            ) ??
                                        ''),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(booking.gownName),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _chip('Size ${booking.gownSize}'),
                                  const SizedBox(width: 6),
                                  _chip(booking.gownColor),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Details
                  _detailRow('Booking Reference', booking.bookingRef),
                  _detailRow(
                    'Rental Period',
                    '${DateFormat('MMM d, yyyy').format(booking.rentalStart)} â€” ${DateFormat('MMM d, yyyy').format(booking.rentalEnd)}',
                  ),
                  _detailRow('Duration', '${booking.rentalDays} days'),
                  _detailRow(
                    'Created',
                    DateFormat('MMM d, yyyy').format(booking.createdAt),
                  ),
                  if (booking.customerNotes != null)
                    _detailRow('Notes', booking.customerNotes!),

                  const SizedBox(height: 20),
                  // Payment section
                  Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.champagneMid.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        _paymentRow('Subtotal (Rental)', booking.subtotal),
                        const SizedBox(height: 8),
                        _paymentRow('Security Deposit', booking.deposit),
                        if (booking.discount > 0) ...[
                          const SizedBox(height: 8),
                          _paymentRow(
                            'Discount',
                            -booking.discount,
                            isDiscount: true,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Divider(
                          color: AppColors.lightGray.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 10),
                        _paymentRow(
                          'Total',
                          booking.totalAmount,
                          isTotal: true,
                        ),
                        const SizedBox(height: 8),
                        _paymentRow(
                          'Amount Paid',
                          booking.amountPaid,
                          isPaid: true,
                        ),
                        if (booking.outstandingBalance > 0) ...[
                          const SizedBox(height: 8),
                          _paymentRow(
                            'Outstanding',
                            booking.outstandingBalance,
                            isOutstanding: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Timeline
                  Text(
                    'Status Timeline',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatusTimeline(currentStatus: booking.status),
                  const SizedBox(height: 24),

                  // Actions
                  if (booking.outstandingBalance > 0)
                    GoldButton(
                      text:
                          'Pay Balance â€” â‚±${NumberFormat('#,###').format(booking.outstandingBalance)}',
                      icon: Icons.payment_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentUploadScreen(
                              bookingRef: booking.bookingRef,
                              gownName: booking.gownName,
                              amount: booking.outstandingBalance,
                              paymentType: 'Outstanding Balance',
                            ),
                          ),
                        );
                      },
                    ),
                  if (booking.status == BookingStatus.pending) ...[
                    const SizedBox(height: 10),
                    GoldButton(
                      text: 'Cancel Booking',
                      isOutlined: true,
                      icon: Icons.cancel_outlined,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGray,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.mediumGray,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _paymentRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isPaid = false,
    bool isOutstanding = false,
    bool isDiscount = false,
  }) {
    Color amountColor = AppColors.charcoal;
    if (isTotal) amountColor = AppColors.primary;
    if (isPaid) amountColor = AppColors.success;
    if (isOutstanding) amountColor = AppColors.warning;
    if (isDiscount) amountColor = AppColors.success;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? AppColors.charcoal : AppColors.darkGray,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}â‚±${NumberFormat('#,###').format(amount.abs())}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal || isOutstanding
                ? FontWeight.w700
                : FontWeight.w500,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.statusPending;
      case BookingStatus.approved:
        return AppColors.statusApproved;
      case BookingStatus.rejected:
        return AppColors.statusRejected;
      case BookingStatus.awaitingPayment:
        return AppColors.statusAwaitingPayment;
      case BookingStatus.confirmed:
        return AppColors.statusConfirmed;
      case BookingStatus.readyForPickup:
        return AppColors.statusReady;
      case BookingStatus.rentedOut:
        return AppColors.statusRented;
      case BookingStatus.returned:
        return AppColors.statusReturned;
      case BookingStatus.completed:
        return AppColors.statusCompleted;
      case BookingStatus.cancelled:
        return AppColors.statusCancelled;
      case BookingStatus.overdue:
        return AppColors.statusOverdue;
      case BookingStatus.inspectionPending:
        return AppColors.info;
    }
  }
}

class _StatusTimeline extends StatelessWidget {
  final BookingStatus currentStatus;
  const _StatusTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      BookingStatus.pending,
      BookingStatus.approved,
      BookingStatus.confirmed,
      BookingStatus.readyForPickup,
      BookingStatus.rentedOut,
      BookingStatus.returned,
      BookingStatus.completed,
    ];

    final currentIndex = steps.indexOf(currentStatus);
    final resolvedIndex = currentIndex == -1 ? 0 : currentIndex;

    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isCompleted = i <= resolvedIndex;
        final isCurrent = i == resolvedIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.lightGray,
                    border: isCurrent
                        ? Border.all(color: AppColors.primary, width: 3)
                        : null,
                  ),
                  child: isCompleted && !isCurrent
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 2,
                    color: isCompleted && !isCurrent
                        ? AppColors.primary
                        : AppColors.lightGray,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                step.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isCompleted
                      ? AppColors.charcoal
                      : AppColors.mediumGray,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}



