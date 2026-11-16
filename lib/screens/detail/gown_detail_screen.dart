import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gown_shop_map_action.dart';
import '../../../models/gown_model.dart';
import '../size_guide/size_guide_flow_screen.dart';
import 'widgets/gown_app_bar.dart';
import 'widgets/gown_carousel.dart';
import 'widgets/gown_color_selector.dart';
import 'widgets/gown_header.dart';
import 'widgets/gown_info_sections.dart';
import 'widgets/gown_media.dart';
import 'widgets/gown_price_panel.dart';
import 'widgets/gown_size_selector.dart';

/// Detail screen for a single gown.
///
/// Acts purely as a composition root: state lives here, presentation
/// lives in the widgets under `widgets/`, and domain mapping lives in
/// `GownVisuals` / `GownMedia` / `GownModel` (SRP throughout).
class GownDetailScreen extends StatefulWidget {
  final GownModel gown;
  const GownDetailScreen({super.key, required this.gown});

  @override
  State<GownDetailScreen> createState() => _GownDetailScreenState();
}

class _GownDetailScreenState extends State<GownDetailScreen> {
  int _selectedSizeIndex = 0;
  int _selectedColorIndex = 0;
  SizeGuideResult? _sizeGuideResult;

  GownModel get gown => widget.gown;

  void _onSizeGuideResult(SizeGuideResult result) {
    setState(() {
      _sizeGuideResult = result;
      final index = gown.sizes.indexOf(result.recommendedSize);
      if (index >= 0) _selectedSizeIndex = index;
    });
  }

  void _onRentPressed() {
    handleRentAction(context, gown, gown.sizes[_selectedSizeIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
      bottomSheet: GownRentBar(gown: gown, onRentPressed: _onRentPressed),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 440,
      pinned: true,
      backgroundColor: AppColors.blushPink,
      leading: CircleAppBarAction(
        onTap: () => Navigator.pop(context),
        icon: Icons.arrow_back_ios_new_rounded,
        iconColor: AppColors.charcoal,
      ),
      actions: [
        FavoriteAction(gownId: gown.id),
        if (gown.hasShopLocation || (gown.companyName?.isNotEmpty ?? false))
          CircleAppBarAction(
            onTap: () => GownShopMapAction.open(context, gown),
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            icon: Icons.map_outlined,
            iconColor: AppColors.charcoal,
          ),
        CircleAppBarAction(
          onTap: () {},
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          icon: Icons.share_outlined,
          iconColor: AppColors.charcoal,
        ),
        CircleAppBarAction(
          onTap: () => launchSizeGuide(context, gown.sizes, _onSizeGuideResult),
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          icon: Icons.straighten_rounded,
          iconColor: AppColors.charcoal,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.ivory, AppColors.blushPink],
            ),
          ),
          child: GownCarousel(
            images: GownMedia.carouselImages(gown, _selectedColorIndex),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GownHeader(
              gown: gown,
              selectedColorIndex: _selectedColorIndex,
            ),
            GownBadges(gown: gown),
            if (gown.companyName != null || gown.hasShopLocation) ...[
              const SizedBox(height: 12),
              _ShopLocationBanner(gown: gown),
            ],
            const SizedBox(height: 20),
            GownTagsRow(gown: gown),
            const SizedBox(height: 16),
            GownDescriptionSection(gown: gown),
            const SizedBox(height: 20),
            GownPricePanel(gown: gown),
            const SizedBox(height: 24),
            GownSizeSelector(
              gown: gown,
              selectedIndex: _selectedSizeIndex,
              onSizeSelected: (i) => setState(() => _selectedSizeIndex = i),
              sizeGuideResult: _sizeGuideResult,
              onSizeGuideResult: _onSizeGuideResult,
            ),
            const SizedBox(height: 24),
            GownColorSelector(
              gown: gown,
              selectedIndex: _selectedColorIndex,
              onColorSelected: (i) => setState(() => _selectedColorIndex = i),
            ),
            const SizedBox(height: 28),
            GownDetailsTable(gown: gown),
            const SizedBox(height: 24),
            GownAccessoriesSection(accessories: gown.accessories),
            const SizedBox(height: 24),
            GownCareNotice(instructions: gown.careInstructions),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _ShopLocationBanner extends StatelessWidget {
  final GownModel gown;
  const _ShopLocationBanner({required this.gown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.roseRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.store_mall_directory_rounded, color: AppColors.roseRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gown.companyName ?? 'GlamFit Shop',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                ),
                if ((gown.companyAddress ?? '').isNotEmpty)
                  Text(
                    gown.companyAddress!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGray),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GownDistanceChip(gown: gown),
                    if (gown.distanceKm == null)
                      Expanded(
                        child: Text(
                          gown.hasShopLocation ? 'Tap map to view location' : 'Location unavailable',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.mediumGray),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => GownShopMapAction.open(context, gown),
            icon: const Icon(Icons.map_outlined, color: AppColors.roseRed),
            tooltip: 'View on map',
          ),
        ],
      ),
    );
  }
}