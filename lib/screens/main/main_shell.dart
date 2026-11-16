import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/glass_widgets.dart';
import '../bookings/bookings_screen.dart';
import '../browse/browse_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  /// Drives the fade/rise whenever a different tab is brought forward.
  late final AnimationController _switch;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const BrowseScreen(),
      const BookingsScreen(),
      const WishlistScreen(),
      const ProfileScreen(),
    ];
    _switch = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
      value: 1,
    );
  }

  @override
  void dispose() {
    _switch.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (AppMotion.reduced(context)) {
      _switch.value = 1;
    } else {
      _switch.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blushPink,
      body: Stack(
        children: [
          // Tab content stays alive inside the IndexedStack; only the
          // transition plays on top of it.
          AnimatedBuilder(
            animation: _switch,
            child: IndexedStack(index: _currentIndex, children: _screens),
            builder: (context, child) {
              final double t = Curves.easeOutCubic.transform(_switch.value);
              return Opacity(
                opacity: 0.40 + 0.60 * t,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - t)),
                  child: child,
                ),
              );
            },
          ),
          // Floating glass bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassNavBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                      0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                  _buildNavItem(1, Icons.search_rounded, Icons.search_outlined,
                      'Search'),
                  _buildNavItem(
                      2,
                      Icons.calendar_month_rounded,
                      Icons.calendar_month_outlined,
                      'Bookings'),
                  _buildNavItem(3, Icons.favorite_rounded,
                      Icons.favorite_border_rounded, 'Wishlist'),
                  _buildNavItem(
                      4, Icons.person_rounded, Icons.person_outlined, 'Profile'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final bool isActive = _currentIndex == index;
    return Pressable(
      onTap: () => _selectTab(index),
      pressedScale: 0.9,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: _selectedPadding(index),
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.roseRed.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.12 : 1.0,
              duration: AppMotion.medium,
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Icon(
                  isActive ? activeIcon : inactiveIcon,
                  key: ValueKey(isActive),
                  size: 24,
                  color: isActive ? AppColors.roseRed : AppColors.mediumGray,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: AppMotion.medium,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.roseRed : AppColors.mediumGray,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  double _selectedPadding(int index) => _currentIndex == index ? 14 : 12;
}
