import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/navigation/home_nav.dart';
import '../../providers/user_provider.dart';
import '../../services/api_services.dart';
import '../auth/login_screen.dart';
import '../../widgets/common/app_avatar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _blue = Color(0xFF1976D2);
  static const Color _navy = Color(0xFF18335A);
  static const Color _background = Color(0xFFF6F8FB);

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ================================================================
  // LOAD USER
  // ================================================================

  bool _deleteDialogOpen = false;

  void _openDeleteAccountDialog() {
    if (_deleteDialogOpen) return;

    // Defer past this frame so the InkWell's own tap/splash
    // overlay entry finishes before a dialog route competes for
    // the same Overlay — the same Flutter "Duplicate GlobalKeys"
    // race hit earlier with the community edit dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confirmAndDeleteAccount();
      }
    });
  }

  Future<void> _confirmAndDeleteAccount() async {
    if (_deleteDialogOpen) return;
    _deleteDialogOpen = true;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'This will permanently delete your account, your posts, '
                'and your comments, and remove you from your communities '
                'and friends lists. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      try {
        await AuthService.deleteAccount();

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete your account.')),
        );
      }
    } finally {
      _deleteDialogOpen = false;
    }
  }

  Future<void> _loadUser() async {
    try {
      await AuthService.getCurrentUser();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load your profile.';
      });
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: _background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: _buildBody(userProvider),

      bottomNavigationBar: const HomeNav(
        selectedIndex: 4,
      ),
    );
  }

  // ================================================================
  // BODY
  // ================================================================

  Widget _buildBody(UserProvider userProvider) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    return RefreshIndicator(
      onRefresh: _loadUser,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          32,
        ),
        children: [
          _buildProfileHeader(userProvider),

          const SizedBox(height: 20),

          _buildAccountCard(userProvider),

          const SizedBox(height: 16),

          _buildTravelCard(),

          const SizedBox(height: 16),

          _buildActivityCard(),
        ],
      ),
    );
  }

  // ================================================================
  // PROFILE HEADER
  // ================================================================

  Widget _buildProfileHeader(
      UserProvider userProvider,
      ) {
    final fullName = userProvider.fullName.trim().isNotEmpty
        ? userProvider.fullName.trim()
        : 'Guest';

    final email = userProvider.email.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              _buildAvatar(
                userProvider,
                radius: 54,
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: _blue,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _openEditProfile,
                    child: const Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.edit,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),

          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],

          const SizedBox(height: 10),

          _buildRoleBadge(userProvider),
        ],
      ),
    );
  }

  // ================================================================
  // AVATAR
  // ================================================================

  Widget _buildAvatar(UserProvider userProvider, {double radius = 54}) {
    return AppAvatar(
      source: userProvider.avatar,
      name: userProvider.firstName,
      radius: radius,
    );
  }

  // ================================================================
  // ROLE
  // ================================================================

  Widget _buildRoleBadge(
      UserProvider userProvider,
      ) {
    String label;
    IconData icon;
    Color color;

    if (userProvider.isAdmin) {
      label = 'Administrator';
      icon = Icons.shield_outlined;
      color = Colors.amber.shade800;
    } else {
      // Adapt this if your UserProvider exposes isPremium.
      label = 'Traveler';
      icon = Icons.flight_takeoff;
      color = _blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ACCOUNT CARD
  // ================================================================

  Widget _buildAccountCard(UserProvider userProvider) {
    return _buildCard(
      title: 'Account',
      icon: Icons.person_outline,
      children: [
        _profileAction(
          icon: Icons.edit_outlined,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: _openEditProfile,
        ),
        _profileAction(
          icon: Icons.lock_outline,
          title: 'Password & Security',
          subtitle: 'Manage your password and security',
          onTap: () {},
        ),
        _profileAction(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Settings',
          subtitle: 'Control your account privacy',
          onTap: () {},
        ),
        _profileAction(
          icon: Icons.delete_forever_outlined,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account and data',
          color: Colors.red,
          onTap: _openDeleteAccountDialog,
        ),
      ],
    );
  }

  // ================================================================
  // TRAVEL CARD
  // ================================================================

  Widget _buildTravelCard() {
    return _buildCard(
      title: 'My Travel',
      icon: Icons.flight_takeoff_outlined,
      children: [
        _profileAction(
          icon: Icons.track_changes,
          title: 'My Plans',
          subtitle: 'View and manage your travel plans',
          onTap: () {
            // Add route.
          },
        ),

        _profileAction(
          icon: Icons.history,
          title: 'Travel History',
          subtitle: 'See your previous trips',
          onTap: () {
            // Add route.
          },
        ),

        _profileAction(
          icon: Icons.place_outlined,
          title: 'Saved Places',
          subtitle: 'Places you saved for later',
          onTap: () {
            // Add route.
          },
        ),
      ],
    );
  }

  // ================================================================
  // ACTIVITY CARD
  // ================================================================

  Widget _buildActivityCard() {
    return _buildCard(
      title: 'Activity',
      icon: Icons.insights_outlined,
      children: [
        _profileAction(
          icon: Icons.groups_outlined,
          title: 'My Communities',
          subtitle: 'Communities you belong to',
          onTap: () {
            // Add route.
          },
        ),

        _profileAction(
          icon: Icons.people_outline,
          title: 'My Friends',
          subtitle: 'Manage your friends',
          onTap: () {
            // Add route.
          },
        ),
      ],
    );
  }

  // ================================================================
  // CARD
  // ================================================================

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              8,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: _blue,
                ),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
              ],
            ),
          ),

          ...children,
        ],
      ),
    );
  }

  // ================================================================
  // PROFILE ACTION
  // ================================================================

  Widget _profileAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final accentColor = color ?? _blue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // ERROR
  // ================================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Colors.grey.shade500,
            ),

            const SizedBox(height: 14),

            Text(
              _errorMessage ??
                  'Unable to load your profile.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });

                _loadUser();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // EDIT PROFILE
  // ================================================================

  Future<void> _openEditProfile() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          user: Map<String, dynamic>.from(user),
        ),
      ),
    );

    if (!mounted) return;

    await _loadUser();
  }
}


