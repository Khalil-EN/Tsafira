import 'package:flutter/material.dart';


class PremiumUpgradeScreen extends StatelessWidget {
  const PremiumUpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrade to Premium'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Unlock Unlimited Suggestions!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Upgrade to Premium to enjoy unlimited plan suggestions, personalized recommendations, and more.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {

              },
              child: Text('Upgrade Now'),
            ),
          ],
        ),
      ),
    );
  }
}
