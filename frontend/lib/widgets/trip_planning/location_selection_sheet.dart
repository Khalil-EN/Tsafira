import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';

class LocationSelectionView extends StatefulWidget {
  final ScrollController scrollController;
  final Function(Map<String, String>, String) onLocationSelected;

  const LocationSelectionView({
    super.key,
    required this.scrollController,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectionView> createState() => _LocationSelectionViewState();
}

class _LocationSelectionViewState extends State<LocationSelectionView> {
  String searchQuery = '';
  Map<String, String>? selectedCountry;
  final TextEditingController cityController = TextEditingController();
  bool useCurrentLocation = false;

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlanProvider>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text("Set Your Current Location",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                useCurrentLocation = !useCurrentLocation;
                if (useCurrentLocation) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Accessing your current location...'), duration: Duration(seconds: 1)),
                  );
                }
              });
            },
            child: Row(
              children: [
                Icon(useCurrentLocation ? Icons.check_circle : Icons.circle_outlined, color: const Color(0xFF6C63FF), size: 24),
                const SizedBox(width: 12),
                const Text("Use my current location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.my_location, color: Color(0xFF6C63FF), size: 22),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Text("Or manually select your location:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        if (selectedCountry == null) _buildCountrySelection() else _buildCityInput(),
        if (selectedCountry != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (cityController.text.isNotEmpty || useCurrentLocation) {
                    provider.setCountry(selectedCountry!["name"]!);
                    provider.setCity(cityController.text);
                    widget.onLocationSelected(selectedCountry!, useCurrentLocation ? "Current Location" : cityController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your city or use current location'), duration: Duration(seconds: 2)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("CONTINUE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCountrySelection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search countries",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: _buildCountryList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Selected country: ${selectedCountry!["name"]}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF4A55A2))),
              const Spacer(),
              TextButton(onPressed: () => setState(() => selectedCountry = null), child: const Text("Change")),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cityController,
            decoration: InputDecoration(
              labelText: "Enter your city",
              hintText: "e.g., New York, Paris, Tokyo",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.location_city),
            ),
            enabled: !useCurrentLocation,
          ),
        ],
      ),
    );
  }

  // NOTE: duplicates signup.dart's `countryCodes` list (different shape:
  // name/code here vs. name/dialCode/flag there). Worth consolidating into
  // one shared dataset — flagged, not fixed in this pass.
  List<Widget> _buildCountryList() {
    final List<Map<String, String>> countries = [
      {"name": "Afghanistan", "code": "AF"}, {"name": "Albania", "code": "AL"},
      {"name": "Algeria", "code": "DZ"}, {"name": "Andorra", "code": "AD"},
      {"name": "Angola", "code": "AO"}, {"name": "Antigua and Barbuda", "code": "AG"},
      {"name": "Argentina", "code": "AR"}, {"name": "Armenia", "code": "AM"},
      {"name": "Australia", "code": "AU"}, {"name": "Austria", "code": "AT"},
      {"name": "Azerbaijan", "code": "AZ"}, {"name": "Bahamas", "code": "BS"},
      {"name": "Bahrain", "code": "BH"}, {"name": "Bangladesh", "code": "BD"},
      {"name": "Barbados", "code": "BB"}, {"name": "Belarus", "code": "BY"},
      {"name": "Belgium", "code": "BE"}, {"name": "Belize", "code": "BZ"},
      {"name": "Benin", "code": "BJ"}, {"name": "Bhutan", "code": "BT"},
      {"name": "Bolivia", "code": "BO"}, {"name": "Bosnia and Herzegovina", "code": "BA"},
      {"name": "Botswana", "code": "BW"}, {"name": "Brazil", "code": "BR"},
      {"name": "Brunei", "code": "BN"}, {"name": "Bulgaria", "code": "BG"},
      {"name": "Burkina Faso", "code": "BF"}, {"name": "Burundi", "code": "BI"},
      {"name": "Cabo Verde", "code": "CV"}, {"name": "Cambodia", "code": "KH"},
      {"name": "Cameroon", "code": "CM"}, {"name": "Canada", "code": "CA"},
      {"name": "Central African Republic", "code": "CF"}, {"name": "Chad", "code": "TD"},
      {"name": "Chile", "code": "CL"}, {"name": "China", "code": "CN"},
      {"name": "Colombia", "code": "CO"}, {"name": "Comoros", "code": "KM"},
      {"name": "Congo", "code": "CG"}, {"name": "Costa Rica", "code": "CR"},
      {"name": "Croatia", "code": "HR"}, {"name": "Cuba", "code": "CU"},
      {"name": "Cyprus", "code": "CY"}, {"name": "Czech Republic", "code": "CZ"},
      {"name": "Denmark", "code": "DK"}, {"name": "Djibouti", "code": "DJ"},
      {"name": "Dominica", "code": "DM"}, {"name": "Dominican Republic", "code": "DO"},
      {"name": "Ecuador", "code": "EC"}, {"name": "Egypt", "code": "EG"},
      {"name": "El Salvador", "code": "SV"}, {"name": "Equatorial Guinea", "code": "GQ"},
      {"name": "Eritrea", "code": "ER"}, {"name": "Estonia", "code": "EE"},
      {"name": "Eswatini", "code": "SZ"}, {"name": "Ethiopia", "code": "ET"},
      {"name": "Fiji", "code": "FJ"}, {"name": "Finland", "code": "FI"},
      {"name": "France", "code": "FR"}, {"name": "Gabon", "code": "GA"},
      {"name": "Gambia", "code": "GM"}, {"name": "Georgia", "code": "GE"},
      {"name": "Germany", "code": "DE"}, {"name": "Ghana", "code": "GH"},
      {"name": "Greece", "code": "GR"}, {"name": "Grenada", "code": "GD"},
      {"name": "Guatemala", "code": "GT"}, {"name": "Guinea", "code": "GN"},
      {"name": "Guinea-Bissau", "code": "GW"}, {"name": "Guyana", "code": "GY"},
      {"name": "Haiti", "code": "HT"}, {"name": "Honduras", "code": "HN"},
      {"name": "Hungary", "code": "HU"}, {"name": "Iceland", "code": "IS"},
      {"name": "India", "code": "IN"}, {"name": "Indonesia", "code": "ID"},
      {"name": "Iran", "code": "IR"}, {"name": "Iraq", "code": "IQ"},
      {"name": "Ireland", "code": "IE"}, {"name": "Israel", "code": "IL"},
      {"name": "Italy", "code": "IT"}, {"name": "Jamaica", "code": "JM"},
      {"name": "Japan", "code": "JP"}, {"name": "Jordan", "code": "JO"},
      {"name": "Kazakhstan", "code": "KZ"}, {"name": "Kenya", "code": "KE"},
      {"name": "Kiribati", "code": "KI"}, {"name": "Kuwait", "code": "KW"},
      {"name": "Kyrgyzstan", "code": "KG"}, {"name": "Laos", "code": "LA"},
      {"name": "Latvia", "code": "LV"}, {"name": "Lebanon", "code": "LB"},
      {"name": "Lesotho", "code": "LS"}, {"name": "Liberia", "code": "LR"},
      {"name": "Libya", "code": "LY"}, {"name": "Liechtenstein", "code": "LI"},
      {"name": "Lithuania", "code": "LT"}, {"name": "Luxembourg", "code": "LU"},
      {"name": "Madagascar", "code": "MG"}, {"name": "Malawi", "code": "MW"},
      {"name": "Malaysia", "code": "MY"}, {"name": "Maldives", "code": "MV"},
      {"name": "Mali", "code": "ML"}, {"name": "Malta", "code": "MT"},
      {"name": "Marshall Islands", "code": "MH"}, {"name": "Mauritania", "code": "MR"},
      {"name": "Mauritius", "code": "MU"}, {"name": "Mexico", "code": "MX"},
      {"name": "Micronesia", "code": "FM"}, {"name": "Moldova", "code": "MD"},
      {"name": "Monaco", "code": "MC"}, {"name": "Mongolia", "code": "MN"},
      {"name": "Montenegro", "code": "ME"}, {"name": "Morocco", "code": "MA"},
      {"name": "Mozambique", "code": "MZ"}, {"name": "Myanmar", "code": "MM"},
      {"name": "Namibia", "code": "NA"}, {"name": "Nauru", "code": "NR"},
      {"name": "Nepal", "code": "NP"}, {"name": "Netherlands", "code": "NL"},
      {"name": "New Zealand", "code": "NZ"}, {"name": "Nicaragua", "code": "NI"},
      {"name": "Niger", "code": "NE"}, {"name": "Nigeria", "code": "NG"},
      {"name": "North Korea", "code": "KP"}, {"name": "North Macedonia", "code": "MK"},
      {"name": "Norway", "code": "NO"}, {"name": "Oman", "code": "OM"},
      {"name": "Pakistan", "code": "PK"}, {"name": "Palau", "code": "PW"},
      {"name": "Palestine", "code": "PS"}, {"name": "Panama", "code": "PA"},
      {"name": "Papua New Guinea", "code": "PG"}, {"name": "Paraguay", "code": "PY"},
      {"name": "Peru", "code": "PE"}, {"name": "Philippines", "code": "PH"},
      {"name": "Poland", "code": "PL"}, {"name": "Portugal", "code": "PT"},
      {"name": "Qatar", "code": "QA"}, {"name": "Romania", "code": "RO"},
      {"name": "Russia", "code": "RU"}, {"name": "Rwanda", "code": "RW"},
      {"name": "Saint Kitts and Nevis", "code": "KN"}, {"name": "Saint Lucia", "code": "LC"},
      {"name": "Saint Vincent and the Grenadines", "code": "VC"}, {"name": "Samoa", "code": "WS"},
      {"name": "San Marino", "code": "SM"}, {"name": "Sao Tome and Principe", "code": "ST"},
      {"name": "Saudi Arabia", "code": "SA"}, {"name": "Senegal", "code": "SN"},
      {"name": "Serbia", "code": "RS"}, {"name": "Seychelles", "code": "SC"},
      {"name": "Sierra Leone", "code": "SL"}, {"name": "Singapore", "code": "SG"},
      {"name": "Slovakia", "code": "SK"}, {"name": "Slovenia", "code": "SI"},
      {"name": "Solomon Islands", "code": "SB"}, {"name": "Somalia", "code": "SO"},
      {"name": "South Africa", "code": "ZA"}, {"name": "South Korea", "code": "KR"},
      {"name": "South Sudan", "code": "SS"}, {"name": "Spain", "code": "ES"},
      {"name": "Sri Lanka", "code": "LK"}, {"name": "Sudan", "code": "SD"},
      {"name": "Suriname", "code": "SR"}, {"name": "Sweden", "code": "SE"},
      {"name": "Switzerland", "code": "CH"}, {"name": "Syria", "code": "SY"},
      {"name": "Taiwan", "code": "TW"}, {"name": "Tajikistan", "code": "TJ"},
      {"name": "Tanzania", "code": "TZ"}, {"name": "Thailand", "code": "TH"},
      {"name": "Timor-Leste", "code": "TL"}, {"name": "Togo", "code": "TG"},
      {"name": "Tonga", "code": "TO"}, {"name": "Trinidad and Tobago", "code": "TT"},
      {"name": "Tunisia", "code": "TN"}, {"name": "Turkey", "code": "TR"},
      {"name": "Turkmenistan", "code": "TM"}, {"name": "Tuvalu", "code": "TV"},
      {"name": "Uganda", "code": "UG"}, {"name": "Ukraine", "code": "UA"},
      {"name": "United Arab Emirates", "code": "AE"}, {"name": "United Kingdom", "code": "GB"},
      {"name": "United States", "code": "US"}, {"name": "Uruguay", "code": "UY"},
      {"name": "Uzbekistan", "code": "UZ"}, {"name": "Vanuatu", "code": "VU"},
      {"name": "Vatican City", "code": "VA"}, {"name": "Venezuela", "code": "VE"},
      {"name": "Vietnam", "code": "VN"}, {"name": "Yemen", "code": "YE"},
      {"name": "Zambia", "code": "ZM"}, {"name": "Zimbabwe", "code": "ZW"},
    ];

    final filtered = searchQuery.isEmpty
        ? countries
        : countries.where((c) => c["name"]!.toLowerCase().contains(searchQuery) || c["code"]!.toLowerCase().contains(searchQuery)).toList();

    return filtered.map((country) {
      return InkWell(
        onTap: () => setState(() => selectedCountry = country),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 40, height: 28,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                alignment: Alignment.center,
                child: Text(country["code"]!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Text(country["name"]!, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }).toList();
  }
}