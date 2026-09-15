import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/home/home_feed_screen.dart';
import 'screens/home/travel_home_screen.dart';
import 'screens/home/discover_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/trip_planning/flight_intro_screen.dart';
//import 'screens/notifications/notifications_screen.dart';
//import 'screens/admin/admin_dashboard_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
      routes: {
        '/home':          (_) => const TravelHomePage(),
        '/discover':      (_) => DiscoverScreen(),
        '/community':     (_) => const HomeScreen(),
        '/profile':       (_) => const ProfileScreen(),
        '/plan':          (_) => const FlightIntroScreen(),
        //'/notifications': (_) => const NotificationsScreen(),
        //'/admin':         (_) => const AdminDashboard(),
      },
    );
  }
}