import 'package:flutter/material.dart';

class ChecklistRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const ChecklistRow({
    super.key,
    required this.label,
    this.icon = Icons.check_circle,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}