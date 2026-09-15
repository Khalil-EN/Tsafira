import 'package:flutter/material.dart';
import '../../models/trip_plan_item.dart';
import 'plan_item_card.dart';
import 'empty_plan_state.dart';

class DayContent extends StatelessWidget {
  final List<TripPlanItem> items;
  final int selectedDayIndex;
  final int dayCount;
  final List<String> warnings;
  final void Function(TripPlanItem item) onItemTap;

  const DayContent({
    super.key,
    required this.items,
    required this.selectedDayIndex,
    required this.dayCount,
    required this.warnings,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyPlanState(selectedDayIndex: selectedDayIndex, dayCount: dayCount, warnings: warnings);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(top: 18),
                    decoration: BoxDecoration(color: index == 0 ? Colors.blue : Colors.grey, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + (index % 26)),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (index < items.length - 1)
                    Container(width: 2, height: 250, color: Colors.grey.shade300),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  PlanItemCard(item: item, onTap: () => onItemTap(item)),
                  if (index < items.length - 1 && item.type != 'breakfastUnavailable') _TransportButton(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TransportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      height: 52,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transport selection coming soon.')),
          );
        },
        child: const Center(
          child: Text('Tap Here To Choose Your Transport Method',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
      ),
    );
  }
}