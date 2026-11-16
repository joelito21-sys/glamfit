import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gown_image.dart';

/// Hero image carousel with page indicator.
class GownCarousel extends StatefulWidget {
  final List<String> images;
  const GownCarousel({super.key, required this.images});

  @override
  State<GownCarousel> createState() => _GownCarouselState();
}

class _GownCarouselState extends State<GownCarousel> {
  late final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.isEmpty ? const [''] : widget.images;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(28, 72, 28, 30),
              child: GownImage(imagePath: images[index], fit: BoxFit.contain),
            ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SmoothPageIndicator(
              controller: _controller,
              count: images.length,
              effect: WormEffect(
                dotHeight: 7,
                dotWidth: 7,
                activeDotColor: AppColors.roseRed,
                dotColor: AppColors.rosePink.withValues(alpha: 0.4),
                spacing: 6,
              ),
            ),
          ),
      ],
    );
  }
}
