import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'restaurants_page.dart';
import '../../widgets/common/counter_stepper.dart';
import '../../widgets/common/labeled_field_box.dart';

class SearchRestaurant extends StatefulWidget {
  const SearchRestaurant({super.key});

  @override
  State<SearchRestaurant> createState() => _SearchRestaurantState();
}

class _SearchRestaurantState extends State<SearchRestaurant> {
  late final TextEditingController _locationController;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _guestCount = 2;
  RangeValues _priceRange = const RangeValues(10, 100);

  static const List<String> _cuisineTypes = [
    'Italian',
    'Mexican',
    'Chinese',
    'Indian',
    'Seafood',
    'Vegetarian',
    'BBQ',
    'Fast-Food',
  ];

  static const List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Halal',
    'Kosher',
  ];

  static const List<String> _specialFeatures = [
    'Outdoor Seating',
    'Live Music',
    'Family-Friendly',
    'Romantic',
    'Wi-Fi',
    'Takeout',
    'Delivery',
  ];

  final List<String> _selectedCuisines = [];
  final List<String> _selectedDietaryOptions = [];
  final List<String> _selectedSpecialFeatures = [];

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: 'Tetuan, Morocco');
    _minPriceController = TextEditingController(text: '${_priceRange.start.round()}');
    _maxPriceController = TextEditingController(text: '${_priceRange.end.round()}');
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Widget _buildFilterChips(
      String title,
      List<String> options,
      List<String> selected,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
              onSelected: (bool selectedValue) {
                setState(() {
                  if (selectedValue) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) {
                  final newMin = double.tryParse(value) ?? 0;
                  if (newMin <= _priceRange.end) {
                    setState(() {
                      _priceRange = RangeValues(newMin.clamp(0, 200), _priceRange.end);
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: RangeSlider(
                values: _priceRange,
                min: 0,
                max: 200,
                divisions: 20,
                activeColor: Colors.blue,
                inactiveColor: Colors.blue.shade100,
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                    _minPriceController.text = values.start.round().toString();
                    _maxPriceController.text = values.end.round().toString();
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) {
                  final newMax = double.tryParse(value) ?? 200;
                  if (newMax >= _priceRange.start) {
                    setState(() {
                      _priceRange = RangeValues(_priceRange.start, newMax.clamp(0, 200));
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _searchRestaurants() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantsPage(
          isFromSearch: true,
          location: _locationController.text.trim(),
          date: _selectedDate,
          time: _selectedTime,
          nbrGuests: _guestCount,
          minPrice: _priceRange.start,
          maxPrice: _priceRange.end,
          cuisines: _selectedCuisines,
          dietaryOptions: _selectedDietaryOptions,
          specialFeatures: _selectedSpecialFeatures,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Restaurant',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    displayValue: DateFormat('dd MMM yyyy').format(_selectedDate),
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
            const Text('Guests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            CounterStepper(
              value: _guestCount,
              min: 1,
              onChanged: (value) => setState(() => _guestCount = value),
            ),
            const SizedBox(height: 20),
            _buildPriceRange(),
            const SizedBox(height: 20),
            _buildFilterChips('Cuisine Types', _cuisineTypes, _selectedCuisines),
            const SizedBox(height: 20),
            _buildFilterChips('Dietary Options', _dietaryOptions, _selectedDietaryOptions),
            const SizedBox(height: 20),
            _buildFilterChips('Special Features', _specialFeatures, _selectedSpecialFeatures),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchRestaurants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Search Restaurants',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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