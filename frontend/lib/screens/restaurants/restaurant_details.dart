import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../widgets/common/checklist_row.dart';
import '../../widgets/common/detail_image_carousel.dart';

class RestaurantDetails extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetails({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validImages =
    restaurant.images.where((url) => url.trim().isNotEmpty).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
      ),
      extendBodyBehindAppBar: validImages.isNotEmpty,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (validImages.isNotEmpty)
              DetailImageCarousel(imageUrls: validImages)
            else
              Container(
                height: 250,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.restaurant, size: 60, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        restaurant.price,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.deepPurple, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          restaurant.location.isNotEmpty
                              ? restaurant.location
                              : 'Location not specified',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${restaurant.rating.toStringAsFixed(1)} (${restaurant.reviews} reviews)',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.description.isNotEmpty
                        ? restaurant.description
                        : 'No description available.',
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Facilities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (restaurant.facilities.isEmpty)
                    const Text(
                      'No facilities information available.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...restaurant.facilities.map(
                          (facility) => ChecklistRow(
                        label: facility,
                        color: Colors.deepPurple,
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Operating Hours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Monday - Sunday',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            restaurant.openingHours.isNotEmpty
                                ? restaurant.openingHours
                                : 'Not available',
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Book a Table',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}