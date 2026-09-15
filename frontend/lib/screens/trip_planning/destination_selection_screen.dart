import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/common/selectable_list_tile.dart';
import 'travelers_selection_screen.dart';

class DestinationSelectionScreen extends StatefulWidget {
  const DestinationSelectionScreen({Key? key}) : super(key: key);

  @override
  _DestinationSelectionScreenState createState() => _DestinationSelectionScreenState();
}

class _DestinationSelectionScreenState extends State<DestinationSelectionScreen> {
  final List<String> cities = ['Tanger', 'Rabat', 'Marrakech', 'Agadir', 'Essaouira', 'Chefchaouen'];
  final Set<String> selectedCities = {};

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
                'Select your preferred destination(s)',
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
                        'Currently, trip planning is only available for Rabat. More cities will be added in future updates.',
                        style: TextStyle(color: Color(0xFF795548), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final isSelected = selectedCities.contains(city);
                    final isRabat = city == 'Rabat';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SelectableListTile(
                        isSelected: isSelected,
                        title: city,
                        badge: isRabat
                            ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.3)
                                : const Color(0xFF6C63FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : const Color(0xFF6C63FF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                            : null,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedCities.remove(city);
                            } else {
                              selectedCities.add(city);
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
                      provider.setSelectedCities(selectedCities);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TravelersSelection()),
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