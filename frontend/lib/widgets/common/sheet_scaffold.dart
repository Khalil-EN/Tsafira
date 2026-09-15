import 'package:flutter/material.dart';

class SheetScaffold extends StatelessWidget {
  final double heightFactor;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const SheetScaffold({
    super.key,
    required this.heightFactor,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}