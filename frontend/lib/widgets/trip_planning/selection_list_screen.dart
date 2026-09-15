import 'package:flutter/material.dart';

class SelectionListScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<List<Map<String, dynamic>>> Function() fetcher;
  final void Function(String name) onSelect;

  const SelectionListScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.fetcher,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetcher(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return Center(child: Text('No results available'));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final name = results[index]['name']?.toString() ?? 'Unnamed';
              return ListTile(
                leading: Icon(icon, color: Colors.blue),
                title: Text(name),
                onTap: () {
                  onSelect(name);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}