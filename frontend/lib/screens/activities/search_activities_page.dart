// lib/screens/activities/search_activities_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/common/labeled_field_box.dart';
import '../../widgets/common/counter_stepper.dart';
import 'activities_page.dart';

class SearchActivitiesPage extends StatefulWidget {
  const SearchActivitiesPage({super.key});

  @override
  State<SearchActivitiesPage> createState() => _SearchActivitiesPageState();
}

class _SearchActivitiesPageState extends State<SearchActivitiesPage> {
  final TextEditingController _locationController =
  TextEditingController(text: 'Tetuan, Morocco');

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  int _participantCount = 2;
  bool _onlyFree = false;

  static const List<String> _activityTypes = [
    'Outdoor', 'Cultural', 'Sports', 'Educational',
    'Art', 'Music', 'Adventure', 'Family-Friendly',
    'Fitness', 'Workshop', 'Beach', 'Museums',
  ];

  static const List<String> _ageGroups = [
    'Kids', 'Teenagers', 'Adults', 'Seniors', 'All Ages',
  ];

  static const List<String> _specialRequirements = [
    'Wheelchair Accessible', 'Pet-Friendly', 'Beginner-Friendly',
    'No Experience Needed', 'Indoor', 'Outdoor',
  ];

  final Set<String> _selectedActivityTypes = {};
  final Set<String> _selectedAgeGroups = {};
  final Set<String> _selectedSpecialRequirements = {};

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  Widget _buildFilterChips(
      String title,
      List<String> options,
      Set<String> selectedSet,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedSet.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedSet.add(option);
                  } else {
                    selectedSet.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _searchActivities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitiesPage(
          isFromSearch: true,
          location: _locationController.text.trim(),
          date: _selectedDate,
          time: _selectedTime,
          participants: _participantCount,
          freeOnly: _onlyFree,
          activityTypes: _selectedActivityTypes.toList(),
          ageGroups: _selectedAgeGroups.toList(),
          specialRequirements: _selectedSpecialRequirements.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Search Activities', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            LabeledFieldBox(
              label: 'Location',
              icon: Icons.location_on,
              controller: _locationController,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: LabeledFieldBox(
                    label: 'Date',
                    icon: Icons.calendar_today,
                    displayValue: DateFormat('dd MMM').format(_selectedDate),
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LabeledFieldBox(
                    label: 'Time',
                    icon: Icons.access_time,
                    displayValue: _selectedTime.format(context),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Participants', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CounterStepper(
              value: _participantCount,
              min: 1,
              onChanged: (value) => setState(() => _participantCount = value),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Free Activities Only'),
              value: _onlyFree,
              onChanged: (value) => setState(() => _onlyFree = value),
            ),
            const SizedBox(height: 20),
            _buildFilterChips('Activity Types', _activityTypes, _selectedActivityTypes),
            const SizedBox(height: 20),
            _buildFilterChips('Age Groups', _ageGroups, _selectedAgeGroups),
            const SizedBox(height: 20),
            _buildFilterChips('Special Requirements', _specialRequirements, _selectedSpecialRequirements),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchActivities,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Search Activities',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}