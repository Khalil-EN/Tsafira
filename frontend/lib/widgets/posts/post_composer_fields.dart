import 'package:flutter/material.dart';
import '../common/app_avatar.dart';

class AuthorHeader extends StatelessWidget {
  final String name;
  final String? avatar;
  final String visibility;
  final VoidCallback onVisibilityTap;

  const AuthorHeader({
    super.key,
    required this.name,
    required this.avatar,
    required this.visibility,
    required this.onVisibilityTap,
  });

  IconData _visibilityIcon(String value) {
    switch (value) {
      case 'friends':
        return Icons.people_outline;
      case 'private':
        return Icons.lock_outline;
      case 'community':
      default:
        return Icons.public;
    }
  }

  String _visibilityLabel(String value) {
    switch (value) {
      case 'friends':
        return 'Friends';
      case 'private':
        return 'Only me';
      case 'community':
      default:
        return 'Community';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(source: avatar, name: name, radius: 25),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: onVisibilityTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_visibilityIcon(visibility), size: 15),
                    const SizedBox(width: 5),
                    Text(_visibilityLabel(visibility),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down, size: 17),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TextComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int characterCount;
  final int maxCharacters;

  const TextComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.characterCount,
    required this.maxCharacters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          minLines: 7,
          maxLines: 12,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: "What's happening?",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 21, fontWeight: FontWeight.w500),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 20, height: 1.45, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 6),
        Text(
          '$characterCount / $maxCharacters',
          style: TextStyle(
            fontSize: 12,
            color: characterCount >= maxCharacters ? Colors.red : Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ImagePreviewGrid extends StatelessWidget {
  final List<String> images;
  final void Function(int index) onRemove;

  const ImagePreviewGrid({super.key, required this.images, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      return _SingleImagePreview(imagePath: images.first, onRemove: () => onRemove(0));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(14), child: _ImageWidget(path: images[index])),
            Positioned(top: 8, right: 8, child: _RemoveImageButton(onPressed: () => onRemove(index))),
          ],
        );
      },
    );
  }
}

class _SingleImagePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const _SingleImagePreview({required this.imagePath, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: _ImageWidget(path: imagePath)),
          Positioned(top: 10, right: 10, child: _RemoveImageButton(onPressed: onRemove)),
        ],
      ),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  final String path;

  const _ImageWidget({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Color(0xFFEAEAEA),
          child: Icon(Icons.broken_image_outlined, size: 36),
        ),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: Color(0xFFEAEAEA),
        child: Icon(Icons.image_outlined, size: 36),
      ),
    );
  }
}

class _RemoveImageButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RemoveImageButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: Icon(Icons.close, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class AttachmentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AttachmentCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F7F8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedOptionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  const SelectedOptionChip({super.key, required this.icon, required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: const Color(0xFFF3F1FF), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 7),
          Flexible(
            child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 5),
          GestureDetector(onTap: onRemove, child: const Icon(Icons.close, size: 17)),
        ],
      ),
    );
  }
}

class BottomActionBar extends StatelessWidget {
  final VoidCallback onAddAttachment;
  final bool enabled;

  const BottomActionBar({super.key, required this.onAddAttachment, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _ToolbarButton(
                  icon: Icons.photo_library_outlined,
                  onPressed: enabled
                      ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo picker will be connected next.')),
                    );
                  }
                      : null,
                ),
                _ToolbarButton(icon: Icons.emoji_emotions_outlined, onPressed: enabled ? onAddAttachment : null),
                _ToolbarButton(icon: Icons.location_on_outlined, onPressed: enabled ? onAddAttachment : null),
                _ToolbarButton(icon: Icons.more_horiz, onPressed: enabled ? onAddAttachment : null),
              ],
            ),
          ),
          Text('Ready to share', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _ToolbarButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: Icon(icon), color: Colors.black87, tooltip: 'Add');
  }
}

class PublishButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  const PublishButton({super.key, required this.enabled, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: loading
          ? const SizedBox(height: 17, width: 17, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Post', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: Colors.red.shade800, fontSize: 13))),
        ],
      ),
    );
  }
}