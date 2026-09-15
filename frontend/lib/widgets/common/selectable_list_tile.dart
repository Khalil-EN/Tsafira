import 'package:flutter/material.dart';

/// The purple/lavender "tap to select" row used across every step of the
/// trip-planning wizard. Handles both shapes that kept getting
/// reimplemented: an icon leading the text (activity/location pickers)
/// and a trailing image/icon (traveler type, budget tier).
class SelectableListTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? badge;
  final EdgeInsetsGeometry padding;

  const SelectableListTile({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.badge,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  static const selectedColor = Color(0xFF6C63FF);
  static const unselectedBackground = Color(0xFFF1EFFF);

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? Colors.white : selectedColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(data: IconThemeData(color: fg), child: leading!),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        badge!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}