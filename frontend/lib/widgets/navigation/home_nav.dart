import 'package:flutter/material.dart';

/// Shared bottom navigation bar — defined ONCE here.
/// Uses named routes registered in main.dart so no screen
/// files need to be imported here, eliminating circular imports.
///
/// Named routes:
///   '/home'      → TravelHomePage
///   '/discover'  → DiscoverScreen
///   '/plan'      → FlightIntroScreen
///   '/community' → CommunityScreen2
///   '/profile'   → ProfileScreen
class HomeNav extends StatefulWidget {
  final int selectedIndex;

  const HomeNav({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  HomeNavState createState() => HomeNavState();
}

class HomeNavState extends State<HomeNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  /// Call via GlobalKey to sync the highlighted icon from a parent widget.
  void changeIndex(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, 'assets/home.png'),
              _navItem(1, 'assets/discover.png'),
              const SizedBox(width: 60), // space for center button
              _navItem(3, 'assets/community.png'),
              _navItem(4, 'assets/user.png'),
            ],
          ),
        ),
        Positioned(
          bottom: 5,
          child: MainNavButton(
            onTap: () => Navigator.pushNamed(context, '/plan'),
          ),
        ),
      ],
    );
  }

  Widget _navItem(int index, String iconPath) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (_) => false);
            break;
          case 1:
            Navigator.pushNamed(context, '/discover');
            break;
          case 3:
            Navigator.pushNamed(context, '/community');
            break;
          case 4:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ImageIcon(
          AssetImage(iconPath),
          size: 36,
          color: isSelected ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}

/// Floating center button in the navigation bar.
class MainNavButton extends StatelessWidget {
  final VoidCallback onTap;

  const MainNavButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.cyan,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            'assets/icon_nav.png',
            width: 42,
            height: 42,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}