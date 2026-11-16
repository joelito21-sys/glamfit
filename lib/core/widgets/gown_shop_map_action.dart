import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/gown_model.dart';
import '../../screens/map/gown_shop_map_screen.dart';
import '../location/location_helper.dart';
import '../theme/app_colors.dart';

class GownShopMapAction {
  static void open(BuildContext context, GownModel gown) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GownShopMapScreen(gown: gown)),
    );
  }

  static String? distanceLabel(GownModel gown, {double? userLat, double? userLng}) {
    double? km = gown.distanceKm;
    if (km == null && userLat != null && userLng != null && gown.hasShopLocation) {
      km = LocationHelper.distanceKm(
        lat1: userLat,
        lng1: userLng,
        lat2: gown.companyLatitude!,
        lng2: gown.companyLongitude!,
      );
    }
    if (km == null) return null;
    return LocationHelper.formatDistance(km);
  }
}

class GownMapIconButton extends StatelessWidget {
  final GownModel gown;
  final Color? color;
  final double size;

  const GownMapIconButton({super.key, required this.gown, this.color, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final canMap = gown.hasShopLocation ||
        (gown.companyName?.isNotEmpty ?? false) ||
        (gown.companyAddress?.isNotEmpty ?? false);
    return IconButton(
      onPressed: canMap ? () => GownShopMapAction.open(context, gown) : null,
      icon: Icon(Icons.map_outlined, size: size),
      color: color ?? AppColors.roseRed,
      tooltip: 'View shop on map',
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

class GownDistanceChip extends StatelessWidget {
  final GownModel gown;
  final double? userLat;
  final double? userLng;
  final bool compact;

  const GownDistanceChip({
    super.key,
    required this.gown,
    this.userLat,
    this.userLng,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = GownShopMapAction.distanceLabel(gown, userLat: userLat, userLng: userLng);
    if (label == null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 3 : 4),
      decoration: BoxDecoration(
        color: AppColors.roseRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_rounded, size: compact ? 12 : 14, color: AppColors.roseRed),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: AppColors.roseRed,
            ),
          ),
        ],
      ),
    );
  }
}
