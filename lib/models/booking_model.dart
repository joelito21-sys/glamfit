class BookingModel {
  final String id;
  final String bookingRef;
  final String gownName;
  final String gownImage;
  final String gownSize;
  final String gownColor;
  final DateTime rentalStart;
  final DateTime rentalEnd;
  final BookingStatus status;
  final double subtotal;
  final double deposit;
  final double discount;
  final double totalAmount;
  final double amountPaid;
  final String? customerNotes;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.bookingRef,
    required this.gownName,
    required this.gownImage,
    required this.gownSize,
    required this.gownColor,
    required this.rentalStart,
    required this.rentalEnd,
    required this.status,
    required this.subtotal,
    required this.deposit,
    this.discount = 0,
    required this.totalAmount,
    this.amountPaid = 0,
    this.customerNotes,
    required this.createdAt,
  });

  factory BookingModel.fromApiJson(
    Map<String, dynamic> json,
    String Function(String) resolveImageUrl,
  ) {
    final statusText = (json['status'] ?? 'Pending')
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), '');
    final status = switch (statusText) {
      'approved' => BookingStatus.approved,
      'rejected' => BookingStatus.rejected,
      'awaitingpayment' => BookingStatus.awaitingPayment,
      'confirmed' => BookingStatus.confirmed,
      'readyforpickup' => BookingStatus.readyForPickup,
      'active' || 'rentedout' => BookingStatus.rentedOut,
      'returned' => BookingStatus.returned,
      'inspectionpending' => BookingStatus.inspectionPending,
      'completed' => BookingStatus.completed,
      'cancelled' => BookingStatus.cancelled,
      'overdue' => BookingStatus.overdue,
      _ => BookingStatus.pending,
    };
    final image = (json['gown_image'] ?? json['image'] ?? '').toString();
    final rentalPrice = _bookingDouble(json['total_price']);
    final deposit = _bookingDouble(json['deposit']);

    return BookingModel(
      id: (json['id'] ?? '').toString(),
      bookingRef: (json['reservation_no'] ?? '').toString(),
      gownName: (json['gown_name'] ?? 'Gown').toString(),
      gownImage: image.isEmpty ? '' : resolveImageUrl(image),
      gownSize: (json['gown_size'] ?? '—').toString(),
      gownColor: (json['gown_color'] ?? '—').toString(),
      rentalStart: DateTime.tryParse((json['rental_start'] ?? '').toString()) ?? DateTime.now(),
      rentalEnd: DateTime.tryParse((json['rental_end'] ?? '').toString()) ?? DateTime.now(),
      status: status,
      subtotal: rentalPrice,
      deposit: deposit,
      totalAmount: rentalPrice + deposit,
      amountPaid: 0,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  double get outstandingBalance => totalAmount - amountPaid;
  int get rentalDays => rentalEnd.difference(rentalStart).inDays;
}

double _bookingDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

enum BookingStatus {
  pending('Pending', 'pending'),
  approved('Approved', 'approved'),
  rejected('Rejected', 'rejected'),
  awaitingPayment('Awaiting Payment', 'awaiting_payment'),
  confirmed('Confirmed', 'confirmed'),
  readyForPickup('Ready for Pickup', 'ready_for_pickup'),
  rentedOut('Rented Out', 'rented_out'),
  returned('Returned', 'returned'),
  inspectionPending('Inspection', 'inspection_pending'),
  completed('Completed', 'completed'),
  cancelled('Cancelled', 'cancelled'),
  overdue('Overdue', 'overdue');

  final String label;
  final String value;
  const BookingStatus(this.label, this.value);
}

class BookingStatusHistory {
  final String id;
  final BookingStatus status;
  final DateTime timestamp;
  final String? note;

  const BookingStatusHistory({
    required this.id,
    required this.status,
    required this.timestamp,
    this.note,
  });
}
