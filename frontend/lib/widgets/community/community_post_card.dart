import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/Post.dart';
import '../../providers/user_provider.dart';
import '../../services/api_services.dart';
import '../common/app_avatar.dart';
import 'comment_sheet.dart';

class CommunityPostCard extends StatefulWidget {
  final Post post;
  final ValueChanged<Post>? onUpdated;
  final ValueChanged<String>? onDeleted;

  const CommunityPostCard({
    super.key,
    required this.post,
    this.onUpdated,
    this.onDeleted,
  });

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  late bool isLiked;
  late int likeCount;
  late int commentCount;

  bool _isLiking = false;
  bool _isEditing = false;
  bool _isDeleting = false;
  bool _isInEditMode = false;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncFromPost();
  }

  void _syncFromPost() {
    isLiked = widget.post.liked;
    likeCount = widget.post.likesCount;
    commentCount = widget.post.commentsCount;
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CommunityPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post.id != widget.post.id) {
      _syncFromPost();
      return;
    }

    if (!_isLiking &&
        (oldWidget.post.liked != widget.post.liked ||
            oldWidget.post.likesCount != widget.post.likesCount)) {
      isLiked = widget.post.liked;
      likeCount = widget.post.likesCount;
    }

    if (oldWidget.post.commentsCount != widget.post.commentsCount) {
      commentCount = widget.post.commentsCount;
    }

    if (!_isInEditMode && _editController.text != widget.post.text) {
      _editController.text = widget.post.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            leading: AppAvatar(
              source: widget.post.author?.profilePicture,
              name: widget.post.author?.fullName ?? '',
              radius: 24,
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.post.author?.fullName.trim().isNotEmpty == true
                        ? widget.post.author!.fullName
                        : 'Unknown user',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                if (widget.post.community?.name != null) ...[
                  const SizedBox(width: 7),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      widget.post.community!.name!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: _canModifyPost() && !_isInEditMode
                ? PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              onSelected: _handlePostMenuAction,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            )
                : null,
          ),
          if (widget.post.images.isNotEmpty && widget.post.images.first.trim().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _PostImage(imageUrl: widget.post.images.first.trim()),
            ),
          if (_isInEditMode)
            _buildEditContent()
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.post.text, style: const TextStyle(fontSize: 16, height: 1.4)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: isLiked ? 'Unlike' : 'Like',
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 28,
                    color: isLiked ? Colors.red : Colors.grey.shade600,
                  ),
                  onPressed: _isLiking || _isInEditMode ? null : _toggleLike,
                ),
                if (likeCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('$likeCount',
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                  ),
                IconButton(
                  tooltip: 'Comments',
                  icon: Icon(Icons.comment_outlined, size: 27, color: Colors.grey.shade600),
                  onPressed: _isEditing || _isDeleting || _isInEditMode ? null : _showComments,
                ),
                if (commentCount > 0)
                  Text('$commentCount',
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (widget.post.isEdited && !_isInEditMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('Edited',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500)),
                  ),
                IconButton(
                  tooltip: 'Share',
                  icon: Icon(Icons.share_outlined, color: Colors.grey.shade600),
                  onPressed: _isInEditMode
                      ? null
                      : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share coming soon.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _editController,
            maxLines: 5,
            minLines: 3,
            autofocus: true,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Edit your post...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade300)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _cancelEdit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isEditing ? null : _saveEdit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: _isEditing
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePostMenuAction(String action) async {
    if (action == 'edit') {
      _startEdit();
    } else if (action == 'delete') {
      _deletePost();
    }
  }

  void _startEdit() {
    if (_isEditing) return;
    setState(() {
      _isInEditMode = true;
      _editController.text = widget.post.text;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isInEditMode = false;
      _editController.text = widget.post.text;
    });
  }

  Future<void> _saveEdit() async {
    final newText = _editController.text.trim();

    if (newText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post content cannot be empty.')),
      );
      return;
    }

    if (newText == widget.post.text) {
      setState(() => _isInEditMode = false);
      return;
    }

    setState(() => _isEditing = true);

    try {
      final response = await PostService.update(widget.post.id, newText);

      if (!mounted) return;

      if (response is Map) {
        final updatedData = _unwrapDataMap(response);
        final updatedPost = Post.fromJson(updatedData);
        widget.onUpdated?.call(updatedPost);
      }

      setState(() {
        _isEditing = false;
        _isInEditMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully.'), duration: Duration(seconds: 2)),
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('Could not update post ${widget.post.id}: $e');

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the post.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deletePost() async {
    if (_isDeleting || _isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext, rootNavigator: true).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext, rootNavigator: true).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await PostService.delete(widget.post.id);

      if (!mounted) return;

      widget.onDeleted?.call(widget.post.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted.'), duration: Duration(seconds: 2)),
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('Could not delete post ${widget.post.id}: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete the post.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  bool _canModifyPost() {
    final currentUserId = context.read<UserProvider>().userId;
    return currentUserId != null && widget.post.author?.id == currentUserId;
  }

  Future<void> _toggleLike() async {
    if (_isLiking || _isInEditMode) return;

    final previousLiked = isLiked;
    final previousCount = likeCount;

    setState(() {
      _isLiking = true;
      isLiked = !previousLiked;
      if (isLiked) {
        likeCount++;
      } else if (likeCount > 0) {
        likeCount--;
      }
    });

    try {
      final response = await PostService.like(widget.post.id);

      if (!mounted) return;

      final serverData = _unwrapDataMap(response);

      setState(() {
        final serverLiked = serverData['liked'];
        final serverCount = serverData['likesCount'];
        if (serverLiked is bool) isLiked = serverLiked;
        if (serverCount is num) likeCount = serverCount.toInt();
        _isLiking = false;
      });
    } catch (e) {
      debugPrint('Could not toggle post like: $e');

      if (!mounted) return;

      setState(() {
        isLiked = previousLiked;
        likeCount = previousCount;
        _isLiking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the like.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showComments() async {
    if (_isInEditMode) return;

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      builder: (_) => CommentSheet(postId: widget.post.id),
    );

    if (!mounted || result == null) return;

    setState(() => commentCount = result);
  }

  Map<String, dynamic> _unwrapDataMap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return response;
  }
}

class _PostImage extends StatelessWidget {
  final String imageUrl;

  const _PostImage({required this.imageUrl});

  bool get _isNetworkImage => imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isNetworkImage) {
      return Image.network(
        imageUrl,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    return Image.asset(
      imageUrl,
      height: 260,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 260,
      width: double.infinity,
      color: const Color(0xFFF0F2F5),
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported_outlined, size: 42, color: Colors.grey.shade400),
    );
  }
}