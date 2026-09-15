import 'package:flutter/material.dart';

class EmptyPlanState extends StatelessWidget {
  final int selectedDayIndex;
  final int dayCount;
  final List<String> warnings;

  const EmptyPlanState({
    super.key,
    required this.selectedDayIndex,
    required this.dayCount,
    required this.warnings,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String description;
    IconData icon;

    if (selectedDayIndex == 0) {
      title = 'No accommodation found';
      description = warnings.any((w) => w.toLowerCase().contains('residence') || w.toLowerCase().contains('accommodation'))
          ? 'No suitable accommodation could be selected for this plan.'
          : 'There is no accommodation available for this suggested plan.';
      icon = Icons.hotel_outlined;
    } else if (selectedDayIndex == dayCount + 1) {
      title = 'No night activities found';
      description = 'There are no suggested night activities for this plan.';
      icon = Icons.nightlife_outlined;
    } else {
      title = 'No suggestions for Day $selectedDayIndex';
      description = 'There are no suggested places for this day.';
      icon = Icons.event_note_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}