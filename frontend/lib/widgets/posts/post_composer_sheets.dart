import 'package:flutter/material.dart';

enum PostAttachmentAction { photo, feeling, location, community }

class SheetContainer extends StatelessWidget {
  final Widget child;

  const SheetContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: SafeArea(top: false, child: child),
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
    );
  }
}

class SheetActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SheetActionTile({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class AttachmentSheet extends StatelessWidget {
  const AttachmentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          const SizedBox(height: 12),
          const Text('Add to your post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          SheetActionTile(
            icon: Icons.photo_library_outlined,
            title: 'Photos',
            onTap: () => Navigator.of(context).pop(PostAttachmentAction.photo),
          ),
          SheetActionTile(
            icon: Icons.emoji_emotions_outlined,
            title: 'Feeling',
            onTap: () => Navigator.of(context).pop(PostAttachmentAction.feeling),
          ),
          SheetActionTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            onTap: () => Navigator.of(context).pop(PostAttachmentAction.location),
          ),
          SheetActionTile(
            icon: Icons.groups_outlined,
            title: 'Community',
            onTap: () => Navigator.of(context).pop(PostAttachmentAction.community),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class VisibilitySheet extends StatelessWidget {
  final String selectedVisibility;

  const VisibilitySheet({super.key, required this.selectedVisibility});

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          const SizedBox(height: 12),
          const Text('Who can see your post?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          _VisibilityOption(
            icon: Icons.public,
            title: 'Community',
            subtitle: 'Share with the community',
            value: 'community',
            selected: selectedVisibility == 'community',
          ),
          _VisibilityOption(
            icon: Icons.people_outline,
            title: 'Friends',
            subtitle: 'Only your friends can see it',
            value: 'friends',
            selected: selectedVisibility == 'friends',
          ),
          _VisibilityOption(
            icon: Icons.lock_outline,
            title: 'Only me',
            subtitle: 'Keep this post private',
            value: 'private',
            selected: selectedVisibility == 'private',
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final bool selected;

  const _VisibilityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: selected ? const Icon(Icons.check_circle) : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}

class FeelingSheet extends StatelessWidget {
  const FeelingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const feelings = [
      '😊 Feeling happy',
      '😍 Feeling excited',
      '😎 Feeling adventurous',
      '🥰 Feeling grateful',
      '🤩 Feeling inspired',
      '🌍 Feeling adventurous',
    ];

    return SheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          const SizedBox(height: 12),
          const Text('How are you feeling?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...feelings.map((feeling) => ListTile(title: Text(feeling), onTap: () => Navigator.of(context).pop(feeling))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}