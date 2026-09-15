import 'package:flutter/material.dart';

class HomeFeedHeader extends StatelessWidget {
  final VoidCallback onCreatePost;
  final VoidCallback onRequests;
  final VoidCallback onMessages;
  final int pendingRequestCount;
  final int unreadChatCount;

  static const _navy = Color(0xFF18335A);
  static const _red = Color(0xFFE53935);

  const HomeFeedHeader({
    super.key,
    required this.onCreatePost,
    required this.onRequests,
    required this.onMessages,
    required this.pendingRequestCount,
    required this.unreadChatCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 6),
      child: Row(
        children: [
          const Expanded(
            child: Text('Community',
                style: TextStyle(color: _navy, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ),
          _HeaderIconButton(icon: Icons.add_box_outlined, tooltip: 'Create post', onPressed: onCreatePost),
          const SizedBox(width: 4),
          _BadgeIconButton(
            icon: Icons.notifications_none_rounded,
            count: pendingRequestCount,
            color: _red,
            tooltip: 'Requests',
            onPressed: onRequests,
          ),
          const SizedBox(width: 4),
          _BadgeIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            count: unreadChatCount,
            color: _red,
            tooltip: 'Messages',
            onPressed: onMessages,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderIconButton({required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 27, color: const Color(0xFF18335A)),
    );
  }
}

class _BadgeIconButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _BadgeIconButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: 27, color: const Color(0xFF18335A)),
        ),
        if (count > 0)
          Positioned(
            right: 1,
            top: 1,
            child: Container(
              constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(count > 99 ? '99+' : '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ),
      ],
    );
  }
}