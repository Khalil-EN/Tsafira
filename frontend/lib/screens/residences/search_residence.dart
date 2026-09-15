import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'residence_list.dart';
import '../../widgets/common/labeled_field_box.dart';
import '../../widgets/common/counter_stepper.dart';

class SearchResidence extends StatefulWidget {
  const SearchResidence({Key? key}) : super(key: key);

  @override
  _SearchResidenceState createState() => _SearchResidenceState();
}

class _SearchResidenceState extends State<SearchResidence> {
  final TextEditingController _locationController =
  TextEditingController(text: 'City, country');

  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 2));

  int _guestCount = 2;
  int _roomCount = 1;

  RangeValues _moneyRange = const RangeValues(50, 200);
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _minPriceController.text = _moneyRange.start.round().toString();
    _maxPriceController.text = _moneyRange.end.round().toString();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isCheckIn}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate : _checkOutDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked == null) return;

    setState(() {
      if (isCheckIn) {
        _checkInDate = picked;
      } else {
        _checkOutDate = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Search Residence', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                      label: 'Check In',
                      icon: Icons.calendar_today,
                      displayValue: DateFormat('dd MMM').format(_checkInDate),
                      onTap: () => _selectDate(isCheckIn: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LabeledFieldBox(
                      label: 'Check Out',
                      icon: Icons.calendar_today,
                      displayValue: DateFormat('dd MMM').format(_checkOutDate),
                      onTap: () => _selectDate(isCheckIn: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Guests', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        CounterStepper(
                          value: _guestCount,
                          onChanged: (v) => setState(() => _guestCount = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rooms', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        CounterStepper(
                          value: _roomCount,
                          onChanged: (v) => setState(() => _roomCount = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Money', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Min',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        onChanged: (value) {
                          final newMin = double.tryParse(value) ?? _moneyRange.start;
                          setState(() {
                            _moneyRange = RangeValues(newMin.clamp(0, 1000), _moneyRange.end);
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: RangeSlider(
                      values: _moneyRange,
                      min: 0,
                      max: 1000,
                      divisions: 30,
                      labels: RangeLabels(
                        '${_moneyRange.start.round()} Dhs',
                        '${_moneyRange.end.round()} Dhs',
                      ),
                      activeColor: Colors.blue,
                      inactiveColor: Colors.blue.shade100,
                      onChanged: (values) {
                        setState(() {
                          _moneyRange = values;
                          _minPriceController.text = values.start.round().toString();
                          _maxPriceController.text = values.end.round().toString();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Max',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        onChanged: (value) {
                          final newMax = double.tryParse(value) ?? _moneyRange.end;
                          setState(() {
                            _moneyRange = RangeValues(_moneyRange.start, newMax.clamp(0, 1000));
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResidencesPage(
                          isFromSearch: true,
                          checkInDate: _checkInDate,
                          checkOutDate: _checkOutDate,
                          minPrice: _moneyRange.start,
                          maxPrice: _moneyRange.end,
                          location: _locationController.text,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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