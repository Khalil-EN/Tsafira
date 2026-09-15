import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/navigation/home_nav.dart';
import '../community/community_inbox_screen.dart';
import '../posts/create_post_screen.dart';
import '../auth/login_screen.dart';
import '../../exceptions/session_expired_exception.dart';
import '../../models/Post.dart';
import '../../providers/user_provider.dart';
import '../../models/SocialSearchResult.dart';
import '../../services/api_services.dart';
import '../chat/chat_screen.dart';
import '../requests/requests_screen.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/community/community_post_card.dart';
import '../../widgets/community/search_result_card.dart';
import '../../widgets/community/search_result_sheet.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/home_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const Color _background = Color(0xFFF6F8FB);

  List<Post> _feed = [];
  List<SearchResult> _searchResults = [];

  bool _isLoadingFeed = true;
  bool _isSearching = false;
  bool _searchMode = false;
  bool _isLoadingUser = true;

  int _pendingRequestCount = 0;
  int _unreadChatCount = 0;

  String? _currentUserId;
  String? _searchError;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUser();
    _loadFeed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  // --- Current user ---------------------------------------------------------

  Future<void> _loadCurrentUser() async {
    try {
      final me = await AuthService.getCurrentUser();

      if (!mounted) return;

      final id = me['id']?.toString() ?? me['_id']?.toString();

      setState(() {
        _currentUserId = id;
        _isLoadingUser = false;
      });

      await _loadNotificationCounts();
    } on SessionExpiredException {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(showSessionExpired: true)));
    } catch (e) {
      debugPrint('Failed to load current user: $e');

      if (!mounted) return;

      setState(() => _isLoadingUser = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load your account.')),
      );
    }
  }

  // --- App lifecycle ----------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationCounts();
      _loadFeed();
    }
  }

  // --- Feed ---------------------------------------------------------------

  Future<void> _loadFeed() async {
    try {
      if (mounted) setState(() => _isLoadingFeed = true);

      final data = await FeedService.getFeed();

      if (!mounted) return;

      final currentUserId = _currentUserId ?? context.read<UserProvider>().userId;

      setState(() {
        _feed = data
            .map((e) => Post.fromJson(Map<String, dynamic>.from(e), currentUserId: currentUserId))
            .toList();
        _isLoadingFeed = false;
      });
    } on SessionExpiredException {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(showSessionExpired: true)));
    } catch (e) {
      debugPrint('Failed to load community feed: $e');

      if (!mounted) return;

      setState(() => _isLoadingFeed = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load your community feed.')),
      );
    }
  }

  void _onPostUpdated(Post updated) {
    setState(() {
      final index = _feed.indexWhere((p) => p.id == updated.id);
      if (index != -1) _feed[index] = updated;
    });
  }

  void _onPostDeleted(String postId) {
    setState(() => _feed.removeWhere((p) => p.id == postId));
  }

  // --- Badges ---------------------------------------------------------------

  Future<void> _loadNotificationCounts() async {
    try {
      final results = await Future.wait([
        RequestService.getPendingReceivedCount(),
        MessagingService.getChats(),
      ]);

      final pendingRequests = results[0] as int;
      final chats = results[1] as List<Map<String, dynamic>>;
      final unreadChats = chats.where((chat) => chat['unread'] == true).length;

      if (!mounted) return;

      setState(() {
        _pendingRequestCount = pendingRequests;
        _unreadChatCount = unreadChats;
      });
    } catch (e) {
      debugPrint('Failed to load notification counts: $e');
    }
  }

  // --- Search ---------------------------------------------------------------

  Future<void> _search(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchMode = false;
        _searchError = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _searchMode = true;
      _searchError = null;
    });

    try {
      final rawResults = await SearchService.searchUsersAndCommunities(
        query: trimmed,
        types: const ['user', 'community'],
      );

      if (!mounted) return;

      setState(() {
        _searchResults = rawResults.map((item) => SearchResult.fromJson(Map<String, dynamic>.from(item))).toList();
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Search failed: $e');

      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _searchError = 'Search failed. Please try again.';
      });
    }
  }

  void _onSearchFieldChanged(String value) {
    if (value.trim().isEmpty && _searchMode) {
      setState(() {
        _searchResults = [];
        _searchMode = false;
        _searchError = null;
      });
    }
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchResults = [];
      _searchMode = false;
      _searchError = null;
      _isSearching = false;
    });

    FocusScope.of(context).unfocus();
  }

  // --- Create post ------------------------------------------------------------

  Future<void> _openCreatePost() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));

    if (result == true && mounted) {
      await _loadFeed();
    }
  }

  // --- Inbox / requests -------------------------------------------------------

  Future<void> _openInbox() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityInboxScreen()));
    if (!mounted) return;
    await _loadNotificationCounts();
  }

  Future<void> _openRequests() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestsScreen()));
    if (!mounted) return;
    await _loadNotificationCounts();
  }

  // --- Search result actions --------------------------------------------------

  Future<void> _sendFriendRequest(SearchResult item) async {
    try {
      await FriendService.sendFriendRequest(item.id);

      if (!mounted) return;

      final index = _searchResults.indexOf(item);
      if (index != -1) {
        setState(() => _searchResults[index] = item.copyWith(requestSent: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request sent.')));

      await _loadNotificationCounts();
    } catch (e) {
      debugPrint('Could not send friend request: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send friend request.')),
      );
    }
  }

  Future<void> _requestCommunityJoin(SearchResult item) async {
    try {
      await CommunityService.requestToJoinById(item.id);

      if (!mounted) return;

      final index = _searchResults.indexOf(item);
      if (index != -1) {
        setState(() => _searchResults[index] = item.copyWith(requestSent: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Join request sent.')));

      await _loadNotificationCounts();
    } catch (e) {
      debugPrint('Could not send join request: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send join request.')),
      );
    }
  }

  // --- Direct chat ------------------------------------------------------------

  Future<void> _openDirectChat(String participantId, String name, {String? profilePicture}) async {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.userId ?? _currentUserId;

    if (currentUserId == null || currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not identify your account.')),
      );
      return;
    }

    try {
      final conversation = await MessagingService.getOrCreateDirectChat(participantId);

      if (!mounted) return;

      final conversationId = (conversation['_id'] ?? conversation['id'])?.toString();

      if (conversationId == null || conversationId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open this conversation.')),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            title: name,
            currentUserId: currentUserId,
            profilePicture: profilePicture,
          ),
        ),
      );

      if (!mounted) return;

      await _loadNotificationCounts();
    } catch (e) {
      debugPrint('Could not open chat: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open chat.')));
    }
  }

  // --- Search result details ---------------------------------------------------

  void _showSearchResultDetails(SearchResult item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SearchResultSheet(
          item: item,
          onMessage: item.type == 'user'
              ? () {
            Navigator.pop(sheetContext);
            _openDirectChat(item.id, item.name, profilePicture: item.avatar);
          }
              : null,
          onAdd: item.type == 'user' && !item.isFriend && !item.requestSent
              ? () {
            Navigator.pop(sheetContext);
            _sendFriendRequest(item);
          }
              : null,
          onJoin: item.type == 'community' && !item.isMember && !item.requestSent
              ? () {
            Navigator.pop(sheetContext);
            _requestCommunityJoin(item);
          }
              : null,
        );
      },
    );
  }

  // --- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      bottomNavigationBar: const HomeNav(selectedIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            HomeFeedHeader(
              onCreatePost: _openCreatePost,
              onRequests: _openRequests,
              onMessages: _openInbox,
              pendingRequestCount: _pendingRequestCount,
              unreadChatCount: _unreadChatCount,
            ),
            HomeSearchBar(
              controller: _searchController,
              onSubmitted: _search,
              onChanged: _onSearchFieldChanged,
              onClear: _clearSearch,
            ),
            if (_isSearching) const LinearProgressIndicator(minHeight: 2),
            Expanded(child: _searchMode ? _buildSearchContent() : _buildFeed()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchError != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Search unavailable',
        subtitle: _searchError!,
        actionLabel: 'Try again',
        onAction: () => _search(_searchController.text),
      );
    }

    if (_searchResults.isEmpty) {
      return const EmptyState(icon: Icons.search_off_rounded, title: 'No results', subtitle: 'Try another name or community.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: _searchResults.length,
      itemBuilder: (_, index) {
        final item = _searchResults[index];
        return SearchResultCard(
          item: item,
          onTap: () => _showSearchResultDetails(item),
          onMessage: () => _openDirectChat(item.id, item.name, profilePicture: item.avatar),
          onAdd: () => _sendFriendRequest(item),
          onJoin: () => _requestCommunityJoin(item),
        );
      },
    );
  }

  Widget _buildFeed() {
    if (_isLoadingFeed) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_feed.isEmpty) {
      return const EmptyState(
        icon: Icons.groups_outlined,
        title: 'Your community is quiet',
        subtitle: 'Join communities or add friends to see posts here.',
        topSpacing: 180,
      ).scrollable(onRefresh: _loadFeed);
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _feed.length,
        itemBuilder: (_, index) {
          return CommunityPostCard(
            key: ValueKey(_feed[index].id),
            post: _feed[index],
            onUpdated: _onPostUpdated,
            onDeleted: _onPostDeleted,
          );
        },
      ),
    );
  }
}