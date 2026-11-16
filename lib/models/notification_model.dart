class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? relatedBookingId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.relatedBookingId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromApiJson(Map<String, dynamic> json) {
    final typeName = (json['notification_type'] ?? 'general').toString();
    final type = NotificationType.values.firstWhere(
      (value) => value.name.toLowerCase() == typeName.toLowerCase(),
      orElse: () => NotificationType.general,
    );

    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'GlamFit update').toString(),
      body: (json['body'] ?? '').toString(),
      type: type,
      relatedBookingId: json['reservation_no']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

enum NotificationType {
  bookingReceived('Booking Received'),
  bookingApproved('Booking Approved'),
  bookingRejected('Booking Rejected'),
  paymentVerified('Payment Verified'),
  pickupReminder('Pickup Reminder'),
  returnReminder('Return Reminder'),
  returnDueSoon('Return Due Soon'),
  overdue('Overdue'),
  depositSettled('Deposit Settled'),
  general('General');

  final String label;
  const NotificationType(this.label);
}
