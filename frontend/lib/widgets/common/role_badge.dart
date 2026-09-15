import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final String? role;
  final bool compact;

  const RoleBadge({
    super.key,
    required this.role,
    this.compact = false,
  });

  static const _navy = Color(0xFF18335A);

  ({String label, IconData icon, Color color}) get _presentation {
    switch (role?.toLowerCase()) {
      case 'owner':
        return (
        label: compact ? 'Owner' : 'Community owner',
        icon: Icons.workspace_premium_outlined,
        color: Colors.orange.shade700,
        );
      case 'admin':
        return (
        label: compact ? 'Admin' : 'Community admin',
        icon: Icons.shield_outlined,
        color: Colors.orange.shade700,
        );
      case 'moderator':
        return (
        label: 'Moderator',
        icon: Icons.admin_panel_settings_outlined,
        color: Colors.blue.shade700,
        );
      default:
        return (
        label: 'Member',
        icon: Icons.person_outline,
        color: Colors.grey.shade700,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role == null || role!.isEmpty) {
      return const SizedBox.shrink();
    }

    final p = _presentation;

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(p.icon, size: 14, color: p.color),
          const SizedBox(width: 5),
          Text(
            p.label,
            style: TextStyle(
              color: p.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: p.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(p.icon, size: 17, color: p.color),
          const SizedBox(width: 7),
          Text(
            p.label,
            style: TextStyle(
              color: p.color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}