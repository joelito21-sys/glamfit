import '../../../models/gown_model.dart';

/// Image-selection rules for a gown (previously private helpers on the
/// State class that coupled the UI to image-list indexing quirks).
abstract final class GownMedia {
  /// The image representing a given color variant, falling back to the
  /// first available image.
  static String imageForColor(GownModel gown, int colorIndex) {
    if (gown.images.isEmpty) return '';
    return gown.images[colorIndex < gown.images.length ? colorIndex : 0];
  }

  /// All non-empty carousel images; if there are none, falls back to the
  /// image of the currently selected color so the header is never blank.
  static List<String> carouselImages(GownModel gown, int selectedColorIndex) {
    final images = gown.images.where((i) => i.isNotEmpty).toList();
    if (images.isEmpty) images.add(imageForColor(gown, selectedColorIndex));
    return images;
  }
}
