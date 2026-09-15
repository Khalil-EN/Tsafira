import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/Post.dart';
import '../../providers/user_provider.dart';
import '../../widgets/community/community_post_card.dart';
import '../../services/api_services.dart';

class CommunityPostsScreen extends StatefulWidget {
  final String communityId;
  final String communityName;

  const CommunityPostsScreen({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  State<CommunityPostsScreen> createState() =>
      _CommunityPostsScreenState();
}

class _CommunityPostsScreenState
    extends State<CommunityPostsScreen> {
  static const Color _navy = Color(0xFF18335A);
  static const Color _background = Color(0xFFF6F8FB);

  List<Post> _posts = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  int _page = 1;
  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _page = 1;
      _hasMore = true;
    });

    try {
      final currentUserId = context.read<UserProvider>().userId;

      final data = await PostService.getCommunityFeed(
        widget.communityId,
        page: _page,
        limit: _limit,
      );

      if (!mounted) return;

      setState(() {
        _posts = data
            .map(
              (item) => Post.fromJson(
            item,
            currentUserId: currentUserId,
          ),
        )
            .toList();
        _isLoading = false;
        _hasMore = data.length == _limit;
      });
    } catch (e) {
      debugPrint('Failed to load community posts: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load posts for this community.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final currentUserId = context.read<UserProvider>().userId;
      final nextPage = _page + 1;

      final data = await PostService.getCommunityFeed(
        widget.communityId,
        page: nextPage,
        limit: _limit,
      );

      if (!mounted) return;

      setState(() {
        _page = nextPage;
        _posts.addAll(
          data.map(
                (item) => Post.fromJson(
              item,
              currentUserId: currentUserId,
            ),
          ),
        );
        _isLoadingMore = false;
        _hasMore = data.length == _limit;
      });
    } catch (e) {
      debugPrint('Failed to load more community posts: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load more posts.'),
        ),
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

    if (_errorMessage != null && _posts.isEmpty) {
      return _buildErrorState();
    }

    if (_posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFirstPage,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'No posts in this community yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _posts.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return CommunityPostCard(
              key: ValueKey(_posts[index].id),
              post: _posts[index],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 14),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadFirstPage,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}