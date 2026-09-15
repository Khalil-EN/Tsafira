import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../services/api_services.dart';
import '../../utils/safe_dialog.dart';
import '../common/app_avatar.dart';
import '../common/empty_state.dart';

class CommentSheet extends StatefulWidget {
  final String postId;

  const CommentSheet({super.key, required this.postId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();

  late Future<List<Map<String, dynamic>>> _comments;

  bool _isSubmitting = false;
  String? _replyingToId;
  String? _replyingToName;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    _comments = CommentService.getByPost(widget.postId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reloadComments() async {
    final future = CommentService.getByPost(widget.postId);

    setState(() => _comments = future);

    try {
      final comments = await future;
      if (!mounted) return;
      setState(() => _commentCount = comments.length);
    } catch (_) {
      // FutureBuilder displays the error.
    }
  }

  void _startReply(Map<String, dynamic> comment) {
    final id = CommentTileHelpers.readString(comment['id']) ??
        CommentTileHelpers.readString(comment['_id']);

    if (id == null || id.isEmpty) return;

    final name = CommentTileHelpers.extractAuthorName(comment['author']);

    setState(() {
      _replyingToId = id;
      _replyingToName = name.isEmpty ? 'User' : name;
    });

    FocusScope.of(context).unfocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
    });
  }

  Future<void> _toggleCommentLike(String commentId) async {
    try {
      await CommentService.like(commentId);
      await _reloadComments();
    } catch (e) {
      debugPrint('Could not toggle comment like: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the comment like.')),
      );
    }
  }

  Future<void> _updateComment(String commentId, String newText) async {
    try {
      await CommentService.update(commentId, newText);
      if (!mounted) return;
      await _reloadComments();
    } catch (e) {
      debugPrint('Could not update comment: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update comment.')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await CommentService.delete(commentId);

      if (!mounted) return;

      if (_replyingToId == commentId) _cancelReply();

      await _reloadComments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted.')),
      );
    } catch (e) {
      debugPrint('Could not delete comment: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete comment.')),
      );
    }
  }

  Future<void> _submitComment() async {
    if (_isSubmitting) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await CommentService.create(
        postId: widget.postId,
        text: text,
        parentCommentId: _replyingToId,
      );

      if (!mounted) return;

      _controller.clear();

      setState(() {
        _isSubmitting = false;
        _replyingToId = null;
        _replyingToName = null;
      });

      await _reloadComments();
    } catch (e) {
      debugPrint('Could not add comment: $e');

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add comment.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _comments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('Could not load comments.', textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            OutlinedButton(onPressed: _reloadComments, child: const Text('Retry')),
                          ],
                        ),
                      ),
                    );
                  }

                  final comments = snapshot.data ?? [];

                  if (_commentCount != comments.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _commentCount = comments.length);
                    });
                  }

                  if (comments.isEmpty) {
                    return const EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: 'No comments yet',
                      subtitle: 'Be the first to comment.',
                    );
                  }

                  return _CommentList(
                    comments: comments,
                    currentUserId: context.read<UserProvider>().userId,
                    onReply: _startReply,
                    onLike: _toggleCommentLike,
                    onDelete: _deleteComment,
                    onUpdate: _updateComment,
                  );
                },
              ),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          const Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          if (_commentCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_commentCount',
                style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          const Spacer(),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context, _commentCount),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToId != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply_outlined, size: 18, color: Color(0xFF1976D2)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyingToName ?? 'comment'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF18335A), fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cancel reply',
                    onPressed: _cancelReply,
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: _replyingToId != null ? 'Write a reply...' : 'Write a comment...',
                    filled: true,
                    fillColor: const Color(0xFFF4F6F8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFF1976D2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: _replyingToId != null ? 'Send reply' : 'Send comment',
                onPressed: _isSubmitting ? null : _submitComment,
                icon: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: Color(0xFF1976D2)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentList extends StatelessWidget {
  final List<Map<String, dynamic>> comments;
  final String? currentUserId;
  final ValueChanged<Map<String, dynamic>> onReply;
  final Future<void> Function(String) onLike;
  final Future<void> Function(String) onDelete;
  final Future<void> Function(String, String) onUpdate;

  const _CommentList({
    required this.comments,
    required this.currentUserId,
    required this.onReply,
    required this.onLike,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final roots = comments.where((c) => CommentTileHelpers.readParentId(c) == null).toList();

    final repliesByParent = <String, List<Map<String, dynamic>>>{};

    for (final comment in comments) {
      final parentId = CommentTileHelpers.readParentId(comment);
      if (parentId == null || parentId.isEmpty) continue;
      repliesByParent.putIfAbsent(parentId, () => []).add(comment);
    }

    if (roots.isEmpty && comments.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        itemCount: comments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          return _CommentTile(
            comment: comments[index],
            currentUserId: currentUserId,
            isReply: false,
            onReply: onReply,
            onLike: onLike,
            onDelete: onDelete,
            onUpdate: onUpdate,
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: roots.length,
      itemBuilder: (_, index) {
        final root = roots[index];
        final rootId = CommentTileHelpers.readId(root);
        final replies = rootId == null ? <Map<String, dynamic>>[] : repliesByParent[rootId] ?? [];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              _CommentTile(
                comment: root,
                currentUserId: currentUserId,
                isReply: false,
                onReply: onReply,
                onLike: onLike,
                onDelete: onDelete,
                onUpdate: onUpdate,
              ),
              if (replies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 42, top: 8),
                  child: Column(
                    children: [
                      for (final reply in replies)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _CommentTile(
                            comment: reply,
                            currentUserId: currentUserId,
                            isReply: true,
                            onReply: onReply,
                            onLike: onLike,
                            onDelete: onDelete,
                            onUpdate: onUpdate,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class CommentTileHelpers {
  CommentTileHelpers._();

  static String? readId(Map<String, dynamic> comment) {
    return readString(comment['id']) ?? readString(comment['_id']);
  }

  static String? readParentId(Map<String, dynamic> comment) {
    return readString(comment['parentCommentId']) ?? readString(comment['parentComment']);
  }

  static String extractAuthorName(dynamic author) {
    if (author is! Map) return '';

    final fullName = author['fullName']?.toString().trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final firstName = author['firstName']?.toString().trim() ?? '';
    final lastName = author['lastName']?.toString().trim() ?? '';

    return '$firstName $lastName'.trim();
  }

  static String? extractAuthorAvatar(dynamic author) {
    if (author is! Map) return null;
    final avatar = author['profilePicture']?.toString().trim();
    if (avatar == null || avatar.isEmpty) return null;
    return avatar;
  }

  static String? readAuthorId(dynamic author) {
    if (author is! Map) return null;
    return readString(author['id']) ?? readString(author['_id']);
  }

  static int readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? readString(dynamic value) {
    final stringValue = value?.toString().trim();
    if (stringValue == null || stringValue.isEmpty || stringValue == 'null') return null;
    return stringValue;
  }
}

class _CommentTile extends StatefulWidget {
  final Map<String, dynamic> comment;
  final String? currentUserId;
  final bool isReply;
  final ValueChanged<Map<String, dynamic>> onReply;
  final Future<void> Function(String) onLike;
  final Future<void> Function(String) onDelete;
  final Future<void> Function(String, String) onUpdate;

  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.isReply,
    required this.onReply,
    required this.onLike,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _isEditing = false;
  bool _isSaving = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEdit(String currentText) {
    setState(() {
      _controller.text = currentText;
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() => _isEditing = false);
  }

  Future<void> _saveEdit(String commentId, String originalText) async {
    final newText = _controller.text.trim();

    if (newText.isEmpty || newText == originalText) {
      setState(() => _isEditing = false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.onUpdate(commentId, newText);
      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update comment.')),
      );
    }
  }

  Future<void> _confirmDelete(String? commentId) async {
    if (commentId == null || commentId.isEmpty) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete comment?',
      message: 'This comment will be removed.',
      confirmLabel: 'Delete',
    );

    if (confirmed) await widget.onDelete(commentId);
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final author = comment['author'];
    final name = CommentTileHelpers.extractAuthorName(author);
    final avatar = CommentTileHelpers.extractAuthorAvatar(author);

    final text = (comment['text'] ?? comment['content'] ?? '').toString().trim();
    final isEdited = comment['isEdited'] == true;

    final commentId = CommentTileHelpers.readId(comment);
    final likesCount = CommentTileHelpers.readInt(comment['likesCount']);
    final repliesCount = CommentTileHelpers.readInt(comment['repliesCount']);
    final liked = comment['liked'] == true;

    final authorId = CommentTileHelpers.readAuthorId(author);

    final canModify = widget.currentUserId != null && authorId != null && widget.currentUserId == authorId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(source: avatar, name: name.isEmpty ? 'User' : name, radius: widget.isReply ? 18 : 21),
        const SizedBox(width: 11),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(13, 10, 8, 9),
            decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.isEmpty ? 'User' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF18335A)),
                      ),
                    ),
                    if (canModify && !_isEditing)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', height: 44, child: Text('Edit')),
                          PopupMenuItem(value: 'delete', height: 44, child: Text('Delete')),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _startEdit(text);
                          } else if (value == 'delete') {
                            _confirmDelete(commentId);
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                if (_isEditing)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: 4,
                        minLines: 1,
                        autofocus: true,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: _isSaving ? null : _cancelEdit, child: const Text('Cancel')),
                          const SizedBox(width: 4),
                          FilledButton(
                            onPressed: _isSaving || commentId == null ? null : () => _saveEdit(commentId, text),
                            style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14), minimumSize: const Size(0, 34)),
                            child: _isSaving
                                ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  )
                else ...[
                  Text(text, style: const TextStyle(fontSize: 14, height: 1.35)),
                  if (isEdited)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('Edited',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                    ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: commentId == null ? null : () => widget.onLike(commentId),
                        style: TextButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
                            size: 16, color: liked ? const Color(0xFFE53935) : Colors.grey.shade600),
                        label: Text(likesCount > 0 ? '$likesCount' : 'Like',
                            style: TextStyle(
                                fontSize: 12,
                                color: liked ? const Color(0xFFE53935) : Colors.grey.shade700,
                                fontWeight: FontWeight.w600)),
                      ),
                      if (!widget.isReply)
                        TextButton.icon(
                          onPressed: () => widget.onReply(comment),
                          style: TextButton.styleFrom(
                              minimumSize: const Size(0, 30),
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          icon: const Icon(Icons.reply_outlined, size: 16),
                          label: const Text('Reply', style: TextStyle(fontSize: 12)),
                        ),
                      if (repliesCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('$repliesCount ${repliesCount == 1 ? 'reply' : 'replies'}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}