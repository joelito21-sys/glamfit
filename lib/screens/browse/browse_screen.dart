import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/state/favorites_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../core/widgets/gown_shop_map_action.dart';
import '../../core/widgets/gown_image.dart';
import '../../data/gown_catalog.dart';
import '../../models/gown_model.dart';
import '../detail/gown_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'Popular';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GownCatalog.instance.addListener(_onCatalogChanged);
    unawaited(GownCatalog.instance.load());
  }

  void _onCatalogChanged() {
    if (mounted) setState(() {});
  }

  List<GownModel> get _filteredGowns {
    var gowns = GownCatalog.instance.gowns.toList();
    if (_selectedCategory != 'All') {
      gowns = gowns.where((g) => g.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      gowns = gowns
          .where(
            (g) =>
                g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                g.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                g.designer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                g.style.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    switch (_sortBy) {
      case 'Price: Low':
        gowns.sort((a, b) => a.rentalPrice.compareTo(b.rentalPrice));
        break;
      case 'Price: High':
        gowns.sort((a, b) => b.rentalPrice.compareTo(a.rentalPrice));
        break;
      case 'Rating':
        gowns.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Popular':
      default:
        gowns.sort((a, b) => b.rentalCount.compareTo(a.rentalCount));
    }
    return gowns;
  }

  @override
  void dispose() {
    GownCatalog.instance.removeListener(_onCatalogChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredGowns = _filteredGowns;
    return Scaffold(
      backgroundColor: AppColors.blushPink,
      body: Stack(
        children: [
          // Ambient glow
          const Positioned(
            top: -60,
            left: -40,
            child: GoldGlow(size: 200, opacity: 0.08),
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
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.glassWhite,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.charcoal),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Gown Catalog',
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
                const SizedBox(height: 16),

                // ── Search Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    blur: 10,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.charcoal),
                      decoration: InputDecoration(
                        hintText: 'Search gowns...',
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.mediumGray),
                        prefixIcon: const Icon(Icons.search_rounded, size: 22, color: AppColors.roseRed),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20, color: AppColors.mediumGray),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Category Chips ──
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      'All',
                      ...GownCatalog.instance.categories.map((c) => c.name),
                    ].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.primaryGradient : null,
                              color: isSelected ? null : AppColors.glassWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.deepRose
                                    : AppColors.lightPink.withValues(alpha: 0.9),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.ivory : AppColors.softGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Sort Row ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.sort_rounded, size: 16, color: AppColors.mediumGray),
                      const SizedBox(width: 6),
                      Text('Sort:', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGray)),
                      const SizedBox(width: 8),
                      ...['Popular', 'Price: Low', 'Price: High', 'Rating'].map((sort) {
                        final isActive = _sortBy == sort;
                        return GestureDetector(
                          onTap: () => setState(() => _sortBy = sort),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.roseRed.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sort,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                color: isActive ? AppColors.roseRed : AppColors.mediumGray,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Grid ──
                Expanded(
                  child: GownCatalog.instance.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.roseRed,
                          ),
                        )
                      : GownCatalog.instance.error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_off_rounded, size: 36, color: AppColors.mediumGray),
                                const SizedBox(height: 12),
                                Text(
                                  GownCatalog.instance.error!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(color: AppColors.mediumGray),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () => unawaited(GownCatalog.instance.load(refresh: true)),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredGowns.isEmpty
                      ? const EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No gowns found',
                          subtitle: 'Try adjusting your search or filters',
                        )
                      : RefreshIndicator(
                          color: AppColors.roseRed,
                          backgroundColor: AppColors.ivory,
                          onRefresh: () => GownCatalog.instance.load(refresh: true),
                          child: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.62,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: filteredGowns.length,
                            itemBuilder: (context, index) {
                              final gown = filteredGowns[index];
                              return _CatalogCard(
                                gown: gown,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => GownDetailScreen(gown: gown)),
                                  );
                                },
                              );
                            },
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
}

class _CatalogCard extends StatelessWidget {
  final GownModel gown;
  final VoidCallback onTap;

  const _CatalogCard({required this.gown, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesScope.of(context);
    final isFav = favorites.isFavorite(gown.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.rosePink.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: GownImage(
                      imagePath: gown.images.isNotEmpty ? gown.images.first : '',
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => favorites.toggle(gown.id),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.ivory.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 17,
                          color: isFav ? AppColors.roseRed : AppColors.mediumGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
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
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                    if (gown.distanceKm != null || gown.hasShopLocation) ...[
                      const SizedBox(height: 2),
                      GownDistanceChip(gown: gown, compact: true),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₱${gown.rentalPrice.toStringAsFixed(0)}',
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
                        const Spacer(),
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.champagneGold),
                        const SizedBox(width: 2),
                        Text(
                          gown.rating.toStringAsFixed(1),
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

