import 'package:flutter/material.dart';
import '../../models/SocialSearchResult.dart';
import '../common/app_avatar.dart';

class SearchResultSheet extends StatelessWidget {
  final SearchResult item;
  final VoidCallback? onMessage;
  final VoidCallback? onAdd;
  final VoidCallback? onJoin;

  const SearchResultSheet({super.key, required this.item, this.onMessage, this.onAdd, this.onJoin});

  @override
  Widget build(BuildContext context) {
    final isUser = item.type == 'user';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 22),
            AppAvatar(source: item.avatar, name: item.name, radius: 40, isCommunity: !isUser),
            const SizedBox(height: 12),
            Text(item.name, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF18335A), fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(isUser ? 'User' : 'Community', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 22),
            if (isUser) ...[
              if (item.isFriend && onMessage != null)
                _SheetAction(icon: Icons.chat_bubble_outline, label: 'Send a message', onPressed: onMessage!),
              if (!item.isFriend && !item.requestSent && onAdd != null)
                _SheetAction(icon: Icons.person_add_alt_1, label: 'Add as friend', onPressed: onAdd!),
              if (item.requestSent)
                const _SheetInfo(icon: Icons.schedule, text: 'Friend request pending'),
            ],
            if (!isUser) ...[
              if (item.isMember)
                const _SheetInfo(icon: Icons.check_circle_outline, text: 'You are already a member'),
              if (!item.isMember && item.requestSent)
                const _SheetInfo(icon: Icons.schedule, text: 'Join request pending'),
              if (!item.isMember && !item.requestSent && onJoin != null)
                _SheetAction(icon: Icons.group_add_outlined, label: 'Request to join', onPressed: onJoin!),
            ],
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SheetAction({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _SheetInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SheetInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}