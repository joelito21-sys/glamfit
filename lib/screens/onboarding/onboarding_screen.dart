import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.checkroom_rounded,
      title: 'Discover Premium Gowns',
      subtitle: 'Browse our exquisite collection of wedding, evening, debut, and prom gowns — curated for every special occasion.',
    ),
    _OnboardingPage(
      icon: Icons.calendar_month_rounded,
      title: 'Easy Booking',
      subtitle: 'Check availability, select your dates, and book your dream gown in just a few taps. It\'s that simple.',
    ),
    _OnboardingPage(
      icon: Icons.local_shipping_rounded,
      title: 'Seamless Experience',
      subtitle: 'From pickup to return, we guide you through every step. Track your booking, payments, and receive timely reminders.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            const Positioned(
              top: -60,
              right: -40,
              child: GoldGlow(size: 200, opacity: 0.06),
            ),
            const Positioned(
              bottom: 100,
              left: -80,
              child: GoldGlow(size: 250, opacity: 0.04),
            ),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: TextButton(
                        onPressed: widget.onComplete,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.poppins(
                            color: AppColors.champagneGold.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.rosePink.withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: AppColors.rosePink.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.lightPink,
                                    ),
                                    child: Icon(
                                      page.icon,
                                      size: 48,
                                      color: AppColors.champagneGold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),
                              Text(
                                page.title,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                page.subtitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.softGray,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == i ? 28 : 8,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          gradient: _currentPage == i ? AppColors.goldButtonGradient : null,
                          color: _currentPage == i ? null : AppColors.champagneGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: LuxuryGoldButton(
                      text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      showArrow: true,
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          widget.onComplete();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
