class PaymentModel {
  final String id;
  final String rentalId;
  final String bookingRef;
  final String gownName;
  final double amount;
  final String paymentMethod;
  final PaymentType transactionType;
  final String? referenceNumber;
  final PaymentStatus status;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.rentalId,
    required this.bookingRef,
    required this.gownName,
    required this.amount,
    required this.paymentMethod,
    required this.transactionType,
    this.referenceNumber,
    required this.status,
    required this.createdAt,
  });
}

enum PaymentType {
  rental('Rental Fee'),
  deposit('Deposit'),
  lateFee('Late Fee'),
  damageFee('Damage Fee'),
  refund('Refund'),
  depositReturn('Deposit Return');

  final String label;
  const PaymentType(this.label);
}

enum PaymentStatus {
  pending('Pending'),
  verified('Verified'),
  rejected('Rejected');

  final String label;
  const PaymentStatus(this.label);
}
