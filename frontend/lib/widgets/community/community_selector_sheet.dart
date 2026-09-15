import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class CommunitySelectorSheet extends StatefulWidget {
  final String? selectedCommunityId;

  const CommunitySelectorSheet({super.key, required this.selectedCommunityId});

  @override
  State<CommunitySelectorSheet> createState() => _CommunitySelectorSheetState();
}

class _CommunitySelectorSheetState extends State<CommunitySelectorSheet> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadCommunities();
  }

  Future<List<Map<String, dynamic>>> _loadCommunities() async {
    final communities = await CommunityService.getMine();

    final mapped = communities.map((item) => Map<String, dynamic>.from(item as Map)).toList();

    return mapped.where((community) {
      final status = community['status']?.toString().toLowerCase() ?? 'active';
      return status == 'active';
    }).toList();
  }

  Future<void> _retry() async {
    setState(() => _future = _loadCommunities());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Choose a community', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: _buildList(),
            ),
            const SizedBox(height: 6),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load your communities.', textAlign: TextAlign.center),
                const SizedBox(height: 10),
                TextButton(onPressed: _retry, child: const Text('Try again')),
              ],
            ),
          );
        }

        final communities = snapshot.data ?? [];

        if (communities.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text("You haven't joined any communities yet.", textAlign: TextAlign.center),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: communities.length,
          itemBuilder: (context, index) => _buildTile(context, communities[index]),
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, Map<String, dynamic> community) {
    final communityId = (community['communityId'] ?? community['id'])?.toString() ?? '';
    final name = community['name']?.toString() ?? 'Community';
    final cover = community['coverImage']?.toString();
    final selected = widget.selectedCommunityId == communityId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEAF3FF),
        backgroundImage: cover != null && cover.isNotEmpty ? NetworkImage(cover) : null,
        child: cover == null || cover.isEmpty
            ? const Icon(Icons.groups_rounded, color: Color(0xFF1976D2))
            : null,
      ),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: selected ? const Icon(Icons.check_circle) : null,
      onTap: communityId.isEmpty ? null : () => Navigator.of(context).pop(communityId),
    );
  }
}