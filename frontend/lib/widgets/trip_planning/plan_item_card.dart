import 'package:flutter/material.dart';
import '../../models/trip_plan_item.dart';

class PlanItemCard extends StatelessWidget {
  final TripPlanItem item;
  final VoidCallback onTap;

  const PlanItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (item.type == 'breakfastUnavailable') {
      return _UnavailableMealCard(description: item.description);
    }

    final tags = item.tags;

    return Card(
      margin: const EdgeInsets.only(right: 16, top: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlanImage(imageUrl: item.image, height: 180, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(item.icon, size: 18, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(item.typeLabel, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name.isNotEmpty ? item.name : 'Unnamed place',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.bookmark_border), onPressed: () {}),
                      IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.more_horiz), onPressed: () {}),
                    ],
                  ),
                  if (item.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(child: Text(item.location, style: TextStyle(color: Colors.grey.shade700, fontSize: 14))),
                      ],
                    ),
                  ],
                  if (item.rating > 0 || item.reviews > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (item.reviews > 0) ...[
                          const SizedBox(width: 4),
                          Text('(${item.reviews} reviews)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ],
                    ),
                  ],
                  if (item.priceLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.payments_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(child: Text(item.priceLabel, style: const TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ],
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(item.description, maxLines: 3, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                          child: Text(tag, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text('Tap to view details', style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableMealCard extends StatelessWidget {
  final String description;

  const _UnavailableMealCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.free_breakfast_outlined, color: Colors.orange.shade800, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Breakfast unavailable',
                    style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(description, style: TextStyle(color: Colors.orange.shade900, fontSize: 13, height: 1.35)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final BorderRadius? borderRadius;

  const _PlanImage({required this.imageUrl, this.height = 150, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: borderRadius),
      child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 45, color: Colors.grey)),
    );

    if (imageUrl.trim().isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(height: height, width: double.infinity, color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}