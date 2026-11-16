import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ForgotPasswordScreen({super.key, required this.onBack});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _sent = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.champagneGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      onPressed: widget.onBack,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _sent ? AppColors.success.withValues(alpha: 0.1) : AppColors.primarySurface,
                        ),
                        child: Icon(
                          _sent ? Icons.mark_email_read_outlined : Icons.lock_reset_rounded,
                          size: 40,
                          color: _sent ? AppColors.success : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _sent ? 'Check Your Email' : 'Forgot Password?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _sent
                            ? 'We\'ve sent a password reset link to your email. Please check your inbox and follow the instructions.'
                            : 'Don\'t worry! Enter your email address and we\'ll send you a link to reset your password.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (!_sent) ...[
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email address',
                            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                            filled: true,
                            fillColor: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 28),
                        GoldButton(
                          text: 'Send Reset Link',
                          isLoading: _isLoading,
                          onPressed: () {
                            setState(() => _isLoading = true);
                            Future.delayed(const Duration(seconds: 1), () {
                              setState(() {
                                _isLoading = false;
                                _sent = true;
                              });
                            });
                          },
                        ),
                      ] else ...[
                        GoldButton(
                          text: 'Back to Sign In',
                          onPressed: widget.onBack,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _sent = false),
                          child: const Text('Didn\'t receive it? Resend'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
