import 'package:flutter/material.dart';
import '../common/sheet_scaffold.dart';

class WarningsSheet extends StatelessWidget {
  final List<String> warnings;

  const WarningsSheet({super.key, required this.warnings});

  static Future<void> show(BuildContext context, List<String> warnings) {
    if (warnings.isEmpty) return Future.value();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WarningsSheet(warnings: warnings),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      heightFactor: 0.72,
      title: 'Plan warnings (${warnings.length})',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange.shade800,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: warnings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.orange.shade800),
                const SizedBox(width: 10),
                Expanded(child: Text(warnings[index], style: TextStyle(color: Colors.orange.shade900, height: 1.35))),
              ],
            ),
          );
        },
      ),
    );
  }
}