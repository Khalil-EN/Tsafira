import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/common/selectable_list_tile.dart';
import 'activity_preferences_screen.dart';

class BudgetSelectionScreen extends StatefulWidget {
  const BudgetSelectionScreen({Key? key}) : super(key: key);

  @override
  _BudgetSelectionScreenState createState() => _BudgetSelectionScreenState();
}

class _BudgetSelectionScreenState extends State<BudgetSelectionScreen> {
  final List<Map<String, dynamic>> budgetOptions = [
    {'title': 'Cheap', 'description': 'Stay conscious of costs', 'image': 'assets/cheap.png'},
    {'title': 'Moderate', 'description': 'Keep cost on the average side', 'image': 'assets/moderate.png'},
    {'title': 'Luxury', 'description': "Don't worry about cost", 'image': 'assets/luxury.png'},
  ];

  String? selectedOption;
  final TextEditingController budgetController = TextEditingController();
  bool showNotification = false;
  String notificationMessage = '';
  String suggestedOption = '';

  static const double CHEAP_THRESHOLD = 2500;
  static const double MODERATE_THRESHOLD = 9000;

  @override
  void initState() {
    super.initState();
    budgetController.addListener(_checkBudgetCategory);
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  String? _getSuggestedCategory(double amount) {
    if (amount < CHEAP_THRESHOLD) return 'Cheap';
    if (amount < MODERATE_THRESHOLD) return 'Moderate';
    return 'Luxury';
  }

  void _checkBudgetCategory() {
    if (selectedOption == null || budgetController.text.isEmpty) {
      setState(() => showNotification = false);
      return;
    }

    final budgetNum = double.tryParse(budgetController.text);
    if (budgetNum == null) return;

    final suggested = _getSuggestedCategory(budgetNum);
    if (suggested != selectedOption) {
      setState(() {
        suggestedOption = suggested!;
        notificationMessage =
        'Your budget of $budgetNum DH suggests "$suggested" rather than "$selectedOption". Do you want to change?';
        showNotification = true;
      });
    } else {
      setState(() => showNotification = false);
    }
  }

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
              const Text("Budget", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 10),
              const Text('Choose spending habits for your trip', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: budgetOptions.length,
                  itemBuilder: (context, index) {
                    final option = budgetOptions[index];
                    final isSelected = selectedOption == option['title'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SelectableListTile(
                        isSelected: isSelected,
                        title: option['title'],
                        subtitle: option['description'],
                        trailing: Image.asset(option['image'], width: 48, height: 48),
                        onTap: () {
                          setState(() {
                            selectedOption = option['title'];
                            _checkBudgetCategory();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              if (selectedOption != null) ...[
                const Text('Enter your budget amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: TextField(
                    controller: budgetController,
                    style: const TextStyle(fontSize: 18),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Your budget (DH)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(width: 2),
                      ),
                      hintText: 'Type your budget amount here',
                      filled: true,
                      fillColor: const Color(0xFFF1EFFF),
                      suffixText: 'DH',
                      suffixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (showNotification)
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade300, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notificationMessage, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => showNotification = false),
                            child: const Text('Keep current'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedOption = suggestedOption;
                                showNotification = false;
                              });
                            },
                            child: const Text('Change to suggested'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: (selectedOption != null && budgetController.text.isNotEmpty)
                        ? () {
                      final budget = int.tryParse(budgetController.text);
                      provider.setBudget(budget!);
                      provider.setBudgetCategory(selectedOption!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ActivityPreferences()),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
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