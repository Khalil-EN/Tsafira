import 'package:flutter/material.dart';

import '../../exceptions/session_expired_exception.dart';
import '../auth/login_screen.dart';
import '../../models/restaurant.dart';
import 'restaurant_details.dart';
import 'restaurant_search.dart';
import '../../services/api_services.dart';

class RestaurantsPage extends StatefulWidget {
  final bool isFromSearch;
  final List<String>? cuisines;
  final DateTime? date;
  final String location;
  final double minPrice;
  final double maxPrice;
  final TimeOfDay? time;
  final int nbrGuests;
  final List<String>? dietaryOptions;
  final List<String>? specialFeatures;

  const RestaurantsPage({
    super.key,
    this.isFromSearch = false,
    this.location = '',
    this.cuisines,
    this.date,
    this.minPrice = 0,
    this.maxPrice = 0,
    this.time,
    this.nbrGuests = 0,
    this.specialFeatures,
    this.dietaryOptions,
  });

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      dynamic responseData;

      if (widget.isFromSearch) {
        final searchData = {
          'date': widget.date?.toIso8601String(),
          'time': widget.time != null ? '${widget.time!.hour}:${widget.time!.minute}' : null,
          'minPrice': widget.minPrice,
          'maxPrice': widget.maxPrice,
          'location': widget.location,
          'cuisines': widget.cuisines,
          'specialFeatures': widget.specialFeatures,
          'dietaryOptions': widget.dietaryOptions,
          'nbrGuests': widget.nbrGuests,
        };
        responseData = await SearchService.searchRestaurants(searchData);
      } else {
        responseData = await RestaurantService.getAll();
      }

      if (!mounted) return;

      List<Restaurant> parsedList = [];
      if (responseData is List) {
        parsedList = responseData
            .whereType<Map<String, dynamic>>()
            .map((json) => Restaurant.fromJson(json))
            .toList();
      }

      setState(() {
        _restaurants = parsedList;
        _isLoading = false;
      });
    } on SessionExpiredException {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(showSessionExpired: true),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading restaurants: $e')),
      );
    }
  }

  void _openRestaurantDetails(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetails(restaurant: restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Restaurants',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchRestaurant(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_restaurants.isEmpty) {
      return const Center(
        child: Text(
          'No restaurants found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        return _buildRestaurantCard(context, _restaurants[index]);
      },
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant) {
    final primaryImage = restaurant.images.isNotEmpty ? restaurant.images.first : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openRestaurantDetails(restaurant),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (primaryImage.isNotEmpty)
                Image.network(
                  primaryImage,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                )
              else
                Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          restaurant.price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.rating.toStringAsFixed(1)} (${restaurant.reviews})',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    if (restaurant.facilities.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: restaurant.facilities.take(3).map((facility) {
                          return Chip(
                            label: Text(
                              facility,
                              style: const TextStyle(fontSize: 12),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => _openRestaurantDetails(restaurant),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}