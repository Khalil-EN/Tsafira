
import 'package:flutter/material.dart';
import '../../../models/activity.dart';
import '../../../widgets/common/detail_image_carousel.dart';
import '../../../widgets/common/checklist_row.dart';

class ActivityDetailsPage extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsPage({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final images = activity.imageUrl.trim().isNotEmpty ? [activity.imageUrl] : <String>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailImageCarousel(imageUrls: images),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          activity.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        activity.price,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${activity.rating.toStringAsFixed(1)} (${activity.reviews})',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // About Section
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activity.type.isNotEmpty ? activity.type : 'No activity type available.',
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),

                  // Highlights Section
                  if (activity.highlights.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Activity Highlights',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...activity.highlights.map(
                          (item) => ChecklistRow(
                        label: item,
                        color: primaryColor,
                      ),
                    ),
                  ],

                  // Schedule Section
                  if (activity.schedule.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Schedule',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...activity.schedule.entries.map(
                          (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Text(
                                entry.value,
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // What to Bring Section
                  if (activity.itemsToBring.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'What to Bring',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...activity.itemsToBring.map(
                          (item) => ChecklistRow(
                        label: item,
                        icon: Icons.check_circle_outline,
                        color: primaryColor,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Booking Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Book this Activity',
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