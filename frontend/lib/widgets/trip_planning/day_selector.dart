import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final List<DateTime> days;
  final int selectedDayIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddDay;

  const DaySelector({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.onSelect,
    required this.onAddDay,
  });

  String _getTitleName(int index) {
    if (index == 0) return 'Residency';
    if (index >= 1 && index <= days.length) return 'Day $index';
    if (index == days.length + 1) return 'Night activities';
    return '';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color.fromARGB(255, 53, 177, 255), width: 2)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length + 3,
        itemBuilder: (context, index) {
          if (index == days.length + 2) {
            return Center(
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color.fromARGB(255, 24, 189, 255), size: 30),
                onPressed: onAddDay,
              ),
            );
          }

          final isSelected = index == selectedDayIndex;
          final isDay = index >= 1 && index <= days.length;
          final day = isDay ? days[index - 1] : null;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              constraints: const BoxConstraints(minWidth: 105),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: isSelected
                    ? const Border(bottom: BorderSide(color: Color.fromARGB(255, 9, 210, 255), width: 4))
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_getTitleName(index), textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  if (day != null) ...[
                    const SizedBox(height: 2),
                    Text('${day.day} ${_getMonthName(day.month)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}