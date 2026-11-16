import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// Displays a gown photo from either an asset path or a network URL.
/// Supports raster formats (PNG/JPG/WebP) and SVG.
class GownImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const GownImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
  });

  bool get _isSvg => imagePath.toLowerCase().split('?').first.endsWith('.svg');

  Widget _errorPlaceholder(Object? error) {
    if (kDebugMode) {
      debugPrint('[GownImage] failed to load "$imagePath": $error');
    }
    return ColoredBox(
      color: AppColors.lightPink,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 32,
          color: AppColors.charcoal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorImage = _errorPlaceholder(null);

    if (imagePath.isEmpty) return errorImage;

    final uri = Uri.tryParse(imagePath);
    final isNetworkImage =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (_isSvg) {
      if (isNetworkImage) {
        return SvgPicture.network(
          imagePath,
          fit: fit,
          placeholderBuilder: (_) => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorBuilder: (context, error, stackTrace) =>
              _errorPlaceholder(error),
        );
      }
      return SvgPicture.asset(
        imagePath,
        fit: fit,
        placeholderBuilder: (_) => _errorPlaceholder('asset svg unavailable'),
      );
    }

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _errorPlaceholder(error),
      );
    }

    return Image.asset(
      imagePath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _errorPlaceholder(error),
    );
  }
}
