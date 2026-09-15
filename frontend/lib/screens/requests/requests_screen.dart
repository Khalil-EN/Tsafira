import 'package:flutter/material.dart';

import '../../services/api_services.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/empty_state.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({
    super.key,
  });

  @override
  State<RequestsScreen> createState() =>
      _RequestsScreenState();
}

class _RequestsScreenState
    extends State<RequestsScreen> {
  bool isLoading = true;

  List<Map<String, dynamic>>
  receivedRequests = [];

  List<Map<String, dynamic>>
  sentRequests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final results =
      await RequestService.getRequests();

      if (!mounted) return;

      setState(() {
        receivedRequests =
        List<Map<String, dynamic>>.from(
          results['received'] ?? [],
        );

        sentRequests =
        List<Map<String, dynamic>>.from(
          results['sent'] ?? [],
        );

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load requests: $e',
          ),
        ),
      );
    }
  }

  Future<void> _handleAccept(
      Map<String, dynamic> request,
      ) async {
    try {
      final requestId =
      request['requestId'];

      if (requestId == null) {
        throw Exception(
          'Request ID is missing.',
        );
      }

      await RequestService.acceptRequest(
        requestId.toString(),
      );

      if (!mounted) return;

      await _loadRequests();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to accept request: $e',
          ),
        ),
      );
    }
  }

  Future<void> _handleReject(
      Map<String, dynamic> request,
      ) async {
    try {
      final requestId =
      request['requestId'];

      if (requestId == null) {
        throw Exception(
          'Request ID is missing.',
        );
      }

      await RequestService.rejectRequest(
        requestId.toString(),
      );

      if (!mounted) return;

      await _loadRequests();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to reject request: $e',
          ),
        ),
      );
    }
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final isFriend = request['type'] == 'friend';
    final person = request['from'] ?? request['to'] ?? {};

    final name = person['fullName']?.toString() ??
        '${person['firstName'] ?? ''} ${person['lastName'] ?? ''}'.trim();

    final displayName = name.trim().isEmpty ? 'Unknown user' : name.trim();
    final profilePicture = person['profilePicture'] ?? person['avatar'];

    final subtitle = isFriend
        ? 'Wants to connect with you'
        : 'Invited you to join a community';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            AppAvatar(source: profilePicture, name: displayName, radius: 25),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _roundActionButton(
                  icon: Icons.close_rounded,
                  background: const Color(0xFFFFEBEE),
                  foreground: const Color(0xFFD32F2F),
                  onPressed: () => _handleReject(request),
                ),
                const SizedBox(width: 6),
                _roundActionButton(
                  icon: Icons.check_rounded,
                  background: const Color(0xFFE8F5E9),
                  foreground: const Color(0xFF2E7D32),
                  onPressed: () => _handleAccept(request),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundActionButton({
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: background,
      shape:
      const CircleBorder(),
      child: InkWell(
        customBorder:
        const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color: foreground,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
      String title,
      int count,
      ) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        2,
        18,
        2,
        10,
      ),
      child: Row(
        children: [
          Text(
            title,
            style:
            const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            _badge(count),
          ],
        ],
      ),
    );
  }

  Widget _badge(int count) {
    return Container(
      constraints:
      const BoxConstraints(
        minWidth: 24,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(0xFFD32F2F),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        count > 99
            ? '99+'
            : count.toString(),
        textAlign:
        TextAlign.center,
        style:
        const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF4F7FA),

      appBar: AppBar(
        backgroundColor:
        Colors.white,
        foregroundColor:
        const Color(0xFF18335A),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh:
        _loadRequests,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            30,
          ),
          children: [
            _sectionHeader(
              'Received requests',
              receivedRequests.length,
            ),

            if (receivedRequests.isEmpty)
              const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No new requests',
              )
            else
              ...receivedRequests.map(
                _buildRequestCard,
              ),

            _sectionHeader(
              'Sent requests',
              sentRequests.length,
            ),

            if (sentRequests.isEmpty)
              const EmptyState(
                icon: Icons.send_outlined,
                title: 'No pending sent requests',
              )
            else
              ...sentRequests.map(
                    (request) =>
                    _sentRequestCard(
                      request,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sentRequestCard(
      Map<String, dynamic> request,
      ) {
    final isCommunity =
        request['type'] == 'community';

    final rawTarget =
    request['to'];

    final target =
    rawTarget is Map
        ? Map<String, dynamic>.from(rawTarget)
        : <String, dynamic>{};

    String name;

    if (isCommunity) {
      name =
          target['name']
              ?.toString()
              .trim() ??
              'Community';

      if (name.isEmpty) {
        name = 'Community';
      }
    } else {
      final fullName =
      target['fullName']
          ?.toString()
          .trim();

      name =
      fullName != null &&
          fullName.isNotEmpty
          ? fullName
          : 'Unknown user';
    }

    return Container(
      margin:
      const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.035),
            blurRadius: 10,
            offset:
            const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),

        leading: isCommunity
            ? AppAvatar(source: null, name: '', isCommunity: true, radius: 22)
            : AppAvatar(
          source: target['profilePicture'] ?? target['avatar'],
          name: name,
          radius: 22,
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),

        subtitle: Text(
          isCommunity
              ? 'Join request pending'
              : 'Friend request pending',
        ),
      ),
    );
  }
}