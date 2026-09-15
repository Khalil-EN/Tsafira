import 'activity.dart';
import 'residence.dart';
import 'restaurant.dart';
import 'trip_plan_item.dart';

extension TripPlanItemResidenceConverter on TripPlanItem {
  Residence toResidence() {
    return Residence(
      id: id ?? '',
      name: name,
      location: location,
      price: int.tryParse(price) ?? 0,
      rating: rating,
      reviews: reviews,
      description: description,
      imageUrl: image,
      imageUrls: imageUrls,
      amenities: facilities,
    );
  }
}

extension TripPlanItemActivityConverter on TripPlanItem {
  Activity toActivity() {
    return Activity(
      id: id ?? '',
      name: name,
      location: location,
      rating: rating,
      reviews: reviews,
      type: activityType,
      imageUrl: image,
      price: price.isNotEmpty ? price : 'Free',
      highlights: const [],
      schedule: const {},
      itemsToBring: const [],
    );
  }
}

extension TripPlanItemRestaurantConverter on TripPlanItem {
  Restaurant toRestaurant() {
    return Restaurant(
      id: id ?? '',
      name: name,
      location: location,
      price: price,
      rating: rating,
      reviews: reviews,
      openingHours: openingHours,
      description: description,
      images: imageUrls,
      facilities: facilities,
    );
  }
}