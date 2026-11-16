import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/auth/auth_session.dart';
import '../../core/state/booking_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../core/widgets/gown_image.dart';
import '../../data/gown_catalog.dart';
import '../../models/booking_model.dart';

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({super.key});

  @override
  State<RentalHistoryScreen> createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String? _loadedToken;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
    BookingStore.instance.addListener(_refreshBookings);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = AuthScope.of(context).accessToken;
    if (token != null && token != _loadedToken) {
      _loadedToken = token;
      unawaited(BookingStore.instance.load(token));
    }
  }

  void _refreshBookings() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    BookingStore.instance.removeListener(_refreshBookings);
    _controller.dispose();
    super.dispose();
  }

  List<BookingModel> get _completedBookings {
    return BookingStore.instance.bookings
        .where((b) => b.status == BookingStatus.completed)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            const Positioned(
              top: -40,
              right: -60,
              child: GoldGlow(size: 200, opacity: 0.05),
            ),
            Positioned(
              bottom: 200,
              left: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.deepPurple.withValues(alpha: 0.2),
                      AppColors.deepPurple.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    leading: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: const EdgeInsets.only(left: 16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    title: Text(
                      'Rental History',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),

                  // Summary card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.glassGradient,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Row(
                              children: [
                                _summaryItem(
                                  '${_completedBookings.length}',
                                  'Total Rentals',
                                  Icons.checkroom_rounded,
                                ),
                                Container(
                                  width: 1,
                                  height: 44,
                                  color: AppColors.glassBorder,
                                ),
                                _summaryItem(
                                  '₱${_completedBookings.fold<double>(0, (sum, b) => sum + b.totalAmount).toStringAsFixed(0)}',
                                  'Total Spent',
                                  Icons.account_balance_wallet_rounded,
                                ),
                                Container(
                                  width: 1,
                                  height: 44,
                                  color: AppColors.glassBorder,
                                ),
                                _summaryItem(
                                    '4.8', 'Avg. Rating', Icons.star_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Past rentals
                  if (_completedBookings.isEmpty)
                    SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.history_rounded,
                        title: 'No Rental History',
                        subtitle: 'Your completed rentals will appear here',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final booking = _completedBookings[index];
                            return _HistoryCard(
                                booking: booking, index: index);
                          },
                          childCount: _completedBookings.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 60)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.champagneGold),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 9, color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final BookingModel booking;
  final int index;

  const _HistoryCard({required this.booking, required this.index});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _givenRating = 5;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 150)),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d, yyyy');
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.glassGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    // Top section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: 64,
                              height: 80,
                              child: GownImage(
                                imagePath: widget.booking.gownImage.isNotEmpty
                                    ? widget.booking.gownImage
                                    : (GownCatalog.instance.gowns
                                            .where((g) =>
                                                g.name ==
                                                widget.booking.gownName)
                                            .map((g) => g.images.isNotEmpty
                                                ? g.images.first
                                                : '')
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
                                Text(
                                  widget.booking.bookingRef,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.mediumGray,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.booking.gownName,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      size: 12,
                                      color: AppColors.mediumGray,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${df.format(widget.booking.rentalStart)} – ${df.format(widget.booking.rentalEnd)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppColors.softGray,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    StatusBadge(
                                      label: 'Completed',
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₱${widget.booking.totalAmount.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.champagneGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      color: AppColors.glassBorder,
                    ),
                    // Rating section
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Rating',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (i) {
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _givenRating = i + 1),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4),
                                      child: Icon(
                                        i < _givenRating
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        size: 22,
                                        color: i < _givenRating
                                            ? AppColors.champagneGold
                                            : AppColors.dimGray,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Pressable(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.goldButtonGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.repeat_rounded,
                                        size: 14,
                                        color: AppColors.midnightNavy,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Rent Again',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.midnightNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
