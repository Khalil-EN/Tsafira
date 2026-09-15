import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/common/selectable_list_tile.dart';
import '../../widgets/common/counter_stepper.dart';
import 'travel_dates_screen.dart';

class TravelersSelection extends StatefulWidget {
  const TravelersSelection({Key? key}) : super(key: key);

  @override
  _TravelersSelectionState createState() => _TravelersSelectionState();
}

class _TravelersSelectionState extends State<TravelersSelection> {
  final List<Map<String, dynamic>> travelOptions = [
    {'title': 'Just Me', 'description': 'A sole traveler in exploration', 'image': 'assets/alonee.png', 'people': 1},
    {'title': 'A Couple', 'description': 'Two travelers in tandem', 'image': 'assets/couplee.png', 'people': 2},
    {'title': 'Family', 'description': 'A group of fun loving adventurers', 'image': 'assets/familyy.png', 'people': 0},
    {'title': 'Friends', 'description': 'A bunch of thrill-seekers', 'image': 'assets/friendss.png', 'people': 0},
  ];

  String? selectedOption;
  int peopleCount = 1;
  bool showPeopleSelector = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlanProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
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
                "Who's Traveling",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text('Choose your travelers', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: travelOptions.length,
                  itemBuilder: (context, index) {
                    final option = travelOptions[index];
                    final isSelected = selectedOption == option['title'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SelectableListTile(
                        isSelected: isSelected,
                        title: option['title'],
                        subtitle: option['description'],
                        trailing: Image.asset(option['image'], width: 32, height: 32),
                        onTap: () {
                          setState(() {
                            selectedOption = option['title'];

                            if (option['title'] == 'Family' || option['title'] == 'Friends') {
                              showPeopleSelector = true;
                              peopleCount = 3;
                            } else {
                              showPeopleSelector = false;
                              peopleCount = option['people'];
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              if (showPeopleSelector) ...[
                const Center(
                  child: Text('How many people?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    width: 160,
                    child: CounterStepper(
                      value: peopleCount,
                      min: 2,
                      onChanged: (v) => setState(() => peopleCount = v),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedOption == null
                        ? null
                        : () {
                      provider.setGroupType(selectedOption!);
                      provider.setNbrPeople(peopleCount);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TravelDatesScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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