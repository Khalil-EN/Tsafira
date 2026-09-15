// lib/screens/auth/verify_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:table_calendar_example/services/api_services.dart';

class VerifyScreen extends StatefulWidget {
  final String email;

  const VerifyScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  static const int _otpLength = 4;
  static const int _resendTimeoutSeconds = 60;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
        (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
        (_) => FocusNode(),
  );

  Timer? _timer;
  int _countdown = _resendTimeoutSeconds;

  bool _canResend = false;
  bool _isVerifying = false;
  bool _isResending = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();
    _countdown = _resendTimeoutSeconds;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  // ============================================================
  // OTP HELPERS
  // ============================================================

  String get _verificationCode {
    return _controllers.map((controller) => controller.text.trim()).join();
  }

  bool get _isCodeComplete {
    return _verificationCode.length == _otpLength;
  }

  void _onOtpChanged(String value, int index) {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    // Handle pasting multi-digit verification code
    if (value.length > 1) {
      final digits = value.trim().split('');
      for (int i = 0; i < _otpLength; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      FocusScope.of(context).unfocus();
      if (_isCodeComplete) {
        _verifyEmail();
      }
      return;
    }

    // Auto-advance focus forward
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-submit when complete
    if (_isCodeComplete) {
      _verifyEmail();
    }
  }

  void _clearOtpFields() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _verifyEmail() async {
    if (!_isCodeComplete || _isVerifying) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      await AuthService.verifyEmail(
        widget.email,
        _verificationCode,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (_) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Invalid or expired verification code.';
      });
      _clearOtpFields();
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await AuthService.resendVerificationCode(widget.email);

      if (!mounted) return;

      _clearOtpFields();
      _startTimer();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to resend the verification code.';
      });
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Verify',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildHeaderImage(),
              const SizedBox(height: 16),
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A 4 digit code has been sent to',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildOtpFields(),
              const SizedBox(height: 16),
              if (_errorMessage != null) _buildErrorMessage(),
              const SizedBox(height: 20),
              _buildVerifyButton(),
              const SizedBox(height: 20),
              _buildResendButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Center(
      child: Image.asset(
        'assets/test4.png',
        height: 180,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.mark_email_read_outlined,
          size: 100,
          color: Colors.blue[300],
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          width: 60,
          height: 60,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                if (_controllers[index].text.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              }
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              onChanged: (value) => _onOtpChanged(value, index),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      _errorMessage!,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isCodeComplete && !_isVerifying ? _verifyEmail : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          disabledBackgroundColor: Colors.blue.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isVerifying
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'Verify',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return GestureDetector(
      onTap: _canResend && !_isResending ? _resendCode : null,
      child: _isResending
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Text(
        _canResend
            ? 'Resend Code'
            : 'Resend Code (${_countdown.toString().padLeft(2, '0')})',
        style: TextStyle(
          fontSize: 15,
          fontWeight: _canResend ? FontWeight.w600 : FontWeight.normal,
          color: _canResend ? Colors.blue : Colors.grey[600],
          decoration: _canResend ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}