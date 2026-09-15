// lib/screens/activities/activities_page.dart

import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../exceptions/session_expired_exception.dart';
import '../../services/api_services.dart';

import '../auth/login_screen.dart';
import 'activity_details_page.dart';
import 'search_activities_page.dart';

class ActivitiesPage extends StatefulWidget {
  final bool isFromSearch;
  final List<String>? activityTypes;
  final DateTime? date;
  final String location;
  final TimeOfDay? time;
  final int participants;
  final bool freeOnly;
  final List<String>? ageGroups;
  final List<String>? specialRequirements;

  const ActivitiesPage({
    Key? key,
    this.isFromSearch = false,
    this.location = '',
    this.activityTypes,
    this.date,
    this.time,
    this.participants = 0,
    this.specialRequirements,
    this.ageGroups,
    this.freeOnly = false,
  }) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      dynamic loadedData;

      if (widget.isFromSearch) {
        final searchData = {
          'date': widget.date,
          'time': widget.time,
          'freeOnly': widget.freeOnly,
          'location': widget.location,
          'activityTypes': widget.activityTypes,
          'specialRequirements': widget.specialRequirements,
          'ageGroups': widget.ageGroups,
          'participants': widget.participants,
        };
        loadedData = await SearchService.searchActivities(searchData);
      } else {
        loadedData = await ActivityService.getAll();
      }

      if (!mounted) return;

      setState(() {
        _activities = _parseActivities(loadedData);
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
        SnackBar(
          content: Text('Error loading activities: $e'),
        ),
      );
    }
  }

  List<Activity> _parseActivities(dynamic data) {
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => Activity.fromJson(json))
        .toList();
  }

  void _openActivityDetails(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailsPage(activity: activity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Activities',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchActivitiesPage(),
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

    if (_activities.isEmpty) {
      return const Center(
        child: Text(
          'No activities found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        return _buildActivityCard(_activities[index]);
      },
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openActivityDetails(activity),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: activity.imageUrl.isEmpty
                  ? _buildImagePlaceholder(Icons.local_activity)
                  : Image.network(
                activity.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(Icons.broken_image),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(activity.location, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(activity.type.isNotEmpty ? activity.type : 'General'),
                        backgroundColor: const Color(0xFFEAF2FF),
                        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      ElevatedButton(
                        onPressed: () => _openActivityDetails(activity),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Book Now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(IconData icon) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey.shade200,
      child: Center(child: Icon(icon, size: 60, color: Colors.grey)),
    );
  }
}