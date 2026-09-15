import 'package:flutter/material.dart';
import '../../models/SocialSearchResult.dart';
import '../common/app_avatar.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult item;
  final VoidCallback onTap;
  final VoidCallback onMessage;
  final VoidCallback onAdd;
  final VoidCallback onJoin;

  static const _navy = Color(0xFF18335A);

  const SearchResultCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onMessage,
    required this.onAdd,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = item.type == 'user';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.requestSent ? Colors.orange.shade100 : Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AppAvatar(source: item.avatar, name: item.name, radius: 25, isCommunity: !isUser),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(isUser ? Icons.person_outline : Icons.groups_outlined,
                            size: 15, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Text(isUser ? 'User' : 'Community',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _actionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton() {
    if (item.type == 'user') {
      if (item.isFriend) {
        return _SmallActionButton(icon: Icons.chat_bubble_outline, label: 'Message', onPressed: onMessage);
      }
      if (item.requestSent) {
        return const _StatusChip(label: 'Pending', color: Colors.orange);
      }
      return _SmallActionButton(icon: Icons.person_add_alt_1, label: 'Add', onPressed: onAdd);
    }

    if (item.isMember) {
      return const _StatusChip(label: 'Member', color: Colors.green);
    }
    if (item.requestSent) {
      return const _StatusChip(label: 'Pending', color: Colors.orange);
    }
    return _SmallActionButton(icon: Icons.group_add_outlined, label: 'Join', onPressed: onJoin);
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SmallActionButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, 38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(14)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}