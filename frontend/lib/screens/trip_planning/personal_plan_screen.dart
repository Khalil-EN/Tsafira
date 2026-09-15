import 'package:flutter/material.dart';
import '../../models/trip_day.dart';
import '../../services/api_services.dart';
import '../../widgets/trip_planning/selection_list_screen.dart';
import '../../widgets/trip_planning/transport_selection.dart';
import '../../widgets/trip_planning/attraction_timeline_item.dart';

class PersonalPlanning extends StatefulWidget {
  final String tripName;

  const PersonalPlanning({super.key, this.tripName = "Beach Trip"});

  @override
  _PersonalPlanningState createState() => _PersonalPlanningState();
}

class _PersonalPlanningState extends State<PersonalPlanning> {
  List<TripDay> tripDays = [TripDay(day: 1, date: DateTime.now())];
  int selectedDayIndex = 0;

  void addNewDay() {
    setState(() {
      tripDays.add(TripDay(day: tripDays.length + 1, date: tripDays.last.date.add(const Duration(days: 1))));
    });
  }

  void addAttraction(int dayIndex, String attractionName) {
    setState(() {
      final day = tripDays[dayIndex];
      day.attractions.add(attractionName);
      if (day.attractions.length > 1 && day.transports.length < day.attractions.length - 1) {
        day.transports.add("");
      }
    });
  }

  void addCustomAttraction(int dayIndex, String attractionName) {
    if (attractionName.isNotEmpty) addAttraction(dayIndex, attractionName);
  }

  void updateTransport(int dayIndex, int transportIndex, String newTransport) {
    setState(() => tripDays[dayIndex].transports[transportIndex] = newTransport);
  }

  void showAttractionChoices(int dayIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Attraction Type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green),
              title: const Text("Add New Attraction"),
              onTap: () {
                Navigator.pop(context);
                showCustomAttractionDialog(dayIndex);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant, color: Colors.blue),
              title: const Text("Restaurant"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => SelectionListScreen(
                  title: 'Select Restaurant',
                  icon: Icons.restaurant,
                  fetcher: RestaurantService.getAll,
                  onSelect: (selected) => addAttraction(dayIndex, selected),
                )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.hotel, color: Colors.blue),
              title: const Text("Hotel"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => SelectionListScreen(
                  title: 'Select Hotel',
                  icon: Icons.hotel,
                  fetcher: ResidenceService.getAll,
                  onSelect: (selected) => addAttraction(dayIndex, selected),
                )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_activity, color: Colors.blue),
              title: const Text("Activity"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => SelectionListScreen(
                  title: 'Select Activity',
                  icon: Icons.local_activity,
                  fetcher: ActivityService.getAll,
                  onSelect: (selected) => addAttraction(dayIndex, selected),
                )));
              },
            ),
          ],
        ),
      ),
    );
  }

  void showCustomAttractionDialog(int dayIndex) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Attraction"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter attraction name", border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              addCustomAttraction(dayIndex, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = tripDays[selectedDayIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Column(
          children: [
            const Text('Trip Details Plan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.tripName, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tripDays.length + 1,
              itemBuilder: (context, index) {
                if (index < tripDays.length) {
                  final day = tripDays[index];
                  return GestureDetector(
                    onTap: () => setState(() => selectedDayIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: selectedDayIndex == index ? Colors.blue.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selectedDayIndex == index ? Colors.blue : Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text('Day ${day.day}',
                            style: TextStyle(
                                color: selectedDayIndex == index ? Colors.blue : Colors.black,
                                fontWeight: selectedDayIndex == index ? FontWeight.bold : FontWeight.normal)),
                      ),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: addNewDay,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                    child: const Center(child: Icon(Icons.add, color: Colors.blue, size: 20)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentDay.formattedDate, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ElevatedButton.icon(
                  onPressed: () => showAttractionChoices(selectedDayIndex),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Attraction"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), textStyle: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          Expanded(
            child: currentDay.attractions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No attractions added yet', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => showAttractionChoices(selectedDayIndex),
                    icon: const Icon(Icons.add),
                    label: const Text("Add First Attraction"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: currentDay.attractions.length * 2 - 1,
              itemBuilder: (context, index) {
                if (index % 2 == 0) {
                  final attractionIndex = index ~/ 2;
                  return AttractionTimelineItem(
                    attraction: currentDay.attractions[attractionIndex],
                    isLast: attractionIndex == currentDay.attractions.length - 1,
                  );
                }
                final transportIndex = index ~/ 2;
                final transport = transportIndex < currentDay.transports.length ? currentDay.transports[transportIndex] : "";
                return buildTransportTimelineItem(context, transportIndex, transport, selectedDayIndex, updateTransport);
              },
            ),
          ),
        ],
      ),
    );
  }
}