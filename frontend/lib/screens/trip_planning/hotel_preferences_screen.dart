import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/common/selectable_list_tile.dart';
import '../../widgets/common/selectable_icon_option.dart';
import 'restaurant_preferences_screen.dart';

class HotelPreferences extends StatefulWidget {
  const HotelPreferences({Key? key}) : super(key: key);

  @override
  _HotelPreferencesState createState() => _HotelPreferencesState();
}

class _HotelPreferencesState extends State<HotelPreferences> {
  String? selectedAccommodationType;

  final List<String> accommodationTypes = ['Hotel', 'Logement'];

  final List<String> locationOptions = [
    'City Center',
    'Near the Beach',
    'Calm/Quiet Area',
    'Rural Area',
  ];

  final Set<String> selectedLocations = {};

  IconData _getIconForLocation(String location) {
    switch (location) {
      case 'City Center':
        return Icons.location_city;
      case 'Near the Beach':
        return Icons.beach_access;
      case 'Calm/Quiet Area':
        return Icons.nights_stay;
      case 'Rural Area':
        return Icons.nature_people;
      default:
        return Icons.place;
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
                'Accommodation Preferences',
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
                        'First, select your accommodation type, then choose your preferred locations.',
                        style: TextStyle(color: Color(0xFF795548), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Accommodation Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A55A2)),
              ),
              const SizedBox(height: 10),
              Row(
                children: accommodationTypes.map((type) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SelectableIconOption(
                        isSelected: selectedAccommodationType == type,
                        icon: type == 'Hotel' ? Icons.hotel : Icons.home,
                        label: type,
                        onTap: () => setState(() => selectedAccommodationType = type),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Location Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A55A2)),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: locationOptions.length,
                  itemBuilder: (context, index) {
                    final location = locationOptions[index];
                    final isSelected = selectedLocations.contains(location);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SelectableListTile(
                        isSelected: isSelected,
                        title: location,
                        leading: Icon(_getIconForLocation(location)),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedLocations.remove(location);
                            } else {
                              selectedLocations.add(location);
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
                    onPressed: selectedAccommodationType != null && selectedLocations.isNotEmpty
                        ? () {
                      // Fixed: these are regular methods, not nullable
                      // function-typed fields — the `!` null-assertion
                      // was meaningless here and has been removed.
                      provider.setAccomodationType(selectedAccommodationType!);
                      provider.setSelectedHotelLocations(selectedLocations);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RestaurantPreferences()),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      disabledBackgroundColor: const Color(0xFFD1CFFF),
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