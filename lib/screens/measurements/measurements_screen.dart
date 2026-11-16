import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/glass_widgets.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool _isEditing = false;
  String _unit = 'in'; // 'in' or 'cm'

  // Measurement controllers
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _measurements = {
    'Bust': '34',
    'Waist': '26',
    'Hips': '36',
    'Shoulder Width': '15',
    'Arm Length': '23',
    'Dress Length': '58',
    'Upper Arm': '11',
    'Torso Length': '17',
  };

  final Map<String, IconData> _measurementIcons = {
    'Bust': Icons.accessibility_new_rounded,
    'Waist': Icons.straighten_rounded,
    'Hips': Icons.accessibility_new_rounded,
    'Shoulder Width': Icons.open_with_rounded,
    'Arm Length': Icons.back_hand_rounded,
    'Dress Length': Icons.height_rounded,
    'Upper Arm': Icons.fitness_center_rounded,
    'Torso Length': Icons.person_rounded,
  };

  final Map<String, String> _measurementTips = {
    'Bust': 'Measure around the fullest part of your bust',
    'Waist': 'Measure around your natural waistline',
    'Hips': 'Measure around the widest part of your hips',
    'Shoulder Width': 'Measure from shoulder point to shoulder point',
    'Arm Length': 'Measure from shoulder to wrist',
    'Dress Length': 'Measure from shoulder to desired hemline',
    'Upper Arm': 'Measure around the widest part of your upper arm',
    'Torso Length': 'Measure from shoulder to waist',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();

    for (var entry in _measurements.entries) {
      _controllers[entry.key] = TextEditingController(text: entry.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleUnit() {
    setState(() {
      if (_unit == 'in') {
        _unit = 'cm';
        for (var entry in _controllers.entries) {
          final val = double.tryParse(entry.value.text) ?? 0;
          entry.value.text = (val * 2.54).toStringAsFixed(1);
        }
      } else {
        _unit = 'in';
        for (var entry in _controllers.entries) {
          final val = double.tryParse(entry.value.text) ?? 0;
          entry.value.text = (val / 2.54).toStringAsFixed(1);
        }
      }
    });
  }

  void _saveMeasurements() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Text('Measurements saved successfully!',
                style:
                    GoogleFonts.poppins(fontSize: 13, color: AppColors.charcoal)),
          ],
        ),
      ),
    );
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
            FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header
                  SliverAppBar(
                    expandedHeight: 170,
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
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppColors.charcoal),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(60, 16, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'My Measurements',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Accurate measurements help us find the perfect fit',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.softGray,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.glassBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.update_rounded,
                                            size: 14,
                                            color: AppColors.mediumGray),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Last updated: Oct 20, 2026',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: AppColors.softGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isEditing = !_isEditing),
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: _isEditing
                                ? null
                                : AppColors.goldButtonGradient,
                            color: _isEditing ? AppColors.glassWhite : null,
                            borderRadius: BorderRadius.circular(12),
                            border: _isEditing
                                ? Border.all(color: AppColors.glassBorder)
                                : null,
                          ),
                          child: Text(
                            _isEditing ? 'Cancel' : 'Edit',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isEditing
                                  ? AppColors.ivory
                                  : AppColors.midnightNavy,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Unit Toggle
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Body Measurements',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal,
                            ),
                          ),
                          GestureDetector(
                            onTap: _toggleUnit,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.glassWhite,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: AppColors.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  _unitButton('in', _unit == 'in'),
                                  _unitButton('cm', _unit == 'cm'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Measurements Grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final key = _measurements.keys.elementAt(index);
                          return _MeasurementCard(
                            label: key,
                            unit: _unit,
                            icon: _measurementIcons[key]!,
                            tip: _measurementTips[key]!,
                            controller: _controllers[key]!,
                            isEditing: _isEditing,
                            index: index,
                          );
                        },
                        childCount: _measurements.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                    ),
                  ),

                  // Fit Guide
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppColors.glassGradient,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightPink,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                      Icons.info_outline_rounded,
                                      color: AppColors.champagneGold,
                                      size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Measuring Guide',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.charcoal,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tap on any measurement card to see tips on how to measure correctly.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.softGray,
                                        ),
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

                  // Size recommendation
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: AppColors.glassGradient,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient:
                                            AppColors.goldButtonGradient,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                          Icons.auto_awesome,
                                          size: 18,
                                          color: AppColors.midnightNavy),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'AI Recommended Size',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: ['S', 'M', 'L'].map((size) {
                                    final isRecommended = size == 'S';
                                    return Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        decoration: BoxDecoration(
                                          gradient: isRecommended
                                              ? AppColors.goldButtonGradient
                                              : null,
                                          color: isRecommended
                                              ? null
                                              : AppColors.glassWhite,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: isRecommended
                                              ? null
                                              : Border.all(
                                                  color:
                                                      AppColors.glassBorder),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              size,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: isRecommended
                                                    ? AppColors.midnightNavy
                                                    : AppColors.softGray,
                                              ),
                                            ),
                                            if (isRecommended) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'Best Fit',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColors.midnightNavy,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    'Based on your measurements, size S is the best fit for most gowns.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.softGray,
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

                  // Save button
                  if (_isEditing)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: GoldButton(
                          text: 'Save Measurements',
                          icon: Icons.check_rounded,
                          onPressed: _saveMeasurements,
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

  Widget _unitButton(String label, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.goldButtonGradient : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.midnightNavy : AppColors.mediumGray,
        ),
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final String label;
  final String unit;
  final IconData icon;
  final String tip;
  final TextEditingController controller;
  final bool isEditing;
  final int index;

  const _MeasurementCard({
    required this.label,
    required this.unit,
    required this.icon,
    required this.tip,
    required this.controller,
    required this.isEditing,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditing
          ? null
          : () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.cardDark,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.dimGray,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightPink,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon,
                            size: 36, color: AppColors.champagneGold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        label,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.softGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${controller.text} $unit',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.champagneGold,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: AppColors.glassGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isEditing
                    ? AppColors.champagneGold.withValues(alpha: 0.4)
                    : AppColors.glassBorder,
                width: isEditing ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.champagneGold
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon,
                            size: 16, color: AppColors.champagneGold),
                      ),
                      if (!isEditing)
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: AppColors.dimGray),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.mediumGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isEditing)
                    SizedBox(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                        decoration: InputDecoration(
                          suffixText: unit,
                          suffixStyle: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.mediumGray),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          filled: false,
                        ),
                      ),
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          controller.text,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
