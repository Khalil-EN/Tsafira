import 'package:flutter/material.dart';

/// A labeled bordered box, used two ways across the search screens:
/// as a text-entry field (pass [controller]), or as a tappable
/// display value (pass [displayValue] + [onTap], e.g. a date picker).
class LabeledFieldBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? displayValue;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const LabeledFieldBox({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.displayValue,
    this.onTap,
    this.keyboardType,
    this.onChanged,
  }) : assert(
  controller != null || displayValue != null,
  'Provide either a controller (editable) or a displayValue (tappable).',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (controller != null)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: onChanged,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(displayValue!),
                ],
              ),
            ),
          ),
      ],
    );
  }
}