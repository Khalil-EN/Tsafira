// lib/widgets/country_picker_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:table_calendar_example/models/country_code.dart';

class CountryPickerBottomSheet extends StatefulWidget {
  final CountryCode selectedCountry;

  const CountryPickerBottomSheet({
    super.key,
    required this.selectedCountry,
  });

  @override
  State<CountryPickerBottomSheet> createState() => _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryCode> _filteredCountries = List<CountryCode>.from(countryCodes);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = List<CountryCode>.from(countryCodes);
      } else {
        _filteredCountries = countryCodes.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.isoCode.toLowerCase().contains(query) ||
              country.dialCode.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select country',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Search country',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredCountries.isEmpty
                  ? const Center(child: Text('No countries found'))
                  : ListView.builder(
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  final bool isSelected =
                      country.isoCode == widget.selectedCountry.isoCode;

                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    subtitle: Text(country.isoCode),
                    trailing: Text(
                      country.dialCode,
                      style: TextStyle(
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}