import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tank_battle/screens/sign_in_screen.dart';

import 'auth_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  bool _isLoading = false;
  int _resendSeconds = 60;
  bool _canResend = false;
  Timer? _resendTimer;

  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animation for success/failure indicators
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseAnimationController.forward();
      }
    });
    _pulseAnimationController.forward();

    // Start resend timer
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 60;
      _canResend = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOTP() async {
    // Combine OTP digits
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implement actual OTP verification

    if (mounted) {
      setState(() => _isLoading = false);

      // For demo, just show success and return to sign in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account verified successfully! You can now sign in.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to sign in
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SignInScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Implement actual resend OTP logic

    if (mounted) {
      setState(() => _isLoading = false);

      // Reset the timer
      _startResendTimer();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to ${widget.email}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseAuthScreen(
      title: 'VERIFY CODE',
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Instruction text
          Text(
            'Enter the 6-digit code sent to',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade200,
              fontSize: 16,
            ),
          ),
          Text(
            widget.email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          // OTP input fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
                  (index) => _buildOTPDigitField(index),
            ),
          ),

          const SizedBox(height: 40),

          // Verify button
          ElevatedButton(
            onPressed: _isLoading ? null : _verifyOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.green.shade200,
                  width: 2,
                ),
              ),
              elevation: 5,
            ),
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : const Text(
              'VERIFY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Resend code option
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Didn't receive the code? ",
                style: TextStyle(color: Colors.white70),
              ),
              TextButton(
                onPressed: _canResend && !_isLoading ? _resendOTP : null,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber,
                ),
                child: Text(
                  _canResend ? 'RESEND CODE' : 'RESEND IN $_resendSeconds s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _canResend ? Colors.amber : Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          // Animation for visual appeal
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.security,
                    color: Colors.blue.withOpacity(0.7),
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPDigitField(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? Colors.amber
              : Colors.blue.shade700,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              // Move to next field when digit is entered
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else {
                // Last digit, hide keyboard
                _focusNodes[index].unfocus();
              }
            } else if (index > 0) {
              // Move to previous field when digit is deleted
              _focusNodes[index - 1].requestFocus();
            }
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
    );
  }
}
