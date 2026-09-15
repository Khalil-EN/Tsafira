import '../models/trip_plan_item.dart';
import '../models/trip_plan_budget.dart';

/// Turns the raw suggested-plan API response into the typed shapes the
/// UI consumes. Pure functions only — no widget or navigation concerns.
class SuggestedPlanParser {
  SuggestedPlanParser._();

  static Map<String, dynamic> unwrapPlan(Map<String, dynamic> responseData) {
    final rawPlan = responseData['plan'];
    if (rawPlan is Map) return Map<String, dynamic>.from(rawPlan);

    final rawData = responseData['data'];
    if (rawData is Map) {
      final nestedPlan = rawData['plan'];
      if (nestedPlan is Map) return Map<String, dynamic>.from(nestedPlan);
      return Map<String, dynamic>.from(rawData);
    }

    return responseData;
  }

  static bool hasValidItinerary(Map<String, dynamic> planData) {
    final days = planData['days'];
    return days is List && days.isNotEmpty;
  }

  static List<Map<String, dynamic>> getPlanDays(Map<String, dynamic> planData) {
    final rawDays = planData['days'];
    if (rawDays is! List) return [];
    return rawDays.whereType<Map>().map((d) => Map<String, dynamic>.from(d)).toList();
  }

  static List<TripPlanItem> getSelectedItems(
      Map<String, dynamic> planData,
      int selectedDayIndex,
      int dayCount,
      ) {
    if (selectedDayIndex == 0) {
      final residency = planData['residency'];
      if (residency is Map) {
        return [TripPlanItem.fromJson(Map<String, dynamic>.from(residency), type: 'residency')];
      }
      return [];
    }

    if (selectedDayIndex == dayCount + 1) {
      final nightActivities = planData['nightActivities'];
      if (nightActivities is! List) return [];
      return nightActivities
          .whereType<Map>()
          .map((item) => TripPlanItem.fromJson(Map<String, dynamic>.from(item), type: 'nightActivity'))
          .toList();
    }

    if (selectedDayIndex >= 1 && selectedDayIndex <= dayCount) {
      return getDayItems(planData, selectedDayIndex);
    }

    return [];
  }

  static List<TripPlanItem> getDayItems(Map<String, dynamic> planData, int dayNumber) {
    final items = <TripPlanItem>[];
    final days = planData['days'];
    if (days is! List) return items;

    Map<String, dynamic>? selectedDay;
    for (final rawDay in days) {
      if (rawDay is! Map) continue;
      final day = Map<String, dynamic>.from(rawDay);
      final rawDayNumber = day['day'];
      if (rawDayNumber is num && rawDayNumber.toInt() == dayNumber) {
        selectedDay = day;
        break;
      }
    }
    if (selectedDay == null) return items;

    final breakfastRestaurant = _getBreakfastRestaurantForDay(planData, dayNumber);
    if (breakfastRestaurant != null) {
      items.add(TripPlanItem.fromJson(breakfastRestaurant, type: 'breakfast'));
    } else if (_isMealRequested(planData, 'breakfast')) {
      items.add(TripPlanItem.breakfastUnavailable());
    }

    for (final activity in _getActivityGroup(selectedDay, groupKey: 'morningActivities', fallbackKey: 'morningActivity')) {
      items.add(TripPlanItem.fromJson(activity, type: 'activity', section: 'morning'));
    }

    final lunch = selectedDay['lunch'];
    if (lunch is Map) {
      items.add(TripPlanItem.fromJson(Map<String, dynamic>.from(lunch), type: 'restaurant'));
    }

    for (final activity in _getActivityGroup(selectedDay, groupKey: 'afternoonActivities', fallbackKey: 'afternoonActivity')) {
      items.add(TripPlanItem.fromJson(activity, type: 'activity', section: 'afternoon'));
    }

    final dinner = selectedDay['dinner'];
    if (dinner is Map) {
      items.add(TripPlanItem.fromJson(Map<String, dynamic>.from(dinner), type: 'restaurant'));
    }

    return items;
  }

  static List<Map<String, dynamic>> _getActivityGroup(
      Map<String, dynamic> day, {
        required String groupKey,
        required String fallbackKey,
      }) {
    final rawGroup = day[groupKey];
    if (rawGroup is List) {
      return rawGroup.whereType<Map>().map((a) => Map<String, dynamic>.from(a)).toList();
    }
    final fallback = day[fallbackKey];
    if (fallback is Map) return [Map<String, dynamic>.from(fallback)];
    return [];
  }

  static bool _isMealRequested(Map<String, dynamic> planData, String meal) {
    final meals = planData['meals'];
    if (meals is! List) return false;
    return meals.any((item) => item.toString().trim().toLowerCase() == meal.trim().toLowerCase());
  }

  static Map<String, dynamic>? _getBreakfastRestaurantForDay(
      Map<String, dynamic> planData,
      int dayNumber,
      ) {
    final breakfastSlots = planData['breakfastSlots'];
    if (breakfastSlots is! List) return null;

    for (final rawSlot in breakfastSlots) {
      if (rawSlot is! Map) continue;
      final slot = Map<String, dynamic>.from(rawSlot);
      final rawDay = slot['day'];
      if (rawDay is! num || rawDay.toInt() != dayNumber) continue;
      final restaurant = slot['restaurant'];
      if (restaurant is Map) return Map<String, dynamic>.from(restaurant);
    }
    return null;
  }

  static List<String> getWarnings(Map<String, dynamic> planData) {
    final warnings = <String>[];

    void addWarning(dynamic value) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && !warnings.contains(text)) warnings.add(text);
    }

    final rawWarnings = planData['warnings'];
    if (rawWarnings is List) {
      for (final w in rawWarnings) addWarning(w);
    }

    final budget = getBudget(planData);
    if (budget != null) {
      for (final w in budget.warnings) addWarning(w);
      if (budget.overBudget > 0) {
        addWarning('The itinerary exceeds your budget by ${budget.overBudget.toStringAsFixed(2)} DH.');
      }
    }

    return warnings;
  }

  static TripPlanBudget? getBudget(Map<String, dynamic> planData) {
    final rawBudget = planData['budget'];
    if (rawBudget is! Map) return null;
    return TripPlanBudget.fromJson(Map<String, dynamic>.from(rawBudget));
  }
}