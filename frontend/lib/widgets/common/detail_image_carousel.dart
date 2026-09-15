import 'package:flutter/material.dart';

class DetailImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final VoidCallback? onBack;

  const DetailImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 350,
    this.onBack,
  });

  @override
  State<DetailImageCarousel> createState() => _DetailImageCarouselState();
}

class _DetailImageCarouselState extends State<DetailImageCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls.isEmpty ? [''] : widget.imageUrls;

    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _current = index),
            itemBuilder: (context, index) {
              final url = images[index];

              if (url.isEmpty) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 60, color: Colors.grey),
                  ),
                );
              }

              return Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}