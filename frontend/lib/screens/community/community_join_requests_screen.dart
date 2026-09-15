import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class CommunityJoinRequestsScreen extends StatefulWidget {
  final String communityId;

  const CommunityJoinRequestsScreen({
    super.key,
    required this.communityId,
  });

  @override
  State<CommunityJoinRequestsScreen> createState() =>
      _CommunityJoinRequestsScreenState();
}

class _CommunityJoinRequestsScreenState
    extends State<CommunityJoinRequestsScreen> {
  static const Color _navy = Color(0xFF18335A);

  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = [];
  final Set<String> _busyUserIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final requests =
      await CommunityService.getPendingRequests(widget.communityId);
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load join requests.')),
      );
    }
  }

  String _userId(Map<String, dynamic> request) {
    final user = request['user'];
    if (user is Map) {
      return (user['_id'] ?? user['id']).toString();
    }
    return request['userId']?.toString() ?? '';
  }

  Future<void> _respond(String userId, {required bool approve}) async {
    setState(() => _busyUserIds.add(userId));
    try {
      if (approve) {
        await CommunityService.approveMember(
          communityId: widget.communityId,
          userId: userId,
        );
      } else {
        await CommunityService.rejectMember(
          communityId: widget.communityId,
          userId: userId,
        );
      }
      if (!mounted) return;
      setState(() {
        _requests.removeWhere((r) => _userId(r) == userId);
        _busyUserIds.remove(userId);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyUserIds.remove(userId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not ${approve ? "approve" : "reject"} request.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join requests'),
        foregroundColor: _navy,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(
        child: Text(
          'No pending requests.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _requests.length,
          itemBuilder: (_, index) {
            final request = _requests[index];
            final userId = _userId(request);
            final user = request['user'] is Map
                ? Map<String, dynamic>.from(request['user'] as Map)
                : request;
            final name =
            '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                .trim();
            final busy = _busyUserIds.contains(userId);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(name.isEmpty ? 'Unknown user' : name),
                trailing: busy
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _respond(userId, approve: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _respond(userId, approve: false),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}