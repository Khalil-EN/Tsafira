import 'package:flutter/material.dart';

class AuthToggle extends StatelessWidget {
  final bool isLoginSelected;
  final VoidCallback onSelectLogin;
  final VoidCallback onSelectSignup;

  const AuthToggle({
    super.key,
    required this.isLoginSelected,
    required this.onSelectLogin,
    required this.onSelectSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSelectLogin,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isLoginSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isLoginSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isLoginSelected ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onSelectSignup,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !isLoginSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isLoginSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: !isLoginSelected ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}