import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class TwoFactorScreen extends StatefulWidget {
  const TwoFactorScreen({
    super.key,
    required this.onVerify,
    required this.onBack,
    this.emailHint,
  });

  final Future<void> Function(String code) onVerify;
  final VoidCallback onBack;
  final String? emailHint;

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Enter the six-digit code from your email.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await widget.onVerify(code);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.champagneGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                        label: const Text('Back to sign in'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Icon(Icons.verified_user_rounded, size: 54, color: AppColors.primary),
                    const SizedBox(height: 22),
                    Text('Verify it’s you', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                    const SizedBox(height: 10),
                    Text('We sent a one-time sign-in code to ${widget.emailHint ?? 'your email address'}. The code expires in 5 minutes.',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.mediumGray)),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      autofocus: true,
                      onSubmitted: (_) => _verify(),
                      decoration: InputDecoration(
                        labelText: '6-digit verification code',
                        hintText: '000000',
                        prefixIcon: const Icon(Icons.password_rounded),
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.error)),
                    ],
                    const SizedBox(height: 22),
                    GoldButton(text: 'Verify and Sign In', isLoading: _loading, onPressed: _verify),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
