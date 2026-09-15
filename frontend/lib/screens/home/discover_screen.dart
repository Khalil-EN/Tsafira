import 'package:flutter/material.dart';

import '../residences/residence_list.dart';
import '../restaurants/restaurants_page.dart';
import '../activities/activities_page.dart';
import '../../widgets/navigation/home_nav.dart';

class DiscoverScreen extends StatelessWidget {
  final List<DiscoverItem> discoveryItems = [
    DiscoverItem(
      title: 'HOTEL',
      iconPath: 'assets/hotel_logo.png',
      colors: [const Color(0xFF71BBFF), const Color(0xFFDB76FF)],
      onTap: (context) => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ResidencesPage())),
    ),
    DiscoverItem(
      title: 'RESTAURANT',
      iconPath: 'assets/restaurant_logo.png',
      colors: [const Color(0xFF56E79F), const Color(0xFF4093E7)],
      onTap: (context) => Navigator.push(
          context, MaterialPageRoute(builder: (_) => RestaurantsPage())),
    ),
    DiscoverItem(
      title: 'Activities',
      iconPath: 'assets/Advanture.png',
      colors: [
        const Color.fromARGB(223, 253, 5, 211),
        const Color(0xFFAC56EA)
      ],
      onTap: (context) => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ActivitiesPage())),
    ),
    DiscoverItem(
      title: 'FLIGHTS',
      iconPath: 'assets/flight_logo.png',
      colors: [
        const Color.fromARGB(255, 230, 251, 0),
        const Color.fromARGB(255, 4, 199, 11)
      ],
      onTap: (context) => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ResidencesPage())),
    ),
    DiscoverItem(
      title: 'EVENTS',
      iconPath: 'assets/Events.png',
      colors: [
        const Color.fromARGB(255, 229, 134, 1),
        const Color.fromARGB(255, 240, 21, 5),
      ],
      onTap: (context) => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ResidencesPage())),
    ),
  ];

  DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Discover',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 20),
                itemCount: discoveryItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _buildDiscoverItem(context, discoveryItems[index]),
              ),
            ),
            // Uses shared HomeNav; selectedIndex = 1 for Discover
            const HomeNav(selectedIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverItem(BuildContext context, DiscoverItem item) {
    return GestureDetector(
      onTap: () => item.onTap(context),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: item.colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          image: DecorationImage(
            image: const AssetImage('assets/back2.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.03),
              BlendMode.dstATop,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              spreadRadius: 10,
              blurRadius: 100,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item.iconPath,
                width: 80, height: 80, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoverItem {
  final String title;
  final String iconPath;
  final List<Color> colors;
  final Function(BuildContext context) onTap;

  DiscoverItem({
    required this.title,
    required this.iconPath,
    required this.colors,
    required this.onTap,
  });
}