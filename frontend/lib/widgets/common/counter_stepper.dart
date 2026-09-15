import 'package:flutter/material.dart';

class CounterStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;

  const CounterStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > min;
    final canIncrement = max == null || value < max!;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.blue),
            onPressed: canDecrement ? () => onChanged(value - 1) : null,
          ),
          Text('$value'),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: canIncrement ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}