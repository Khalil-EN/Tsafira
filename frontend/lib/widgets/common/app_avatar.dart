import 'package:flutter/material.dart';

/// Single source of truth for rendering a user or community avatar.
///
/// Handles all three cases every screen was reimplementing separately:
///  - a network URL (http/https)
///  - a local asset name (looked up under assets/avatars/)
///  - no image at all (falls back to initials, or a group icon for
///    communities)
class AppAvatar extends StatelessWidget {
  final String? source;
  final String name;
  final double radius;
  final bool isCommunity;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppAvatar({
    super.key,
    required this.source,
    this.name = '',
    this.radius = 24,
    this.isCommunity = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  bool get _isNetworkImage {
    final value = source?.trim() ?? '';
    return value.startsWith('http://') || value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final value = source?.trim() ?? '';

    final bg = backgroundColor ??
        (isCommunity
            ? const Color(0xFFEAF3FF)
            : const Color(0xFFE4F7F1));

    final fg = foregroundColor ?? const Color(0xFF18335A);

    if (value.isNotEmpty) {
      final image = _isNetworkImage
          ? NetworkImage(value)
          : AssetImage('assets/avatars/$value.png') as ImageProvider;

      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        backgroundImage: image,
        onBackgroundImageError: (_, __) {},
      );
    }

    if (isCommunity) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: Icon(
          Icons.groups_rounded,
          size: radius,
          color: fg,
        ),
      );
    }

    final initial = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}