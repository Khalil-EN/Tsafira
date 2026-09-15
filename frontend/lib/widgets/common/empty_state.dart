import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double topSpacing;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.topSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topSpacing > 0) SizedBox(height: topSpacing),
            Icon(icon, size: 62, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF18335A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 7),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Wrap in a scrollable list so pull-to-refresh keeps working even
  /// when the content itself doesn't fill/overflow the screen.
  Widget scrollable({Future<void> Function()? onRefresh}) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [this],
    );

    if (onRefresh == null) return list;

    return RefreshIndicator(onRefresh: onRefresh, child: list);
  }
}