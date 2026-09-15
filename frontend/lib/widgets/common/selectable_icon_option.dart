import 'package:flutter/material.dart';
import 'selectable_list_tile.dart';

/// A compact icon-over-label button, meant to sit inside a Row of
/// Expanded siblings (e.g. "Breakfast / Lunch / Dinner", "Hotel / Logement").
class SelectableIconOption extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  const SelectableIconOption({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? Colors.white : SelectableListTile.selectedColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? SelectableListTile.selectedColor
              : SelectableListTile.unselectedBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: fg, size: 26),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}