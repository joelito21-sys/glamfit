import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/state/favorites_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../core/widgets/gown_image.dart';
import '../../core/widgets/gown_shop_map_action.dart';
import '../../data/gown_catalog.dart';
import '../../models/gown_model.dart';
import '../detail/gown_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
    FavoritesStore.instance.addListener(_onFavoritesChanged);
    GownCatalog.instance.addListener(_onFavoritesChanged);
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    FavoritesStore.instance.removeListener(_onFavoritesChanged);
    GownCatalog.instance.removeListener(_onFavoritesChanged);
    _fadeController.dispose();
    super.dispose();
  }

  List<GownModel> get _wishlistGowns {
    final favStore = FavoritesStore.instance;
    return GownCatalog.instance.gowns
        .where((g) => favStore.isFavorite(g.id))
        .toList();
  }

  void _removeFromWishlist(GownModel gown) {
    FavoritesStore.instance.remove(gown.id);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite_border_rounded,
                color: AppColors.dustyRose, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${gown.name} removed from wishlist',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.charcoal),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.champagneGold,
          onPressed: () => FavoritesStore.instance.add(gown.id),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gowns = _wishlistGowns;
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // Ambient glows
            const Positioned(
              top: -60,
              right: -80,
              child: GoldGlow(size: 220, opacity: 0.06),
            ),
            Positioned(
              bottom: 100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.deepPurple.withValues(alpha: 0.25),
                      AppColors.deepPurple.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App bar
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    expandedHeight: 120,
                    flexibleSpace: FlexibleSpaceBar(
                      background: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Wishlist',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                gowns.isEmpty
                                    ? 'Save your favorite gowns here'
                                    : '${gowns.length} gown${gowns.length == 1 ? '' : 's'} saved',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.softGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      if (gowns.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () => _showClearAllDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.glassWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: Text(
                                'Clear All',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.dustyRose,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Content
                  if (gowns.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final gown = gowns[index];
                            return _WishlistCard(
                              key: ValueKey(gown.id),
                              gown: gown,
                              index: index,
                              onRemove: () => _removeFromWishlist(gown),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        GownDetailScreen(gown: gown),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: gowns.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated heart icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.rosePink.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.rosePink.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightPink,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 36,
                      color: AppColors.champagneGold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Your Wishlist is Empty',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the heart icon on any gown to\nsave it for later',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.mediumGray,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            LuxuryGoldButton(
              text: 'Browse Gowns',
              showArrow: true,
              onPressed: () {
                // Navigate to browse tab (index 1 in MainShell)
                final mainShell = context.findAncestorStateOfType<State>();
                if (mainShell != null) {
                  // fallback: just pop if we can't find the shell
                }
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Clear Wishlist',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          content: Text(
            'Are you sure you want to remove all gowns from your wishlist?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.softGray,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                    color: AppColors.mediumGray, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                for (final gown in _wishlistGowns) {
                  FavoritesStore.instance.remove(gown.id);
                }
                Navigator.pop(ctx);
              },
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                    color: AppColors.dustyRose, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistCard extends StatefulWidget {
  final GownModel gown;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _WishlistCard({
    super.key,
    required this.gown,
    required this.index,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 80)),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gown = widget.gown;
    final currencyFormat = NumberFormat('#,###');
    final isPromoActive = gown.isPromoActive;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: ValueKey(gown.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => widget.onRemove(),
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.transparent, Color(0xFF777777)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(height: 4),
                Text(
                  'Remove',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.glassGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        // Gown image
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(22),
                          ),
                          child: SizedBox(
                            width: 110,
                            height: 140,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                GownImage(
                                  imagePath: gown.images.isNotEmpty
                                      ? gown.images.first
                                      : '',
                                ),
                                // Category badge
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.midnightNavy
                                          .withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      gown.category,
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.champagneGold,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isPromoActive)
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.error
                                            .withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '-${gown.promoDiscountPercent}%',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gown.name,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.charcoal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'by ${gown.designer}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.mediumGray,
                                      ),
                                    ),
                                    if (gown.companyName != null || gown.hasShopLocation) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              gown.companyName ?? 'GlamFit Shop',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.mediumGray),
                                            ),
                                          ),
                                          GownMapIconButton(gown: gown, size: 18),
                                        ],
                                      ),
                                      if (gown.distanceKm != null || gown.hasShopLocation)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: GownDistanceChip(gown: gown, compact: true),
                                        ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Rating
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 14,
                                        color: AppColors.champagneGold),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${gown.rating}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${gown.rentalCount})',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppColors.mediumGray,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Availability
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: (gown.isAvailable
                                                ? AppColors.success
                                                : AppColors.error)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: (gown.isAvailable
                                                  ? AppColors.success
                                                  : AppColors.error)
                                              .withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Text(
                                        gown.isAvailable
                                            ? 'Available'
                                            : 'Rented',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: gown.isAvailable
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Price + action
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isPromoActive)
                                          Text(
                                            '₱${currencyFormat.format(gown.rentalPrice)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: AppColors.mediumGray,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline:
                                              TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              '₱${currencyFormat.format(gown.effectiveRentalPrice)}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    AppColors.champagneGold,
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
                                      ],
                                    ),
                                    // Remove button
                                    Pressable(
                                      onTap: widget.onRemove,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.dustyRose
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppColors.dustyRose
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.favorite_rounded,
                                          size: 18,
                                          color: AppColors.dustyRose,
                                        ),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
