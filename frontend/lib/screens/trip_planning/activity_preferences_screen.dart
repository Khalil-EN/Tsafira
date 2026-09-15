import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/common/selectable_list_tile.dart';
import 'hotel_preferences_screen.dart';

class ActivityPreferences extends StatefulWidget {
  const ActivityPreferences({Key? key}) : super(key: key);

  @override
  _ActivityPreferencesState createState() => _ActivityPreferencesState();
}

class _ActivityPreferencesState extends State<ActivityPreferences> {
  final List<String> activities = [
    'Museums',
    'Mountains',
    'Beach',
    'Gardens',
    'Cultural Attractions',
    'Entertainment Activities',
  ];

  final Set<String> selectedActivities = {};

  IconData _getIconForActivity(String activity) {
    switch (activity) {
      case 'Museums':
        return Icons.museum;
      case 'Mountains':
        return Icons.landscape;
      case 'Beach':
        return Icons.beach_access;
      case 'Gardens':
        return Icons.nature;
      case 'Cultural Attractions':
        return Icons.theater_comedy;
      case 'Entertainment Activities':
        return Icons.celebration;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlanProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select your activity preferences',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFFFA000), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select the activities you are interested in. This will help us customize your trip itinerary.',
                        style: TextStyle(color: Color(0xFF795548), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    final isSelected = selectedActivities.contains(activity);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SelectableListTile(
                        isSelected: isSelected,
                        title: activity,
                        leading: Icon(_getIconForActivity(activity)),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedActivities.remove(activity);
                            } else {
                              selectedActivities.add(activity);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.setSelectedActivities(selectedActivities);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HotelPreferences()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "NEXT",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}