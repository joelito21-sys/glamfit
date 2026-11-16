class SmsNotificationModel {
  final int id;
  final String? recipientName;
  final String phoneNumber;
  final String message;
  final String notificationType;
  final int? relatedBookingId;
  final int? relatedPaymentId;
  final String status;
  final String? textbeeBatchId;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final String? errorMessage;

  const SmsNotificationModel({
    required this.id,
    this.recipientName,
    required this.phoneNumber,
    required this.message,
    required this.notificationType,
    this.relatedBookingId,
    this.relatedPaymentId,
    required this.status,
    this.textbeeBatchId,
    this.sentAt,
    this.deliveredAt,
    required this.createdAt,
    this.errorMessage,
  });

  factory SmsNotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? dt(String? v) => v == null || v.isEmpty ? null : DateTime.tryParse(v)?.toLocal();
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    return SmsNotificationModel(
      id: asInt(json['id']) ?? 0,
      recipientName: json['recipient_name']?.toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      notificationType: (json['notification_type'] ?? 'general').toString(),
      relatedBookingId: asInt(json['related_booking_id']),
      relatedPaymentId: asInt(json['related_payment_id']),
      status: (json['status'] ?? 'queued').toString(),
      textbeeBatchId: json['textbee_batch_id']?.toString(),
      sentAt: dt(json['sent_at']?.toString()),
      deliveredAt: dt(json['delivered_at']?.toString()),
      createdAt: dt(json['created_at']?.toString()) ?? DateTime.now(),
      errorMessage: json['error_message']?.toString(),
    );
  }
}

class SmsPreferencesModel {
  final bool smsEnabled;
  final bool bookingUpdates;
  final bool paymentUpdates;
  final bool deliveryUpdates;
  final bool returnReminders;
  final bool promotionalMessages;

  const SmsPreferencesModel({
    required this.smsEnabled,
    required this.bookingUpdates,
    required this.paymentUpdates,
    required this.deliveryUpdates,
    required this.returnReminders,
    required this.promotionalMessages,
  });

  factory SmsPreferencesModel.defaults() => const SmsPreferencesModel(
        smsEnabled: true,
        bookingUpdates: true,
        paymentUpdates: true,
        deliveryUpdates: true,
        returnReminders: true,
        promotionalMessages: false,
      );

  factory SmsPreferencesModel.fromJson(Map<String, dynamic> json) => SmsPreferencesModel(
        smsEnabled: json['sms_enabled'] == true || json['sms_enabled'] == 1,
        bookingUpdates: json['booking_updates'] == true || json['booking_updates'] == 1,
        paymentUpdates: json['payment_updates'] == true || json['payment_updates'] == 1,
        deliveryUpdates: json['delivery_updates'] == true || json['delivery_updates'] == 1,
        returnReminders: json['return_reminders'] == true || json['return_reminders'] == 1,
        promotionalMessages: json['promotional_messages'] == true || json['promotional_messages'] == 1,
      );

  SmsPreferencesModel copyWith({
    bool? smsEnabled,
    bool? bookingUpdates,
    bool? paymentUpdates,
    bool? deliveryUpdates,
    bool? returnReminders,
    bool? promotionalMessages,
  }) => SmsPreferencesModel(
        smsEnabled: smsEnabled ?? this.smsEnabled,
        bookingUpdates: bookingUpdates ?? this.bookingUpdates,
        paymentUpdates: paymentUpdates ?? this.paymentUpdates,
        deliveryUpdates: deliveryUpdates ?? this.deliveryUpdates,
        returnReminders: returnReminders ?? this.returnReminders,
        promotionalMessages: promotionalMessages ?? this.promotionalMessages,
      );

  Map<String, dynamic> toJson() => {
        'sms_enabled': smsEnabled,
        'booking_updates': bookingUpdates,
        'payment_updates': paymentUpdates,
        'delivery_updates': deliveryUpdates,
        'return_reminders': returnReminders,
        'promotional_messages': promotionalMessages,
      };
}
