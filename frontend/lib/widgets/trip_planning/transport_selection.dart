import 'package:flutter/material.dart';

Widget buildTransportTimelineItem(
    BuildContext context,
    int transportIndex,
    String transport,
    int dayIndex,
    void Function(int, int, String) updateTransport,
    ) {
  IconData transportIcon;
  String transportText = transport;

  if (transport.isEmpty) {
    transportIcon = Icons.directions;
    transportText = "Select Transport";
  } else {
    switch (transport) {
      case "Car":
        transportIcon = Icons.directions_car;
        break;
      case "Bus":
        transportIcon = Icons.directions_bus;
        break;
      case "Taxi":
        transportIcon = Icons.local_taxi;
        break;
      case "By Legs":
        transportIcon = Icons.directions_walk;
        break;
      default:
        transportIcon = Icons.directions;
    }
  }

  return GestureDetector(
    onTap: () => showTransportChoices(context, dayIndex, transportIndex, updateTransport),
    child: Row(
      children: [
        SizedBox(
          width: 20,
          child: Center(child: Container(width: 2, height: 60, color: Colors.grey.shade300)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: transport.isEmpty ? Colors.grey.shade50 : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: transport.isEmpty ? Colors.grey.shade300 : Colors.blue.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(transportIcon, size: 18, color: transport.isEmpty ? Colors.grey.shade400 : Colors.blue),
                const SizedBox(width: 6),
                Text(transportText, style: TextStyle(color: transport.isEmpty ? Colors.grey.shade500 : Colors.blue, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

void showTransportChoices(
    BuildContext context,
    int dayIndex,
    int transportIndex,
    void Function(int, int, String) updateTransport,
    ) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Choose Your Transport", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ],
            ),
          ),
          TransportOption(
            icon: 'assets/carr.png', name: 'Car', distance: '12Km', duration: '20min', price: '\$20', people: 4, isSelected: true,
            onTap: () { updateTransport(dayIndex, transportIndex, "Car"); Navigator.pop(context); },
          ),
          TransportOption(
            icon: 'assets/buss.png', name: 'Bus', distance: '12Km', duration: '25min', price: '\$5', people: 10,
            onTap: () { updateTransport(dayIndex, transportIndex, "Bus"); Navigator.pop(context); },
          ),
          TransportOption(
            icon: 'assets/taxi.png', name: 'Tuk', distance: '12Km', duration: '28min', price: '\$15', people: 3,
            onTap: () { updateTransport(dayIndex, transportIndex, "Taxi"); Navigator.pop(context); },
          ),
          TransportOption(
            icon: 'assets/walk.png', name: 'By Legs', distance: '12Km', duration: '60min', price: null, people: 1,
            onTap: () { updateTransport(dayIndex, transportIndex, "By Legs"); Navigator.pop(context); },
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

class TransportOption extends StatelessWidget {
  final String icon;
  final String name;
  final String distance;
  final String duration;
  final String? price;
  final int people;
  final bool isSelected;
  final VoidCallback onTap;

  const TransportOption({
    super.key,
    required this.icon,
    required this.name,
    required this.distance,
    required this.duration,
    this.price,
    required this.people,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 40, height: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(duration, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.straighten, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(distance, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text("$people", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            price != null
                ? Text(price!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                : Text("Free", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade600)),
          ],
        ),
      ),
    );
  }
}