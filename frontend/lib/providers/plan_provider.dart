import 'package:flutter/material.dart';


class PlanProvider with ChangeNotifier {
  String city = '';
  String country = '';
  Map<String, int> interests = {};
  String groupType = '';
  int budget = 0;
  int days = 0;
  int number_of_people = 0;
  int day = 0;
  int month = 0;
  int year = 0;
  String budgetCategory = "";
  Set<String> selectedActivities = {};
  Set<String> selectedCities = {};
  Set<String> selectedHotelLocations = {};
  String AccommodationType = "";
  List<String> selectedMeals = [];
  List<String> selectedRestaurantTypes = [];
  List<String> selectedPaymentFeatures = [];
  List<String> selectedDietaryPreferences = [];

  // Update methods
  void setCity(String value) {
    city = value;
    notifyListeners();
  }

  void setAccomodationType(String value) {
    AccommodationType = value;
    notifyListeners();
  }

  void setSelectedMeals(List<String> value) {
    selectedMeals = value;
    notifyListeners();
  }

  void setSelectedRestaurantTypes(List<String> value) {
    selectedRestaurantTypes = value;
    notifyListeners();
  }

  void setSelectedPaymentFeatures(List<String> value) {
    selectedPaymentFeatures = value;
    notifyListeners();
  }

  void setSelectedDietary(List<String> value) {
    selectedDietaryPreferences = value;
    notifyListeners();
  }

  void setSelectedActivities(Set<String> value) {
    selectedActivities = value;
    notifyListeners();
  }
  void setSelectedCities(Set<String> value) {
    selectedCities = value;
    notifyListeners();
  }

  void setSelectedHotelLocations(Set<String> value) {
    selectedHotelLocations = value;
    notifyListeners();
  }

  void setCountry(String value) {
    country = value;
    notifyListeners();
  }
  void setBudgetCategory(String value) {
    budgetCategory = value;
    notifyListeners();
  }
  void setNbrPeople(int value) {
    number_of_people = value;
    notifyListeners();
  }
  void setDay(int value) {
    day = value;
    notifyListeners();
  }
  void setMonth(int value) {
    month = value;
    notifyListeners();
  }
  void setYear(int value) {
    year = value;
    notifyListeners();
  }

  void setDays(int value){
    days = value;
    notifyListeners();
  }

  void setInterests(Map<String, int> value) {
    interests = value;
    notifyListeners();
  }

  void setGroupType(String value) {
    groupType = value;
    notifyListeners();
  }

  void setBudget(int value) {
    budget = value;
    notifyListeners();
  }

  // Method to retrieve all data as a Map
  Map<String, dynamic> toMap() {
    return {
      'country' : country,
      'city': city,
      'destinations': selectedCities.toList(),
      'interests': selectedActivities.toList(),
      'groupType': groupType,
      'nbrPeople' : number_of_people,
      'budget': budget,
      'category' : budgetCategory,
      'days': days,
      'day' : day,
      'month' : month,
      'year' : year,
      'accomodationType' : AccommodationType,
      'hotelLocation' : selectedHotelLocations.toList(),
      'meals' : selectedMeals,
      'restaurantTags' : selectedRestaurantTypes,
      'paymentPreferences' : selectedPaymentFeatures,
      'dietaryPreferences' : selectedDietaryPreferences,

    };
  }
}
