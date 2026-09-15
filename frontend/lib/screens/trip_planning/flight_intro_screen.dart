import 'package:flutter/material.dart';
import 'location_setup_screen.dart';

class FlightIntroScreen extends StatelessWidget {
  const FlightIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('assets/plane_trip1.png', width: 320),
                            Image.asset('assets/plane_trip2.png', width: 320),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "It look like you did not\nplan your trip yet",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5C6BC0),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "You Can Create Your Own Trip Plan Now",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: Color(0xFF8C9BAB)),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 130,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LocationSetupScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "START NOW",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}