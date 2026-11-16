import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/location/location_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/gown_model.dart';

// Geoapify map tile configuration. The API key is required by Geoapify's free plan.
// Never commit this key to version control; inject via build environment or dart define.
const String _geoapifyApiKey = String.fromEnvironment('GEOAPIFY_API_KEY', defaultValue: '');
const String _geoapifyTileUrl = 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$_geoapifyApiKey';
const String _geoapifyAttribution = '&copy; <a href="https://www.geoapify.com/" target="_blank">Geoapify</a> | &copy; OpenStreetMap contributors';

class GownShopMapScreen extends StatefulWidget {
  final GownModel gown;

  const GownShopMapScreen({super.key, required this.gown});

  @override
  State<GownShopMapScreen> createState() => _GownShopMapScreenState();
}

class _GownShopMapScreenState extends State<GownShopMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  double? _distanceKm;
  bool _loadingLocation = true;
  List<LatLng> _routePoints = [];
  double? _routeDistanceKm;
  double? _routeDurationMin;
  bool _routing = false;

  static const String _apiBase = 'http://10.0.2.2:8000/api';

  Future<Map<String, dynamic>?> _calculateRoute() async {
    if (_userLocation == null || !widget.gown.hasShopLocation) return null;
    setState(() => _routing = true);
    try {
      final res = await http.post(
        Uri.parse('$_apiBase/shop/route'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'from_latitude': _userLocation!.latitude,
          'from_longitude': _userLocation!.longitude,
          'to_latitude': widget.gown.companyLatitude,
          'to_longitude': widget.gown.companyLongitude,
        }),
      ).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        setState(() {
          _routePoints = (data['polyline'] as List)
              .map((p) => LatLng(p['lat'] as double, p['lng'] as double))
              .toList();
          _routeDistanceKm = data['distance_km'] as double?;
          _routeDurationMin = data['duration_min'] as double?;
        });
        return data;
      }
    } catch (_) {
      // Routing unavailable; fall back to external navigation only.
    } finally {
      if (mounted) setState(() => _routing = false);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _distanceKm = widget.gown.distanceKm;
    unawaited(_loadUserLocation());
  }

  Future<void> _loadUserLocation() async {
    final pos = await LocationHelper.getCurrentPosition();
    if (!mounted) return;
    if (pos != null) {
      final user = LatLng(pos.latitude, pos.longitude);
      double? dist = _distanceKm;
      if (widget.gown.hasShopLocation) {
        dist = LocationHelper.distanceKm(
          lat1: pos.latitude,
          lng1: pos.longitude,
          lat2: widget.gown.companyLatitude!,
          lng2: widget.gown.companyLongitude!,
        );
      }
      setState(() {
        _userLocation = user;
        _distanceKm = dist ?? _distanceKm;
        _loadingLocation = false;
      });
      _fitBounds();
      if (widget.gown.hasShopLocation) unawaited(_calculateRoute());
    } else {
      setState(() => _loadingLocation = false);
    }
  }

  void _fitBounds() {
    if (!widget.gown.hasShopLocation) return;
    final shop = LatLng(widget.gown.companyLatitude!, widget.gown.companyLongitude!);
    if (_userLocation != null) {
      final bounds = LatLngBounds.fromPoints([shop, _userLocation!]);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)));
    } else {
      _mapController.move(shop, 14);
    }
  }

  Future<void> _openExternalNavigation() async {
    if (widget.gown.hasShopLocation) {
      final lat = widget.gown.companyLatitude!;
      final lng = widget.gown.companyLongitude!;
      final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }
    await _openAddressSearch();
  }

  Future<void> _openAddressSearch() async {
    final query = [
      widget.gown.companyName,
      widget.gown.companyAddress,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');
    if (query.isEmpty) return;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gown = widget.gown;
    final hasShop = gown.hasShopLocation;
    final shop = hasShop ? LatLng(gown.companyLatitude!, gown.companyLongitude!) : null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          gown.companyName ?? 'Shop Location',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
      ),
      body: !hasShop
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EmptyState(
                      icon: Icons.location_off_outlined,
                      title: 'Location not available',
                      subtitle: (gown.companyAddress ?? '').trim().isNotEmpty
                          ? 'This shop has not provided map coordinates yet. You can still open its address in Maps.'
                          : 'This shop has not provided map coordinates or address yet.',
                    ),
                    if ((gown.companyAddress ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      GoldButton(
                        text: 'Search Address in Maps',
                        icon: Icons.open_in_new_rounded,
                        onPressed: _openAddressSearch,
                      ),
                    ],
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: shop!,
                      initialZoom: 14,
                      onMapReady: _fitBounds,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: _geoapifyTileUrl,
                        userAgentPackageName: 'com.glamfit.customer_app',
                      ),
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              color: AppColors.roseRed,
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                      const RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'Geoapify | OpenStreetMap contributors',
                            prependCopyright: true,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: shop,
                            width: 46,
                            height: 46,
                            child: const Icon(Icons.location_on, color: AppColors.roseRed, size: 42),
                          ),
                          if (_userLocation != null)
                            Marker(
                              point: _userLocation!,
                              width: 36,
                              height: 36,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: AppColors.ivory,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          gown.companyName ?? 'GlamFit Shop',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        if ((gown.companyAddress ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            gown.companyAddress!,
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.mediumGray),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              _loadingLocation ? Icons.hourglass_top_rounded : Icons.near_me_rounded,
                              size: 18,
                              color: AppColors.roseRed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _loadingLocation
                                  ? 'Calculating distance...'
                                  : _distanceKm != null
                                      ? '${LocationHelper.formatDistance(_distanceKm!)} away'
                                      : 'Enable location to see distance',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (_routing)
                          const SizedBox(
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.roseRed),
                          )
                        else if (_routeDistanceKm != null && _routeDurationMin != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.route_rounded, size: 16, color: AppColors.roseRed),
                              const SizedBox(width: 6),
                              Text(
                                'Route: ${_routeDistanceKm!.toStringAsFixed(1)} km • ${_routeDurationMin!.toStringAsFixed(0)} min drive',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),
                        GoldButton(
                          text: 'Open Directions',
                          icon: Icons.directions_rounded,
                          onPressed: _openExternalNavigation,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _GeoapifyAttribution extends StatelessWidget {
  const _GeoapifyAttribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '© Geoapify | © OpenStreetMap contributors',
        style: TextStyle(fontSize: 9, color: Colors.black87),
      ),
    );
  }
}
