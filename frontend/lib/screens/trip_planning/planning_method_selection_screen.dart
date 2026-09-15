import 'package:flutter/material.dart';
import 'personal_plan_screen.dart';
import 'suggested_plan_screen.dart';

class PlanningMethodSelection extends StatelessWidget {
  const PlanningMethodSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
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
                  'Choose your preferred way of planning',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2)),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PersonalPlanning()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 160,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1EFFF),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                          ),
                          child: const Center(
                            child: Icon(Icons.edit_calendar, size: 80, color: Color(0xFF6C63FF)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'Personal Planning',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2)),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.person, color: Color(0xFF6C63FF), size: 22),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'You manually add everything to your plan, including hotels, restaurants, and activities. No assistance is available.',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SuggestMyPlan()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 160,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6F2FF),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_awesome, size: 80, color: Color(0xFF4A89DC)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'Suggest My Plan',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2)),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.psychology, color: Color(0xFF4A89DC), size: 22),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Everything is set up for you thanks to our algorithm. If you want to modify, don't worry - you have the right to customize your suggested plan.",
                                style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFE082), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Color(0xFFFFA000), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can always switch between planning methods later.',
                          style: TextStyle(color: Color(0xFF795548), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}