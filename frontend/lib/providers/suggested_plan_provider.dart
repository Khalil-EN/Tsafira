import 'package:flutter/material.dart';

import '../services/api_services.dart';
import '../utils/suggested_plan_parser.dart';

class SuggestedPlanProvider extends ChangeNotifier {
  int selectedDayIndex = 0;
  List<DateTime> days = [];
  Map<String, dynamic>? planData;
  bool isLoading = true;
  Object? error;

  Future<void> load(Map<String, dynamic> planParams, int requestedDays) async {
    isLoading = true;
    error = null;
    planData = null;
    days = _generateDaysList(requestedDays);
    notifyListeners();

    try {
      final response = await ItineraryService.generateSuggested(planParams);
      final unwrapped = SuggestedPlanParser.unwrapPlan(response);

      if (SuggestedPlanParser.hasValidItinerary(unwrapped)) {
        _syncGeneratedDays(unwrapped);
        planData = unwrapped;
      }
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectDay(int index) {
    selectedDayIndex = index;
    notifyListeners();
  }

  void addLocalDay() {
    days.add(days.isEmpty ? DateTime.now() : days.last.add(const Duration(days: 1)));
    notifyListeners();
  }

  List<DateTime> _generateDaysList(int numberOfDays) {
    if (numberOfDays <= 0) return [];
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day);
    return List.generate(numberOfDays, (i) => startDate.add(Duration(days: i)));
  }

  void _syncGeneratedDays(Map<String, dynamic> planData) {
    final generatedDayCount = SuggestedPlanParser.getPlanDays(planData).length;
    if (generatedDayCount == 0 || days.length == generatedDayCount) return;

    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day);
    days = List.generate(generatedDayCount, (i) => startDate.add(Duration(days: i)));

    if (selectedDayIndex > generatedDayCount + 1) {
      selectedDayIndex = 0;
    }
  }
}