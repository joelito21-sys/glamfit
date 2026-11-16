import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth/auth_session.dart';
import '../../core/state/notification_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/widgets/glass_widgets.dart';
import '../auth/auth_flow_screen.dart';
import '../history/rental_history_screen.dart';
import '../measurements/measurements_screen.dart';
import '../notifications/notifications_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.blushPink,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // Background ambient glows
            const Positioned(
              top: -60,
              right: -80,
              child: GoldGlow(size: 240, opacity: 0.1),
            ),
            Positioned(
              bottom: 180,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.rosePink.withValues(alpha: 0.3),
                      AppColors.rosePink.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Profile header
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Profile',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              Pressable(
                                onTap: () {
                                  if (!session.isLoggedIn) {
                                    AuthGate.requireLogin(context,
                                        prompt: 'Sign in to manage your account');
                                    return;
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.glassWhite,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.glassBorder),
                                  ),
                                  child: const Icon(Icons.settings_outlined,
                                      size: 20, color: AppColors.charcoal),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Avatar
                          Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.roseRed,
                                      AppColors.deepRose,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.rosePink.withValues(alpha: 0.8),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.roseRed
                                          .withValues(alpha: 0.3),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    session.initial,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ivory,
                                    ),
                                  ),
                                ),
                              ),
                              if (session.isLoggedIn)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const EditProfileScreen()),
                                    ),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.charcoal,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.roseRed,
                                            width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.3),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 14,
                                          color: AppColors.champagneGold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            session.isLoggedIn ? session.displayName : 'Guest',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.isLoggedIn
                                ? session.email
                                : 'Browse freely. Sign in to book.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.softGray,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (session.isLoggedIn)
                            SizedBox(
                              width: 170,
                              height: 42,
                              child: LuxuryGoldButton(
                                text: 'Edit Profile',
                                showArrow: false,
                                fontSize: 13,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const EditProfileScreen()),
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          if (session.isLoggedIn)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: AppColors.goldButtonGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 14,
                                      color: AppColors.midnightNavy),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Gold Member',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.midnightNavy,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            LuxuryGoldButton(
                              text: 'Sign In',
                              width: 160,
                              onPressed: () => AuthGate.requireLogin(context,
                                  prompt: 'Sign in to manage your account'),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: AppColors.glassGradient,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              _statCard(
                                'Bookings',
                                session.bookingCount.toString(),
                                Icons.event_rounded,
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.glassBorder),
                              _statCard(
                                'Saved',
                                session.wishlistCount.toString(),
                                Icons.favorite_rounded,
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.glassBorder),
                              _statCard(
                                'Spent',
                                '₱${session.totalSpent.toStringAsFixed(0)}',
                                Icons.attach_money_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Recent Activity
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Activity',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                            ),
                            Pressable(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const RentalHistoryScreen()),
                              ),
                              child: Text(
                                'See All',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.champagneGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _activityItem(
                          'Gown rental confirmed',
                          'Elegant Ballgown',
                          '2 hours ago',
                          Icons.check_circle_rounded,
                          AppColors.success,
                        ),
                        const SizedBox(height: 10),
                        _activityItem(
                          'Payment uploaded',
                          'Seraphina Ballgown',
                          '1 day ago',
                          Icons.payment_rounded,
                          AppColors.champagneGold,
                        ),
                        const SizedBox(height: 10),
                        _activityItem(
                          'Return scheduled',
                          'Isabella Mermaid',
                          '3 days ago',
                          Icons.event_note_rounded,
                          AppColors.warning,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Account Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.glassGradient,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.glassBorder),
                              ),
                              child: Column(
                                children: [
                                  _settingsTile(
                                    'Edit Profile',
                                    Icons.person_outline_rounded,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const EditProfileScreen()),
                                    ),
                                  ),
                                  _thinDivider(),
                                  _settingsTile(
                                    'My Rentals',
                                    Icons.checkroom_rounded,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const RentalHistoryScreen()),
                                    ),
                                  ),
                                  _thinDivider(),
                                  _settingsTile(
                                    'Wishlist',
                                    Icons.favorite_outline_rounded,
                                    () {},
                                  ),
                                  _thinDivider(),
                                  _settingsTile(
                                    'Body Measurements',
                                    Icons.straighten_rounded,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const MeasurementsScreen()),
                                    ),
                                  ),
                                  _thinDivider(),
                                  _settingsTile(
                                    'Payment Methods',
                                    Icons.account_balance_wallet_outlined,
                                    () {},
                                  ),
                                  _thinDivider(),
                                  _settingsTile(
                                    'Address Management',
                                    Icons.location_on_outlined,
                                    () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Support Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.glassGradient,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.glassBorder),
                              ),
                              child: Column(
                                children: [
                                  _settingsTile(
                                    'Notifications',
                                    Icons.notifications_outlined,
                                    () {
                                      final token = AuthScope.read(context).accessToken;
                                      if (token != null) {
                                        unawaited(NotificationStore.instance.load(token));
                                      }
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const NotificationsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  _thinDivider(),
                                  _settingsTile(
                                    'Help & Support',
                                    Icons.help_outline_rounded,
                                    () {},
                                  ),
                                  _thinDivider(),
                                  _settingsTile(
                                    'About Us',
                                    Icons.info_outline_rounded,
                                    () {},
                                  ),
                                  _thinDivider(),
                                  _settingsTile(
                                    'Terms & Conditions',
                                    Icons.description_outlined,
                                    () {},
                                  ),
                                  _thinDivider(),
                                  _settingsTile(
                                    'Privacy Policy',
                                    Icons.shield_outlined,
                                    () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Logout
                  if (session.isLoggedIn)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.glassGradient,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: AppColors.glassBorder),
                            ),
                            child: _settingsTile(
                              'Log Out',
                              Icons.logout_rounded,
                              () {
                                session.logout();
                              },
                              isDestructive: true,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Version info
                  const SizedBox(height: 24),
                  Text(
                    'GownLux v1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.dimGray,
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thinDivider() {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.glassBorder,
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, size: 18, color: AppColors.champagneGold),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityItem(String title, String gown, String time,
      IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppColors.glassGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          gown,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.softGray,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· $time',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.dimGray,
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
    );
  }

  Widget _settingsTile(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? AppColors.error
                    : AppColors.champagneGold.withValues(alpha: 0.8),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? AppColors.error : AppColors.charcoal,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDestructive ? AppColors.error.withValues(alpha: 0.4) : AppColors.dimGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
