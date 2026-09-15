import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String logoPath;
  final String providerName;
  final VoidCallback onTap;

  const SocialAuthButton({
    super.key,
    required this.logoPath,
    required this.providerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            logoPath,
            width: 30,
            height: 30,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.login,
              size: 28,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}