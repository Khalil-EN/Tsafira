import 'package:flutter/material.dart';

class AttractionTimelineItem extends StatelessWidget {
  final String attraction;
  final bool isLast;

  const AttractionTimelineItem({super.key, required this.attraction, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1))],
              ),
              child: const Center(child: Icon(Icons.place, color: Colors.white, size: 10)),
            ),
            if (!isLast) Container(width: 2, height: 80, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Text(attraction, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}