import 'package:flutter/material.dart';
import '../../core/auth/auth_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_motion.dart';
import '../../core/state/booking_store.dart';
import '../../core/widgets/gown_image.dart';
import '../../data/api_client.dart';
import '../../models/gown_model.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final GownModel gown;
  final String size;
  final String color;
  final DateTime rentalStart;
  final DateTime rentalEnd;
  const PaymentScreen({
    super.key,
    required this.gown,
    required this.size,
    required this.color,
    required this.rentalStart,
    required this.rentalEnd,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;
  String? _selectedDownpaymentOption;
  String? _selectedFulfillment;
  bool _receiptUploaded = false;
  bool _isSubmitting = false;
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  double get _deliveryFee {
    if (_selectedFulfillment != 'delivery') return 0;
    final distance = double.tryParse(_distanceController.text) ?? 0;
    return distance * 25;
  }

  double get _rentalTotal {
    return widget.gown.effectiveRentalPrice + widget.gown.depositAmount;
  }

  double get _downpaymentAmount {
    final option = _downpaymentOptions.firstWhere(
      (o) => o['label'] == _selectedDownpaymentOption,
      orElse: () => {'percent': 0.5},
    );
    final percent = (option['percent'] as num?)?.toDouble() ?? 0.5;
    return _rentalTotal * percent;
  }

  final List<Map<String, dynamic>> _methods = const [
    {'name': 'GCash', 'icon': '??', 'color': AppColors.textDark},
    {'name': 'Maya', 'icon': '??', 'color': AppColors.textDark},
  ];

  final List<Map<String, dynamic>> _downpaymentOptions = const [
    {'label': '50% Downpayment', 'percent': 0.5},
    {'label': 'Full Payment', 'percent': 1.0},
  ];

  @override
  void initState() {
    super.initState();
    if (_selectedDownpaymentOption == null && _downpaymentOptions.isNotEmpty) {
      _selectedDownpaymentOption = _downpaymentOptions[0]['label'] as String;
    }
    _distanceController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  bool _canPay() {
    if (_selectedFulfillment == 'delivery' && _distanceController.text.isEmpty) return false;
    return true;
  }

  Future<void> _processPayment() async {
    final token = AuthScope.read(context).accessToken;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in before submitting a booking.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final booking = await ApiClient.instance.createRental(
        token: token,
        gownId: widget.gown.id,
        rentalStart: widget.rentalStart,
        rentalEnd: widget.rentalEnd,
        size: widget.size,
        color: widget.color,
      );
      BookingStore.instance.add(booking);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking ${booking.bookingRef} submitted. It is pending owner approval; no payment has been processed.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Rental request'),
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 72,
                      child: GownImage(imagePath: widget.gown.images.first),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.gown.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text('Size: ${widget.size}   ${widget.color}'),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d').format(widget.rentalStart)} - ${DateFormat('MMM d, yyyy').format(widget.rentalEnd)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Choose Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: 12),
            ..._methods.map((m) {
              final isSelected = _selectedMethod == m['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMethod = m['name']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.lightGray.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        decoration: BoxDecoration(
                          color: (m['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text(m['icon']!, style: const TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        m['name']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.charcoal,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            const Text('Downpayment Option', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: 12),
            ..._downpaymentOptions.map((o) {
              final isSelected = _selectedDownpaymentOption == o['label'];
              return GestureDetector(
                onTap: () => setState(() => _selectedDownpaymentOption = o['label']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.lightGray.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.mediumGray, width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          o['label']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.charcoal,
                          ),
                        ),
                      ),
                      Text(
                        '₱${NumberFormat('#,###').format(_downpaymentAmount)}',
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            const Text('Choose How to Receive', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: 12),
            ...['Pick Up', 'Delivery'].map((f) {
              final isSelected = _selectedFulfillment == (f == 'Pick Up' ? 'pickup' : 'delivery');
              return GestureDetector(
                onTap: () => setState(() => _selectedFulfillment = f == 'Pick Up' ? 'pickup' : 'delivery'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.lightGray.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.mediumGray, width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.charcoal,
                          ),
                        ),
                      ),
                      if (isSelected && f == 'Delivery')
                        Text(
                          '+₱${NumberFormat('#,###').format(_deliveryFee)} rider fee',
                        ),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedFulfillment == 'delivery') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Distance from store (km)',
                  suffixText: ' km',
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.lightGray.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Upload Payment Receipt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: 12),
            Pressable(
              onTap: () => setState(() => _receiptUploaded = !_receiptUploaded),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _receiptUploaded ? AppColors.primary : AppColors.lightGray.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _receiptUploaded ? Icons.check_circle : Icons.cloud_upload_rounded,
                      size: 32,
                      color: _receiptUploaded ? AppColors.primary : AppColors.mediumGray,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _receiptUploaded ? 'Receipt Uploaded' : 'Tap to upload receipt',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _receiptUploaded ? AppColors.primary : AppColors.mediumGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Screenshot of your ${_selectedMethod ?? 'GCash/Maya'} transaction',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: 'Transaction reference number (optional)',
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.lightGray.withValues(alpha: 0.3)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated total (not charged)'),
                  Text(
                    '₱${NumberFormat('#,###').format(widget.gown.effectiveRentalPrice + widget.gown.depositAmount + _deliveryFee)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canPay() ? _processPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canPay() ? Colors.white : AppColors.darkSurface,
                  foregroundColor: _canPay() ? const Color(0xFF111111) : AppColors.mediumGray,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_isSubmitting ? 'Submitting' : 'Submit Rental Request'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
