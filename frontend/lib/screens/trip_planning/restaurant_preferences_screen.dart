import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/common/selectable_list_tile.dart';
import '../../widgets/common/selectable_icon_option.dart';
import '../../widgets/common/selectable_feature_chip.dart';
import 'planning_method_selection_screen.dart';

class RestaurantPreferences extends StatefulWidget {
  const RestaurantPreferences({Key? key}) : super(key: key);

  @override
  _RestaurantPreferencesState createState() => _RestaurantPreferencesState();
}

class _RestaurantPreferencesState extends State<RestaurantPreferences> {
  final Map<String, bool> meals = {
    'Breakfast': false,
    'Lunch': false,
    'Dinner': false,
  };

  final Map<String, bool> restaurantTypes = {
    'Fast-Food': false,
    'Traditional Moroccan': false,
    'Modern (European/Asian)': false,
    'Seafood': false,
    'Café': false,
  };

  final Map<String, bool> paymentFeatures = {
    'Cash Payment': false,
    'Credit Card': false,
    'WiFi': false,
    'Takeout': false,
  };

  final Map<String, bool> dietaryPreferences = {
    'Vegan Options': false,
    'Vegetarian Friendly': false,
    'Gluten-Free Options': false,
    'Diabetic Friendly': false,
    'Halal': false,
  };

  IconData _getIconForMeal(String meal) {
    switch (meal) {
      case 'Breakfast':
        return Icons.free_breakfast;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  // Fixed: case labels now match the actual map keys above
  // ('Fast-Food', not 'Fast Food') — previously this always fell
  // through to the default icon.
  IconData _getIconForRestaurantType(String type) {
    switch (type) {
      case 'Fast-Food':
        return Icons.fastfood;
      case 'Traditional Moroccan':
        return Icons.local_dining;
      case 'Modern (European/Asian)':
        return Icons.restaurant;
      case 'Seafood':
        return Icons.set_meal;
      case 'Café':
        return Icons.coffee;
      default:
        return Icons.restaurant;
    }
  }

  // Fixed: case labels now match the actual map keys ('WiFi',
  // 'Takeout', not 'WiFi Available', 'Takeout Option').
  IconData _getIconForPaymentFeature(String feature) {
    switch (feature) {
      case 'Cash Payment':
        return Icons.money;
      case 'Credit Card':
        return Icons.credit_card;
      case 'WiFi':
        return Icons.wifi;
      case 'Takeout':
        return Icons.takeout_dining;
      default:
        return Icons.check_circle_outline;
    }
  }

  IconData _getIconForDietaryPreference(String preference) {
    switch (preference) {
      case 'Vegan Options':
        return Icons.eco;
      case 'Vegetarian Friendly':
        return Icons.spa;
      case 'Gluten-Free Options':
        return Icons.no_food;
      case 'Diabetic Friendly':
        return Icons.monitor_heart;
      case 'Halal':
        return Icons.restaurant_menu;
      default:
        return Icons.food_bank;
    }
  }

  bool _anySelectionMade() {
    return meals.values.any((selected) => selected) ||
        restaurantTypes.values.any((selected) => selected) ||
        paymentFeatures.values.any((selected) => selected) ||
        dietaryPreferences.values.any((selected) => selected);
  }

  Widget _buildSelectableList(Map<String, bool> items, IconData Function(String) iconProvider) {
    return Column(
      children: items.keys.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: SelectableListTile(
            isSelected: items[item]!,
            title: item,
            leading: Icon(iconProvider(item)),
            onTap: () => setState(() => items[item] = !items[item]!),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeaturesGrid(Map<String, bool> features, IconData Function(String) iconProvider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features.keys.elementAt(index);
        final isSelected = features[feature]!;

        return SelectableFeatureChip(
          isSelected: isSelected,
          icon: iconProvider(feature),
          label: feature,
          onTap: () => setState(() => features[feature] = !isSelected),
        );
      },
    );
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
              const SizedBox(height: 16),
              const Text(
                'Restaurant Preferences',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2)),
              ),
              const SizedBox(height: 8),
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
                        'Select which meals you want to eat at restaurants, preferred cuisine types, and special features you need.',
                        style: TextStyle(color: Color(0xFF795548), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Which meals will you eat at restaurants?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A55A2)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: meals.keys.map((meal) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SelectableIconOption(
                              isSelected: meals[meal]!,
                              icon: _getIconForMeal(meal),
                              label: meal,
                              onTap: () => setState(() => meals[meal] = !meals[meal]!),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Preferred Cuisine Types',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A55A2)),
                    ),
                    const SizedBox(height: 10),
                    _buildSelectableList(restaurantTypes, _getIconForRestaurantType),
                    const SizedBox(height: 24),
                    const Text(
                      'Payment & Service Features',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A55A2)),
                    ),
                    const SizedBox(height: 10),
                    _buildFeaturesGrid(paymentFeatures, _getIconForPaymentFeature),
                    const SizedBox(height: 24),
                    const Text(
                      'Dietary Preferences',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A55A2)),
                    ),
                    const SizedBox(height: 10),
                    _buildFeaturesGrid(dietaryPreferences, _getIconForDietaryPreference),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _anySelectionMade()
                        ? () {
                      final selectedMeals = meals.entries.where((e) => e.value).map((e) => e.key).toList();
                      final selectedRestaurantTypes =
                      restaurantTypes.entries.where((e) => e.value).map((e) => e.key).toList();
                      final selectedPaymentFeatures =
                      paymentFeatures.entries.where((e) => e.value).map((e) => e.key).toList();
                      final selectedDietaryPreferences =
                      dietaryPreferences.entries.where((e) => e.value).map((e) => e.key).toList();

                      provider.setSelectedDietary(selectedDietaryPreferences);
                      provider.setSelectedRestaurantTypes(selectedRestaurantTypes);
                      provider.setSelectedPaymentFeatures(selectedPaymentFeatures);
                      provider.setSelectedMeals(selectedMeals);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlanningMethodSelection()),
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