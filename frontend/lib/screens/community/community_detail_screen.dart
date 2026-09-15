import 'package:flutter/material.dart';
import 'community_join_requests_screen.dart';
import 'community_posts_screen.dart';
import '../../exceptions/session_expired_exception.dart';
import '../auth/login_screen.dart';
import '../../services/api_services.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/role_badge.dart';
import '../../utils/safe_dialog.dart';
import '../../widgets/common/error_state.dart';

class CommunityDetailScreen extends StatefulWidget {
  final String communityId;
  final String communityName;

  const CommunityDetailScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  State<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState
    extends State<CommunityDetailScreen> {
  static const Color _navy = Color(0xFF18335A);
  static const Color _blue = Color(0xFF1976D2);
  static const Color _background = Color(0xFFF6F8FB);

  bool _isLoading = true;
  bool _isRefreshing = false;

  String? _currentUserId;
  bool isLoadingUser = true;

  Map<String, dynamic>? _community;
  String? _viewerRole;
  List<Map<String, dynamic>> _members = [];

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCommunity();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final me = await AuthService.getCurrentUser();

      if (!mounted) return;

      final id =
          me['id']?.toString() ??
              me['_id']?.toString();

      setState(() {
        _currentUserId = id;
        isLoadingUser = false;
      });

    } on SessionExpiredException {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            showSessionExpired: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Failed to load current user: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoadingUser = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load your account.',
          ),
        ),
      );
    }
  }

  Future<void> _loadCommunity({
    bool refresh = false,
  }) async {
    if (refresh) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = '';
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final results = await Future.wait([
        CommunityService.getById(
          widget.communityId,
        ),
        CommunityService.getMembers(
          widget.communityId,
        ),
      ]);

      if (!mounted) return;

      // GET /communities/:id now returns a detail
      // envelope: { community, viewerRole, viewerStatus }
      // rather than a flat community object.
      final detail =
      Map<String, dynamic>.from(
        results[0] as Map,
      );

      final community =
      Map<String, dynamic>.from(
        detail['community'] as Map,
      );

      final viewerRole =
      detail['viewerRole']
          ?.toString()
          .toLowerCase();

      final members =
      (results[1] as List)
          .map(
            (item) =>
        Map<String, dynamic>.from(
          item as Map,
        ),
      )
          .toList();

      setState(() {
        _community = community;
        _viewerRole = viewerRole;
        _members = members;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Failed to load community: $e',
      );

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage =
        'Could not load this community.';
      });
    }
  }

  Future<void> _refresh() async {
    await _loadCommunity(refresh: true);
  }

  bool _isEditDialogOpen = false;

  Future<void> _editCommunity() async {
    if (_isEditDialogOpen) return;
    _isEditDialogOpen = true;

    final community = _community!;
    final nameController =
    TextEditingController(text: community['name']?.toString() ?? '');
    final descriptionController = TextEditingController(
      text: community['description']?.toString() ?? '',
    );

    try {
      final result = await showSafeDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit community'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      final name = nameController.text.trim();
      final description = descriptionController.text.trim();

      if (result != true || name.isEmpty || !mounted) return;

      await CommunityService.update(
        communityId: widget.communityId,
        data: {'name': name, 'description': description},
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community updated.')),
      );

      await _loadCommunity(refresh: true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update community.')),
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      _isEditDialogOpen = false;
    }
  }

  Future<void> _deleteCommunity() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete community?',
      message:
      'This will permanently remove the community, its members, and its posts. This cannot be undone.',
      confirmLabel: 'Delete',
    );

    if (!confirmed || !mounted) return;

    try {
      await CommunityService.delete(widget.communityId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community deleted.')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete community.')),
      );
    }
  }

  Future<void> _handleMemberAction(
      String action,
      String targetUserId,
      String targetName,
      ) async {
    String? role;

    switch (action) {
      case 'promote_moderator':
        role = 'moderator';
        break;
      case 'promote_admin':
        role = 'admin';
        break;
      case 'demote_member':
        role = 'member';
        break;
      case 'ban':
        role = null;
        break;
    }

    try {
      if (action == 'ban') {
        final confirmed = await showConfirmDialog(
          context: context,
          title: 'Ban member?',
          message: '$targetName will be removed and unable to rejoin.',
          confirmLabel: 'Ban',
        );

        if (!confirmed) return;

        await CommunityService.banMember(
          communityId: widget.communityId,
          userId: targetUserId,
        );
      } else {
        await CommunityService.promoteMember(
          communityId: widget.communityId,
          userId: targetUserId,
          role: role!,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated $targetName.')),
      );

      await _loadCommunity(refresh: true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not complete that action.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        title: Text(
          widget.communityName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
            _isRefreshing ? null : _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty &&
        _community == null) {
      return _buildErrorState();
    }

    if (_community == null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ),
        children: [
          _buildCommunityHeader(),
          const SizedBox(height: 16),
          _buildStats(),
          const SizedBox(height: 16),
          _buildActions(),
          const SizedBox(height: 16),
          _buildMembersSection(),
        ],
      ),
    );
  }

  Widget _buildCommunityHeader() {
    final community = _community!;

    final name =
        community['name']?.toString() ??
            widget.communityName;

    final description =
        community['description']
            ?.toString()
            .trim() ??
            '';

    final coverImage =
    community['coverImage']
        ?.toString();

    final privacy =
        community['privacy']
            ?.toString()
            .toLowerCase() ??
            'public';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildCover(
            coverImage,
          ),

          Padding(
            padding:
            const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 25,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),
                    _buildPrivacyBadge(
                      privacy,
                    ),
                  ],
                ),

                if (description
                    .isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      color:
                      Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                _buildRoleBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(
      String? coverImage,
      ) {
    if (coverImage != null &&
        coverImage.isNotEmpty) {
      return SizedBox(
        height: 190,
        width: double.infinity,
        child: Image.network(
          coverImage,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) =>
              _buildDefaultCover(),
        ),
      );
    }

    return _buildDefaultCover();
  }

  Widget _buildDefaultCover() {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF3FF),
      ),
      child: const Center(
        child: Icon(
          Icons.groups_rounded,
          size: 70,
          color: _blue,
        ),
      ),
    );
  }

  Widget _buildPrivacyBadge(
      String privacy,
      ) {
    final isPrivate =
        privacy == 'private';

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isPrivate
            ? Colors.orange.shade50
            : Colors.green.shade50,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            isPrivate
                ? Icons.lock_outline
                : Icons.public,
            size: 14,
            color: isPrivate
                ? Colors.orange.shade700
                : Colors.green.shade700,
          ),
          const SizedBox(width: 5),
          Text(
            isPrivate
                ? 'Private'
                : 'Public',
            style: TextStyle(
              color: isPrivate
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    return RoleBadge(role: _viewerRole);
  }

  Widget _buildStats() {
    final membersCount =
        _community!['membersCount'] ??
            _members.length;

    final postsCount =
        _community!['postsCount'] ??
            0;

    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              icon: Icons.people_outline,
              value:
              membersCount.toString(),
              label: 'Members',
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _statItem(
              icon:
              Icons.article_outlined,
              value:
              postsCount.toString(),
              label: 'Posts',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: _blue,
          size: 23,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: _navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final canManageMembers =
        _viewerRole == 'owner' ||
            _viewerRole == 'admin';

    final canEditCommunity = canManageMembers; // same rule as edit permission on the backend
    final isOwner = _viewerRole == 'owner';

    return Column(
      children: [
        _actionCard(
          icon: Icons.article_outlined,
          title: 'Community posts',
          subtitle: 'View and interact with community posts.',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CommunityPostsScreen(
                  communityId: widget.communityId,
                  communityName:
                  _community?['name']?.toString() ?? widget.communityName,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 10),

        _actionCard(
          icon: Icons.people_outline,
          title: 'Members',
          subtitle: '${_members.length} members in this community.',
          onTap: _showMembers,
        ),

        if (canManageMembers) ...[
          const SizedBox(height: 10),
          _actionCard(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Join requests',
            subtitle: 'Review people waiting to join.',
            badge: 'Manage',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CommunityJoinRequestsScreen(
                    communityId: widget.communityId,
                  ),
                ),
              );
            },
          ),
        ],

        if (canEditCommunity) ...[
          const SizedBox(height: 10),
          _actionCard(
            icon: Icons.edit_outlined,
            title: 'Edit community',
            subtitle: 'Update the name and description.',
            onTap: _editCommunity,
          ),
        ],

        if (isOwner) ...[
          const SizedBox(height: 10),
          _actionCard(
            icon: Icons.delete_outline,
            title: 'Delete community',
            subtitle: 'Permanently remove this community.',
            onTap: _deleteCommunity,
          ),
        ],
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Padding(
          padding:
          const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFEAF3FF),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: _blue,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        color: _navy,
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              if (badge != null)
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFEAF3FF),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style:
                    const TextStyle(
                      color: _blue,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
      ),
      padding:
      const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        8,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Members',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: _showMembers,
                child:
                const Text('See all'),
              ),
            ],
          ),

          if (_members.isEmpty)
            Padding(
              padding:
              const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No members found.',
                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            ..._members
                .take(5)
                .map(_memberTile),
        ],
      ),
    );
  }

  Widget _memberTile(
      Map<String, dynamic> member,
      ) {
    final user =
    member['user'] is Map
        ? Map<String, dynamic>.from(
      member['user'] as Map,
    )
        : member;

    final firstName =
        user['firstName']
            ?.toString() ??
            '';

    final lastName =
        user['lastName']
            ?.toString() ??
            '';

    final name =
    '$firstName $lastName'
        .trim()
        .isEmpty
        ? 'Unknown user'
        : '$firstName $lastName'
        .trim();

    final profilePicture =
    user['profilePicture']
        ?.toString();

    final role =
        member['role']
            ?.toString()
            .toLowerCase() ??
            'member';

    final targetUserId =
        (user['id'] ?? user['_id'])
            ?.toString() ??
            '';

    final canManage =
        (_viewerRole == 'owner' ||
            _viewerRole == 'admin') &&
            role != 'owner' &&
            targetUserId.isNotEmpty &&
            targetUserId != _currentUserId;

    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(
        vertical: 2,
      ),
      leading: _memberAvatar(
        name: name,
        profilePicture:
        profilePicture,
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: _navy,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        _roleLabel(role),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: canManage
          ? PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onSelected: (value) =>
            _handleMemberAction(value, targetUserId, name),
        itemBuilder: (context) => [
          if (role != 'moderator')
            const PopupMenuItem(
              value: 'promote_moderator',
              child: Text('Make moderator'),
            ),
          if (role != 'admin' && _viewerRole == 'owner')
            const PopupMenuItem(
              value: 'promote_admin',
              child: Text('Make admin'),
            ),
          if (role != 'member')
            const PopupMenuItem(
              value: 'demote_member',
              child: Text('Set as member'),
            ),
          const PopupMenuItem(
            value: 'ban',
            child: Text('Ban from community',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      )
          : null,
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'owner':
        return 'Owner';
      case 'admin':
        return 'Admin';
      case 'moderator':
        return 'Moderator';
      default:
        return 'Member';
    }
  }

  Widget _memberAvatar({
    required String name,
    required String? profilePicture,
  }) {
    return AppAvatar(
      source: profilePicture,
      name: name,
      radius: 22,
    );
  }

  void _showMembers() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height:
          MediaQuery.of(context)
              .size
              .height *
              0.82,
          decoration:
          const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color:
                  Colors.grey.shade300,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Community Members',
                style: TextStyle(
                  color: _navy,
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child:
                _members.isEmpty
                    ? const Center(
                  child: Text(
                    'No members found.',
                  ),
                )
                    : ListView.builder(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    16,
                    8,
                    16,
                    24,
                  ),
                  itemCount:
                  _members.length,
                  itemBuilder:
                      (_, index) {
                    return _memberTile(
                      _members[index],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return ErrorState(
      title: 'Could not load community',
      message: 'Please check your connection and try again.',
      icon: Icons.groups_outlined,
      onRetry: () => _loadCommunity(),
    );
  }
}