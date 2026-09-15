import 'package:flutter/material.dart';
import 'selectable_list_tile.dart';

/// A small grid chip variant of SelectableListTile — used where several
/// short options need to sit in a 2-column GridView.
class SelectableFeatureChip extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  const SelectableFeatureChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? SelectableListTile.selectedColor
              : SelectableListTile.unselectedBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: fg, fontWeight: FontWeight.w500, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}