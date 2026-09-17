import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:table_calendar_example/providers/user_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../services/api_services.dart';
import '../common/app_avatar.dart';

class AppMenu extends StatelessWidget {
  final VoidCallback onClose;

  const AppMenu({
    super.key,
    required this.onClose,
  });

  static const Color _navy = Color(0xFF18335A);
  static const Color _background = Color(0xFFF6F8FB);
  static const Color _red = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Stack(
      children: [
        // Dimmed overlay background
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black.withOpacity(0.30),
            ),
          ),
        ),

        // Side drawer content
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          child: Material(
            color: Colors.white,
            elevation: 12,
            child: SizedBox(
              width: 300,
              child: SafeArea(
                child: Column(
                  children: [
                    _HeaderSection(
                      userProvider: userProvider,
                      onClose: onClose,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    Expanded(
                      child: _MenuList(
                        isAdmin: userProvider.isAdmin,
                        onClose: onClose,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: _background,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _LogoutButton(onClose: onClose),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final UserProvider userProvider;
  final VoidCallback onClose;

  const _HeaderSection({
    required this.userProvider,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = userProvider.fullName.trim().isNotEmpty
        ? userProvider.fullName.trim()
        : 'Guest';
    final email = userProvider.email.trim();

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          onClose();
          Navigator.pushNamed(context, '/profile');
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 16),
          child: Row(
            children: [
              AppAvatar(
                source: userProvider.avatar,
                name: userProvider.firstName,
                radius: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppMenu._navy,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    if (userProvider.isAdmin)
                      const _RoleBadge(
                        label: 'Administrator',
                        icon: Icons.shield_outlined,
                        color: Colors.amber,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onClose;

  const _MenuList({
    required this.isAdmin,
    required this.onClose,
  });

  void _navigateTo(BuildContext context, String routeName) {
    onClose();
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const _SectionLabel(text: 'ACCOUNT'),
        _MenuItem(
          icon: Icons.person_outline,
          title: 'My Profile',
          onTap: () => _navigateTo(context, '/profile'),
        ),
        _MenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () => _navigateTo(context, '/notifications'),
        ),
        _MenuItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () => _navigateTo(context, '/settings'),
        ),
        const SizedBox(height: 8),
        const _SectionLabel(text: 'TRAVEL'),
        _MenuItem(
          icon: Icons.map_outlined,
          title: 'My Trip Places',
          onTap: () {
            onClose();
            // TODO: Add route when screen exists
          },
        ),
        const SizedBox(height: 8),
        const _SectionLabel(text: 'HELP & INFORMATION'),
        _MenuItem(
          icon: Icons.support_agent_outlined,
          title: 'Customer Support',
          onTap: onClose,
        ),
        _MenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy & Policy',
          onTap: onClose,
        ),
        _MenuItem(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          onTap: onClose,
        ),
        if (isAdmin) ...[
          const SizedBox(height: 8),
          const _SectionLabel(text: 'ADMINISTRATION'),
          _MenuItem(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Admin Dashboard',
            color: Colors.amber.shade800,
            onTap: () => _navigateTo(context, '/admin'),
          ),
        ],
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? Colors.grey.shade700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Icon(icon, size: 22, color: itemColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: itemColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 19,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _RoleBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onClose;

  const _LogoutButton({required this.onClose});

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await AuthService.logout(); // Make sure this matches your service class

      if (!context.mounted) return;
      context.read<UserProvider>().clearUser();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to log out. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, size: 19),
        label: const Text(
          'Logout',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppMenu._red,
          side: BorderSide(color: AppMenu._red.withOpacity(0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => _handleLogout(context),
      ),
    );
  }
}