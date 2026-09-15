import 'package:flutter/material.dart';

import '../../widgets/navigation/app_menu.dart';
import '../../widgets/navigation/home_nav.dart';

class TravelHomePage extends StatefulWidget {
  const TravelHomePage({Key? key}) : super(key: key);

  @override
  _TravelHomePageState createState() => _TravelHomePageState();
}

class _TravelHomePageState extends State<TravelHomePage> {
  bool _showProfileMenu = false;

  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: HomeNav(selectedIndex: _navIndex),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Section ──
                  SizedBox(
                    height: 380,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/montain.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          // Top bar
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() =>
                                  _showProfileMenu = !_showProfileMenu),
                                  child: const Icon(Icons.person_outline,
                                      color: Colors.white, size: 28),
                                ),
                                const Icon(Icons.search,
                                    color: Colors.white, size: 28),
                              ],
                            ),
                          ),
                          // Hero text
                          const Positioned(
                            top: 70,
                            left: 16,
                            right: 16,
                            child: Text(
                              'EXPLORE\nTHE BEAUTY\nOF MOROCCO\nAROUND YOU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Action bar
                          Positioned(
                            bottom: 20,
                            left: 16,
                            right: 16,
                            child: Container(
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionButton(
                                    'EXPLORE',
                                    'assets/Explore.png',
                                    onTap: () {
                                      setState(() => _navIndex = 1);
                                      Navigator.pushNamed(
                                          context, '/discover');
                                    },
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  _buildActionButton(
                                    'PLAN TRIP',
                                    'assets/location.png',
                                    onTap: () {
                                      setState(() => _navIndex = 2);
                                      Navigator.pushNamed(context, '/plan');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Discover Section ──
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Discover',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDiscoverCard(
                                  'Parki El Hamadi',
                                  'Tetouan',
                                  'assets/parki.jpg'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDiscoverCard(
                                  'Jamaa El Fna',
                                  'Marrakech',
                                  'assets/jama3.jpg'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Most Popular ──
                        const Text(
                          'Most Popular',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: const AssetImage('assets/esaouira.jpg'),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.purple.shade100.withOpacity(0.7),
                                BlendMode.srcATop,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Essaouira',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text('Morocco',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text('4.8',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile menu overlay
          if (_showProfileMenu)
            AppMenu(
              onClose: () =>
                  setState(() => _showProfileMenu = false),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, String iconPath,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath,
              width: 28, height: 28, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCard(
      String title, String? location, String imagePath) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
            image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7)
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            if (location != null)
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.white70, size: 12),
                  const SizedBox(width: 4),
                  Text(location,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}