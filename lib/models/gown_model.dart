class GownCategory {
  final String id;
  final String name;
  final String icon;
  final int count;

  const GownCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
  });

  factory GownCategory.fromApiJson(dynamic value, int index) {
    final json = value is Map<String, dynamic> ? value : <String, dynamic>{};
    final name = (json['name'] ?? value).toString();
    return GownCategory(
      id: (json['id'] ?? index + 1).toString(),
      name: name,
      icon: (json['icon'] ?? '👗').toString(),
      count: _asInt(json['count']),
    );
  }
}

class GownModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String designer;
  final String style;
  final String eventType;
  final double rentalPrice;
  final int promoDiscountPercent;
  final DateTime? promoStartsAt;
  final DateTime? promoEndsAt;
  final int rentalDays;
  final double depositAmount;
  final double replacementValue;
  final List<String> sizes;
  final List<String> colors;
  final List<String> images;
  final List<String> accessories;
  final String careInstructions;
  final bool isAvailable;
  final bool isFeatured;
  final bool isNew;
  final double rating;
  final int rentalCount;
  final String? companyId;
  final String? companyName;
  final String? companyAddress;
  final String? companyPhone;
  final double? companyLatitude;
  final double? companyLongitude;
  final double? distanceKm;

  const GownModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.designer,
    required this.style,
    required this.eventType,
    required this.rentalPrice,
    this.promoDiscountPercent = 0,
    this.promoStartsAt,
    this.promoEndsAt,
    required this.rentalDays,
    required this.depositAmount,
    required this.replacementValue,
    required this.sizes,
    required this.colors,
    required this.images,
    required this.accessories,
    required this.careInstructions,
    this.isAvailable = true,
    this.isFeatured = false,
    this.isNew = false,
    this.rating = 4.5,
    this.rentalCount = 0,
    this.companyId,
    this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyLatitude,
    this.companyLongitude,
    this.distanceKm,
  });

  bool get hasShopLocation => companyLatitude != null && companyLongitude != null;

  factory GownModel.fromApiJson(
    Map<String, dynamic> json,
    String Function(String) resolveImageUrl,
  ) {
    final category = _asString(json['category'], 'Gown');
    final rentalPrice = _asDouble(json['rental_price']);
    final promoDiscountPercent = _asInt(json['promo_discount_percent']);
    final promoStartsAt = DateTime.tryParse(_asString(json['promo_starts_at']))?.toLocal();
    final promoEndsAt = DateTime.tryParse(_asString(json['promo_ends_at']))?.toLocal();
    final rawImage = _asString(json['image_url'] ?? json['image']);
    final image = rawImage.isEmpty ? '' : resolveImageUrl(rawImage);
    final rawImages = json['images'];
    List<String> parsedImages = const [];
    if (rawImages is List) {
      parsedImages = rawImages
          .map((item) {
            if (item is Map) {
              return resolveImageUrl(_asString(item['url'] ?? item['image_url'] ?? item['file_path']));
            }
            return resolveImageUrl(_asString(item));
          })
          .where((value) => value.isNotEmpty)
          .toList();
    }
    if (parsedImages.isEmpty && image.isNotEmpty) parsedImages = [image];
    final sizes = _asStringList(json['sizes'] ?? json['size']);
    final colors = _asStringList(json['colors'] ?? json['color']);
    final createdAt = DateTime.tryParse(_asString(json['created_at']));

    return GownModel(
      id: _asString(json['id']),
      style: _asString(json['style'], category),
      name: _asString(json['name'], 'Untitled gown'),
      description: _asString(json['description']),
      category: category,
      designer: _asString(json['designer'], 'GlamFit Designer'),
      eventType: _asString(json['event_type'], category),
      rentalPrice: rentalPrice,
      promoDiscountPercent: promoDiscountPercent,
      promoStartsAt: promoStartsAt,
      promoEndsAt: promoEndsAt,
      rentalDays: _asInt(json['rental_days'], 3),
      depositAmount: _asDouble(json['security_deposit'] ?? json['deposit_amount']),
      replacementValue: _asDouble(json['replacement_value'] ?? json['sale_price']),
      sizes: sizes.isEmpty ? const ['One size'] : sizes,
      colors: colors.isEmpty ? const ['As pictured'] : colors,
      images: parsedImages.isEmpty ? const [''] : parsedImages,
      accessories: _asStringList(json['accessories']),
      careInstructions: _asString(json['care_instructions']),
      isAvailable: _asBool(json['is_available'] ?? json['available_for_rental'], true) &&
          _asString(json['listing_status'], 'Available').toLowerCase() == 'available',
      isFeatured: _asBool(json['is_featured'], true),
      isNew: createdAt != null && DateTime.now().difference(createdAt).inDays <= 30,
      rating: _asDouble(json['rating'], 4.5),
      rentalCount: _asInt(json['rental_count']),
      companyId: _asNullableString(json['company_id']),
      companyName: _asNullableString(json['company_name']),
      companyAddress: _asNullableString(json['company_address']),
      companyPhone: _asNullableString(json['company_phone']),
      companyLatitude: _asNullableDouble(json['company_latitude']),
      companyLongitude: _asNullableDouble(json['company_longitude']),
      distanceKm: _asNullableDouble(json['distance_km']),
    );
  }

  bool get isPromoActive =>
      promoDiscountPercent > 0 &&
      promoStartsAt != null &&
      promoEndsAt != null &&
      !DateTime.now().isBefore(promoStartsAt!) &&
      DateTime.now().isBefore(promoEndsAt!);

  bool get isPromoScheduled =>
      promoDiscountPercent > 0 &&
      promoStartsAt != null &&
      promoEndsAt != null &&
      DateTime.now().isBefore(promoStartsAt!);

  double get effectiveRentalPrice => isPromoActive
      ? rentalPrice * (100 - promoDiscountPercent) / 100
      : rentalPrice;
}

String _asString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  final result = value.toString().trim();
  return result.isEmpty ? fallback : result;
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final result = value.toString().trim();
  return result.isEmpty ? null : result;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final parsed = double.tryParse(value.toString());
  return parsed;
}

double _asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return fallback;
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return value.split(RegExp(r'[,|]')).map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  }
  return const [];
}

class GownItem {
  final String id;
  final String inventoryCode;
  final String gownModelId;
  final String size;
  final String color;
  final String condition;
  final String availabilityStatus;

  const GownItem({
    required this.id,
    required this.inventoryCode,
    required this.gownModelId,
    required this.size,
    required this.color,
    required this.condition,
    required this.availabilityStatus,
  });
}
