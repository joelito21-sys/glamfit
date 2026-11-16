import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class PaymentUploadScreen extends StatefulWidget {
  final String bookingRef;
  final String gownName;
  final double amount;
  final String paymentType;

  const PaymentUploadScreen({
    super.key,
    required this.bookingRef,
    required this.gownName,
    required this.amount,
    required this.paymentType,
  });

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String _selectedMethod = 'GCash';
  final TextEditingController _refController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _hasUploadedProof = false;
  bool _isSubmitting = false;
  bool _isComplete = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'GCash', 'icon': Icons.phone_android_rounded, 'color': AppColors.textDark, 'number': '0917 XXX XXXX'},
    {'name': 'Maya', 'icon': Icons.account_balance_wallet_rounded, 'color': AppColors.textDark, 'number': '0918 XXX XXXX'},
    {'name': 'PayMaya', 'icon': Icons.credit_card_rounded, 'color': AppColors.textDark, 'number': 'PayMaya Business'},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance_rounded, 'color': AppColors.textDark, 'number': 'BDO SA XXXX-XXXX-XXXX'},
    {'name': 'Cash on Pickup', 'icon': Icons.payments_rounded, 'color': AppColors.textDark, 'number': 'Pay at store'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _simulateUpload() {
    setState(() => _hasUploadedProof = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Text('Photo uploaded', style: GoogleFonts.poppins(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_hasUploadedProof && _selectedMethod != 'Cash on Pickup') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload payment proof first', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSubmitting = false;
      _isComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) return _buildSuccessView();

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.charcoal),
                ),
              ),
              title: const Text('Submit Payment'),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.champagneLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.charcoal.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.receipt_long_rounded, size: 20, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.gownName),
                                const SizedBox(height: 2),
                                Text(widget.bookingRef),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(widget.paymentType.toUpperCase()),
                            const SizedBox(height: 4),
                            Text('₱${widget.amount.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: const Text('Payment Method'),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    final isSelected = _selectedMethod == method['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMethod = method['name'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? (method['color'] as Color).withValues(alpha: 0.1) : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? method['color'] as Color : AppColors.lightGray.withValues(alpha: 0.5),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: (method['color'] as Color).withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(method['icon'] as IconData, size: 24, color: method['color'] as Color),
                            const SizedBox(height: 6),
                            Text(
                              method['name'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? method['color'] as Color : AppColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Send payment to:'),
                            const SizedBox(height: 2),
                            Text(
                              _paymentMethods.firstWhere((m) => m['name'] == _selectedMethod)['number'] as String,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.copy_rounded, size: 16, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_selectedMethod != 'Cash on Pickup')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Upload Payment Proof'),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _hasUploadedProof ? null : _simulateUpload,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _hasUploadedProof ? AppColors.successLight : AppColors.surfaceBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _hasUploadedProof
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : AppColors.lightGray.withValues(alpha: 0.5),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: _hasUploadedProof
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check_circle_rounded, size: 32, color: AppColors.success),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Payment proof uploaded'),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => setState(() => _hasUploadedProof = false),
                                      child: const Text('Replace'),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.charcoal.withValues(alpha: 0.06),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Icon(Icons.cloud_upload_outlined, size: 28, color: AppColors.primary.withValues(alpha: 0.7)),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text('Tap to upload screenshot'),
                                    const SizedBox(height: 4),
                                    const Text('JPG, PNG or PDF • Max 5MB'),
                                  ],
                                ),
                           ),
                         ),
                     ],
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reference Number'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _refController,
                      decoration: InputDecoration(
                        hintText: 'Enter transaction reference #',
                        prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notes (optional)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Any additional notes...',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Secured by GownLux \u2022 Payments verified by admin',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: GoldButton(
                  text: 'Submit Payment',
                  icon: Icons.send_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, size: 48, color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              const Text(
                'Payment Submitted!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                'Your payment for ${widget.bookingRef} has been submitted and is pending verification.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: AppColors.warning),
                    const SizedBox(width: 6),
                    const Text('Verification takes 1-2 hours'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GoldButton(
                text: 'Back to Bookings',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              GoldButton(
                text: 'View Receipt',
                isOutlined: true,
                icon: Icons.receipt_long_rounded,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
