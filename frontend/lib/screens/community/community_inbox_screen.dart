import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../../exceptions/session_expired_exception.dart';
import '../../services/api_services.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';

import '../chat/chat_screen.dart';
import 'community_detail_screen.dart';
import 'community_creation_screen.dart';


class CommunityInboxScreen extends StatefulWidget {
  const CommunityInboxScreen({
    super.key,
  });

  @override
  State<CommunityInboxScreen> createState() =>
      _CommunityInboxScreenState();
}

class _CommunityInboxScreenState
    extends State<CommunityInboxScreen>
    with SingleTickerProviderStateMixin {
  static const Color _navy = Color(0xFF18335A);
  static const Color _blue = Color(0xFF1976D2);
  static const Color _background = Color(0xFFF6F8FB);
  static const Color _red = Color(0xFFE53935);

  late TabController _tabController;

  String? currentUserId;

  bool isLoadingUser = true;

  late Future<List<dynamic>> _chatsFuture;
  late Future<List<dynamic>> _friendsFuture;
  late Future<List<dynamic>> _communitiesFuture;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _loadCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // CURRENT USER
  // ==========================================================================

  Future<void> _loadCurrentUser() async {
    try {
      final me = await AuthService.getCurrentUser();

      if (!mounted) return;

      final id =
          me['id']?.toString() ??
              me['_id']?.toString();

      setState(() {
        currentUserId = id;
        isLoadingUser = false;
      });

      _loadAllData();
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



  void _loadAllData() {
    _chatsFuture = MessagingService.getChats();
    _friendsFuture = FriendService.getAll();
    _communitiesFuture = CommunityService.getMine();
  }

  Future<void> _refreshChats() async {
    setState(() {
      _chatsFuture = MessagingService.getChats();
    });

    await _chatsFuture;
  }

  Future<void> _refreshFriends() async {
    setState(() {
      _friendsFuture = FriendService.getAll();
    });

    await _friendsFuture;
  }

  Future<void> _refreshCommunities() async {
    setState(() {
      _communitiesFuture = CommunityService.getMine();
    });

    await _communitiesFuture;
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        title: const Text(
          'Inbox',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _blue,
          indicatorWeight: 3,
          labelColor: _navy,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(
              icon: Icon(
                Icons.chat_bubble_outline,
              ),
              text: 'Chats',
            ),
            Tab(
              icon: Icon(
                Icons.people_outline,
              ),
              text: 'Friends',
            ),
            Tab(
              icon: Icon(
                Icons.groups_outlined,
              ),
              text: 'Communities',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _chatsList(),
          _friendsList(),
          _communitiesList(),
        ],
      ),
      floatingActionButton: _buildCreateCommunityButton(),
    );
  }

  // ==========================================================================
  // CHATS
  // ==========================================================================

  Widget _buildAIChatTile() {

    return Card(
      margin: const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8,
      ),

      child: ListTile(

        leading: const CircleAvatar(
          child: Icon(
            Icons.smart_toy_outlined,
          ),
        ),

        title: const Text(
          'Travel & App Assistant',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),

        subtitle: const Text(
          'Ask about the app or travel',
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap:
        _openAIChat,
      ),
    );
  }

  Widget _chatsList() {
    return FutureBuilder<List<dynamic>>(
      future: _chatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorState(
            message: 'Failed to load conversations.',
            onRetry: _refreshChats,
          );
        }

        final chats = snapshot.data ?? [];

        // Prevent the AI conversation from appearing twice:
        // once as the permanent AI tile and once in the backend chat list.
        final normalChats = chats.where((chat) {
          if (chat is! Map) return true;

          return chat['type'] != 'ai';
        }).toList();

        return RefreshIndicator(
          onRefresh: _refreshChats,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              100,
            ),
            itemCount: normalChats.length + 1,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 6),
            itemBuilder: (_, index) {
              // AI assistant is always the first item.
              if (index == 0) {
                return _buildAIChatTile();
              }

              final chat = Map<String, dynamic>.from(
                normalChats[index - 1] as Map,
              );

              return _chatTile(chat);
            },
          ),
        );
      },
    );
  }

  Widget _chatTile(
      Map<String, dynamic> chat,
      ) {
    final isCommunity =
        chat['type'] == 'community';

    final unread =
        chat['unread'] == true;

    Map<String, dynamic> otherParticipant = {};

    if (!isCommunity) {
      final rawOther =
      chat['otherParticipant'];

      if (rawOther is Map) {
        otherParticipant =
        Map<String, dynamic>.from(rawOther);
      }

      // Fallback for older backend responses.
      if (otherParticipant.isEmpty) {
        final participants =
            (chat['participants'] as List?) ?? [];

        for (final raw in participants) {
          if (raw is! Map) continue;

          final participant =
          Map<String, dynamic>.from(raw);

          final id =
              participant['id']?.toString() ??
                  participant['_id']?.toString();

          if (id != null &&
              id.isNotEmpty &&
              id != currentUserId) {
            otherParticipant = participant;
            break;
          }
        }
      }
    }

    String name;

    if (isCommunity) {
      final community = chat['community'];

      name = community is Map
          ? community['name']?.toString() ??
          'Community'
          : 'Community';
    } else {
      final firstName =
          otherParticipant['firstName']
              ?.toString() ??
              '';

      final lastName =
          otherParticipant['lastName']
              ?.toString() ??
              '';

      name = '$firstName $lastName'.trim();

      if (name.isEmpty) {
        name = 'Unknown';
      }
    }

    final lastMessage =
        chat['lastMessage']?.toString() ?? '';

    final conversationId =
        (chat['_id'] ?? chat['id'])?.toString() ??
            '';

    // IMPORTANT:
    // This variable exists in this method because it is
    // extracted from the other participant.
    final profilePicture =
    otherParticipant['profilePicture']
        ?.toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: conversationId.isEmpty
            ? null
            : () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId:
                conversationId,
                title: name,
                currentUserId:
                currentUserId ?? '',
                profilePicture:
                profilePicture,
              ),
            ),
          );

          if (!mounted) return;

          await _refreshChats();
        },
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: unread
                ? const Color(0xFFEAF3FF)
                : Colors.white,
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color: unread
                  ? const Color(0xFFB9D7FA)
                  : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _ConversationAvatar(
                name: name,
                profilePicture:
                profilePicture,
                isCommunity: isCommunity,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _navy,
                              fontSize: 16,
                              fontWeight: unread
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 9,
                            height: 9,
                            decoration:
                            const BoxDecoration(
                              color: _red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      lastMessage.isEmpty
                          ? 'No messages yet'
                          : lastMessage,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unread
                            ? _navy
                            : Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: unread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAIChat() async {
    try {
      final conversation =
      await AIChatService.getOrCreateConversation();

      final conversationId =
          conversation['id']?.toString() ??
              conversation['_id']?.toString();

      if (conversationId == null || conversationId.isEmpty) {
        throw Exception(
          'AI conversation ID missing.',
        );
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            title: 'Travel & App Assistant',
            currentUserId: currentUserId ?? '',
            profilePicture: null,
            isAI: true,
          ),
        ),
      );

      if (!mounted) return;

      await _refreshChats();
    } catch (e) {
      debugPrint(
        'Unable to open AI chat: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open AI assistant.',
          ),
        ),
      );
    }
  }

  Future<void> _openCommunity({
    required String communityId,
    required String name,
  }) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityDetailScreen(
            communityId: communityId,
            communityName: name,
          ),
        ),
      );

      if (!mounted) return;

      await _refreshCommunities();
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Could not open community: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open community.',
          ),
        ),
      );
    }
  }

  // ==========================================================================
  // FRIENDS
  // ==========================================================================

  Widget _friendsList() {
    return FutureBuilder<List<dynamic>>(
      future: _friendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorState(
            message: 'Failed to load friends.',
            onRetry: _refreshFriends,
          );
        }

        final friends = snapshot.data ?? [];

        if (friends.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            title: 'No friends yet',
            subtitle: 'Search for people in the Community tab to connect.',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshFriends,
          child: ListView.builder(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              100,
            ),
            itemCount: friends.length,
            itemBuilder: (_, index) {
              return _friendTile(
                Map<String, dynamic>.from(
                  friends[index] as Map,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _friendTile(
      Map<String, dynamic> friend,
      ) {
    final firstName =
        friend['firstName']?.toString() ?? '';

    final lastName =
        friend['lastName']?.toString() ?? '';

    final name =
    '$firstName $lastName'.trim().isEmpty
        ? 'Unknown'
        : '$firstName $lastName'.trim();

    final friendId =
        (friend['_id'] ?? friend['id'])
            ?.toString() ??
            '';

    final profilePicture =
    friend['profilePicture']?.toString();

    return _SocialPersonCard(
      name: name,
      profilePicture: profilePicture,
      trailing: FilledButton.icon(
        onPressed: friendId.isEmpty
            ? null
            : () => _openDirectChat(
          friendId,
          name,
          profilePicture:
          profilePicture,
        ),
        icon: const Icon(
          Icons.chat_bubble_outline,
          size: 16,
        ),
        label: const Text('Message'),
        style: FilledButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // COMMUNITIES
  // ==========================================================================

  Widget _communitiesList() {
    return FutureBuilder<List<dynamic>>(
      future: _communitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorState(
            message: 'Failed to load communities.',
            onRetry: _refreshCommunities,
          );
        }

        final communities =
            snapshot.data ?? [];

        if (communities.isEmpty) {
          return const EmptyState(
            icon: Icons.groups_outlined,
            title: 'No communities yet',
            subtitle:
            'Search for communities or create your own.',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshCommunities,
          child: ListView.builder(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              100,
            ),
            itemCount: communities.length,
            itemBuilder: (_, index) {
              return _communityTile(
                Map<String, dynamic>.from(
                  communities[index] as Map,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _communityTile(
      Map<String, dynamic> community,
      ) {
    final communityId =
        (community['communityId'] ??
            community['id'])
            ?.toString() ??
            '';

    final name =
        community['name']?.toString() ??
            'Community';

    final role =
        community['role']?.toString().toLowerCase() ??
            'member';

    final status =
        community['status']?.toString().toLowerCase() ??
            'active';

    final cover =
    community['coverImage']?.toString();

    String roleLabel;
    IconData roleIcon;
    Color roleColor;

    switch (role) {
      case 'owner':
        roleLabel = 'Owner';
        roleIcon = Icons.workspace_premium_outlined;
        roleColor = Colors.orange.shade700;
        break;

      case 'admin':
        roleLabel = 'Admin';
        roleIcon = Icons.shield_outlined;
        roleColor = Colors.orange.shade700;
        break;

      case 'moderator':
        roleLabel = 'Moderator';
        roleIcon = Icons.admin_panel_settings_outlined;
        roleColor = Colors.blue.shade700;
        break;

      default:
        roleLabel = 'Member';
        roleIcon = Icons.person_outline;
        roleColor = Colors.grey.shade600;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),

        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFEAF3FF),
          backgroundImage:
          cover != null && cover.isNotEmpty
              ? NetworkImage(cover)
              : null,
          child:
          cover == null || cover.isEmpty
              ? const Icon(
            Icons.groups_rounded,
            color: _blue,
          )
              : null,
        ),

        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _navy,
            fontWeight: FontWeight.w700,
          ),
        ),

        subtitle: Row(
          children: [
            Icon(
              roleIcon,
              size: 14,
              color: roleColor,
            ),
            const SizedBox(width: 5),
            Text(
              roleLabel,
              style: TextStyle(
                color: roleColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (status == 'pending') ...[
              const SizedBox(width: 8),
              Text(
                'Pending',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),

        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey,
        ),

        onTap: communityId.isEmpty
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CommunityDetailScreen(
                    communityId: communityId,
                    communityName: name,
                  ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // DIRECT CHAT
  // ==========================================================================

  Future<void> _openDirectChat(
      String participantId,
      String name, {
        String? profilePicture,
      }) async {
    if (currentUserId == null ||
        currentUserId!.isEmpty) {
      await _loadCurrentUser();

      if (!mounted) return;
    }

    try {
      final conversation =
      await MessagingService
          .getOrCreateDirectChat(
        participantId,
      );

      if (!mounted) return;

      final conversationId =
      (conversation['_id'] ??
          conversation['id'])
          ?.toString();

      if (conversationId == null ||
          conversationId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not get conversation.',
            ),
          ),
        );

        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            title: name,
            currentUserId:
            currentUserId ?? '',
            profilePicture:
            profilePicture,
          ),
        ),
      );

      if (!mounted) return;

      await _refreshChats();
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Could not open chat: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open chat.',
          ),
        ),
      );
    }
  }

  // ==========================================================================
  // CREATE COMMUNITY
  // ==========================================================================

  Widget _buildCreateCommunityButton() {
    return FloatingActionButton.extended(
      backgroundColor: _blue,
      foregroundColor: Colors.white,
      icon: const Icon(
        Icons.group_add_outlined,
      ),
      label: const Text(
        'Create community',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const CreateCommunityScreen(),
          ),
        );

        if (!mounted) return;

        await _refreshCommunities();
      },
    );
  }
}

// ============================================================================
// CONVERSATION AVATAR
// ============================================================================

class _ConversationAvatar extends StatelessWidget {
  final String name;
  final String? profilePicture;
  final bool isCommunity;

  const _ConversationAvatar({
    required this.name,
    required this.profilePicture,
    required this.isCommunity,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      source: profilePicture,
      name: name,
      radius: 27,
      isCommunity: isCommunity,
    );
  }
}

// ============================================================================
// SOCIAL PERSON CARD
// ============================================================================

class _SocialPersonCard
    extends StatelessWidget {
  final String name;
  final String? profilePicture;
  final Widget trailing;

  const _SocialPersonCard({
    required this.name,
    required this.profilePicture,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _ConversationAvatar(
              name: name,
              profilePicture:
              profilePicture,
              isCommunity: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF18335A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

