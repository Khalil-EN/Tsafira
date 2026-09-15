import 'package:flutter/material.dart';

class FilterChipSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const FilterChipSection({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);

            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (value) {
                final next = List<String>.from(selected);
                if (value) {
                  next.add(option);
                } else {
                  next.remove(option);
                }
                onChanged(next);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}