import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_session.dart';
import '../../core/state/favorites_store.dart';
import '../../core/state/notification_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../core/location/location_helper.dart';
import '../../core/widgets/gown_shop_map_action.dart';
import '../../core/widgets/gown_image.dart';
import '../../data/gown_catalog.dart';
import '../auth/auth_flow_screen.dart';
import '../bookings/bookings_screen.dart';
import '../detail/gown_detail_screen.dart';
import '../history/rental_history_screen.dart';
import '../measurements/measurements_screen.dart';
import '../notifications/notifications_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentPromo = 0;
  final PageController _promoController = PageController(viewportFraction: 0.92);
  Timer? _promoTimer;
  final NotificationStore _notificationStore = NotificationStore.instance;

  @override
  void initState() {
    super.initState();
    GownCatalog.instance.addListener(_onCatalogChanged);
    _notificationStore.addListener(_onCatalogChanged);
    unawaited(GownCatalog.instance.load());
    _startPromoTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadNotificationsForSession();
      if (mounted) _loadDistanceAwareCatalog();
    });
  }

  Future<void> _loadDistanceAwareCatalog() async {
    final pos = await LocationHelper.getCurrentPosition();
    if (!mounted || pos == null) return;
    await GownCatalog.instance.refreshWithLocation(
      userLat: pos.latitude,
      userLng: pos.longitude,
    );
  }

  void _onCatalogChanged() {
    if (mounted) setState(() {});
  }

  void _loadNotificationsForSession() {
    final token = AuthScope.read(context).accessToken;
    unawaited(_notificationStore.load(token));
  }

  @override
  void dispose() {
    GownCatalog.instance.removeListener(_onCatalogChanged);
    _notificationStore.removeListener(_onCatalogChanged);
    _promoTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  void _openNotifications() {
    final token = AuthScope.read(context).accessToken;
    if (token != null) unawaited(_notificationStore.load(token));
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _HomeMenuSheet(),
    );
  }

  void _startPromoTimer() {
    _promoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_promoController.hasClients) return;
      final gowns = GownCatalog.instance.gowns;
      final promoCount = gowns.where((g) => g.isFeatured || g.isNew).length.clamp(1, 5);
      final next = (_currentPromo + 1) % promoCount;
      _promoController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context);
    final gowns = GownCatalog.instance.gowns;
    final featured = gowns.where((g) => g.isFeatured).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          // Ambient rose glow
          const Positioned(
            top: -80,
            right: -60,
            child: GoldGlow(size: 260, opacity: 0.1),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.goldSoft.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          RefreshIndicator(
            color: AppColors.roseRed,
            backgroundColor: AppColors.ivory,
            onRefresh: () => GownCatalog.instance.load(refresh: true),
            child: CustomScrollView(
              slivers: [
                // ── App Bar ──
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  toolbarHeight: 72,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.lightPink.withValues(alpha: 0.95),
                              AppColors.blushPink.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
                            child: Row(
                              children: [
                                // Menu icon
                                Pressable(
                                  onTap: _openMenu,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.glassWhite,
                                      border: Border.all(color: AppColors.glassBorder),
                                    ),
                                    child: const Icon(Icons.menu_rounded, size: 20, color: AppColors.charcoal),
                                  ),
                                ),
                                const Spacer(),
                                // Brand
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [AppColors.goldShimmer, AppColors.champagneGold, AppColors.metallicGold],
                                  ).createShader(bounds),
                                  child: Text(
                                    'GlamFit',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Notification bell
                                Pressable(
                                  onTap: _openNotifications,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.glassWhite,
                                      border: Border.all(color: AppColors.glassBorder),
                                    ),
                                    child: Stack(
                                      children: [
                                        const Center(
                                          child: Icon(Icons.notifications_outlined, size: 20, color: AppColors.textBlack),
                                        ),
                                        if (_notificationStore.unreadCount > 0)
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              constraints: const BoxConstraints(minWidth: 16),
                                              decoration: const BoxDecoration(
                                                color: AppColors.roseRed,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _notificationStore.unreadCount > 9 ? '9+' : '${_notificationStore.unreadCount}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
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

                // ── Loading/Error ──
                if (GownCatalog.instance.isLoading)
                  SliverToBoxAdapter(
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.roseRed,
                      backgroundColor: AppColors.roseRed.withValues(alpha: 0.1),
                    ),
                  )
                else if (GownCatalog.instance.error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Could not load catalog: ${GownCatalog.instance.error}',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error),
                              ),
                            ),
                            TextButton(
                              onPressed: () => unawaited(GownCatalog.instance.load(refresh: true)),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Welcome ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text(
                      session.isLoggedIn
                          ? 'Welcome back, ${session.displayName}'
                          : 'Find your perfect gown',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),

                // ── Hero Banner ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _HeroBanner(
                      gowns: featured.isNotEmpty ? featured : gowns.take(3).toList(),
                      promoController: _promoController,
                      currentPromo: _currentPromo,
                      onPageChanged: (i) => setState(() => _currentPromo = i),
                      onBrowse: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                      },
                    ),
                  ),
                ),

                // ── Quick Nav Row ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _QuickNavItem(icon: Icons.diamond_outlined, label: 'Premium', onTap: () {}),
                        _QuickNavItem(icon: Icons.calendar_month_outlined, label: 'Book Now', onTap: () {}),
                        _QuickNavItem(icon: Icons.local_offer_outlined, label: 'Promo', onTap: () {}),
                        _QuickNavItem(icon: Icons.favorite_outline_rounded, label: 'Favorites', onTap: () {}),
                      ],
                    ),
                  ),
                ),

                // ── Featured Gowns Section ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Gowns',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                        Pressable(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                          child: Row(
                            children: [
                              Text(
                                'See All',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.roseRed,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textBlack),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Featured Grid ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      final columns = width >= 520 ? 3 : 2;
                      const spacing = 14.0;
                      final itemWidth = (width - (spacing * (columns - 1))) / columns;
                      final items = gowns.isNotEmpty
                          ? gowns
                          : const <dynamic>[null, null, null, null];

                      return SliverToBoxAdapter(
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final gown in items)
                              SizedBox(
                                width: itemWidth,
                                child: gown == null
                                    ? const _GownLoadingCard()
                                    : _GownCard(gown: gown),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom padding for nav bar
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final List<dynamic> gowns;
  final PageController promoController;
  final int currentPromo;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBrowse;

  const _HeroBanner({
    required this.gowns,
    required this.promoController,
    required this.currentPromo,
    required this.onPageChanged,
    required this.onBrowse,
  });

  String _imageOf(dynamic gown) {
    try {
      final imgs = gown?.images as List?;
      if (imgs != null) {
        for (final v in imgs) {
          final s = v?.toString().trim() ?? '';
          if (s.isNotEmpty) return s;
        }
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final slides = gowns.isEmpty
        ? const <dynamic>[null]
        : gowns.take(5).toList();
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: promoController,
            itemCount: slides.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final gown = slides[index];
              final image = gown == null ? '' : _imageOf(gown);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.roseRed, AppColors.deepRose],
                  ),
                  border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.roseRed.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (image.isNotEmpty)
                        GownImage(imagePath: image, fit: BoxFit.cover)
                      else
                        const Center(
                          child: Icon(Icons.checkroom_rounded, size: 60, color: Colors.white38),
                        ),
                      // Dark gradient scrim for legibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.metallicGold.withValues(alpha: 0.5),
                              Colors.transparent,
                              AppColors.darkGoldLine.withValues(alpha: 0.6),
                            ],
                            stops: const [0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Elegant Gowns\nfor Every Occasion',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textBlack,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rent in style, feel amazing.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textBlack.withValues(alpha: 0.75),
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: SizedBox(
                                width: 180,
                                height: 44,
                                child: LuxuryGoldButton(
                                  text: 'Browse Collection',
                                  fontSize: 13,
                                  showArrow: true,
                                  onPressed: onBrowse,
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
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: currentPromo == i ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: currentPromo == i
                    ? AppColors.metallicGold
                    : AppColors.metallicGold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.glassWhite,
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.metallicGold.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.textBlack, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _GownCard extends StatelessWidget {
  final dynamic gown;

  const _GownCard({required this.gown});

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesScope.of(context);
    final isFav = favorites.isFavorite(gown.id);
    final formatter = NumberFormat('#,###');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GownDetailScreen(gown: gown)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.roseRed.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: AspectRatio(
                    aspectRatio: 0.84,
                    child: GownImage(
                      imagePath: (() {
                        try {
                          final imgs = gown.images as List?;
                          if (imgs != null) {
                            for (final v in imgs) {
                              final s = v?.toString().trim() ?? '';
                              if (s.isNotEmpty) return s;
                            }
                          }
                        } catch (_) {}
                        return '';
                      })(),
                    ),
                  ),
                ),
                // Wishlist heart
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => favorites.toggle(gown.id),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.ivory.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.5)),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFav ? AppColors.metallicGold : AppColors.textMid,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gown.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₱${formatter.format(gown.effectiveRentalPrice)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        ' /day',
                        style: GoogleFonts.poppins(fontSize: 10, color: AppColors.mediumGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.champagneGold),
                      const SizedBox(width: 3),
                      Text(
                        '${gown.rating}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
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
    );
  }
}

class _GownLoadingCard extends StatelessWidget {
  const _GownLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.goldSoft.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.darkGoldLine.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
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


/// Slide-up menu opened from the hamburger button on the Home app bar.
/// Provides quick navigation to sections that live outside the bottom nav.
class _HomeMenuSheet extends StatelessWidget {
  const _HomeMenuSheet();

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.rosePink.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Menu',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 14),
            _MenuItem(
              icon: Icons.calendar_month_rounded,
              label: 'My Bookings',
              onTap: () => _popAndPush(context, const BookingsScreen()),
            ),
            _MenuItem(
              icon: Icons.history_rounded,
              label: 'Rental History',
              onTap: () => _popAndPush(context, const RentalHistoryScreen()),
            ),
            _MenuItem(
              icon: Icons.straighten_rounded,
              label: 'Measurements & Size Guide',
              onTap: () => _popAndPush(context, const MeasurementsScreen()),
            ),
            _MenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              badge: NotificationStore.instance.unreadCount,
              onTap: () => _popAndPush(context, const NotificationsScreen()),
            ),
            _MenuItem(
              icon: Icons.message_outlined,
              label: 'Message',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Messages are coming soon.')),
                );
              },
            ),
            _MenuItem(
              icon: session.isLoggedIn
                  ? Icons.logout_rounded
                  : Icons.login_rounded,
              label: session.isLoggedIn ? 'Sign Out' : 'Sign In',
              isDestructive: session.isLoggedIn,
              onTap: () async {
                Navigator.pop(context);
                if (session.isLoggedIn) {
                  await session.logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out')),
                    );
                  }
                } else {
                  AuthGate.requireLogin(
                    context,
                    prompt: 'Sign in to continue',
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _popAndPush(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.roseRed : AppColors.charcoal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: AppColors.lightPink.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.roseRed.withValues(alpha: 0.12)
                        : AppColors.champagneGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.roseRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.rosePink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
