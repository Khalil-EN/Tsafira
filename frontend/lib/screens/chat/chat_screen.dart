import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/api_services.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/empty_state.dart';

class ChatScreen extends StatefulWidget {

  final String conversationId;
  final String title;
  final String currentUserId;
  final String? profilePicture;

  final bool isAI;


  const ChatScreen({
    super.key,

    required this.conversationId,
    required this.title,
    required this.currentUserId,

    this.profilePicture,

    this.isAI = false,
  });


  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {

  static const Color _blue =
  Color(0xFF1976D2);

  static const Color _navy =
  Color(0xFF18335A);

  static const Color _background =
  Color(0xFFF2F5F8);

  final TextEditingController
  _messageController =
  TextEditingController();

  final ScrollController
  _scrollController =
  ScrollController();

  List<Map<String, dynamic>>
  _messages = [];

  bool _loading = true;
  bool _sending = false;
  bool _hasInitialLoad = false;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _loadMessages(
      showLoader: true,
      scrollToBottom: true,
    );

    _refreshTimer =
        Timer.periodic(
          const Duration(seconds: 3),
              (_) {
            _loadMessages(
              showLoader: false,
              scrollToBottom: false,
            );
          },
        );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();

    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Widget _buildHeaderAvatar() {
    return AppAvatar(
      source: widget.profilePicture,
      name: widget.title,
      radius: 18,
    );
  }

  // ==========================================================================
  // LOAD MESSAGES
  // ==========================================================================

  Future<void> _loadMessages({
    bool showLoader = false,
    bool scrollToBottom = false,
  }) async {
    if (showLoader && mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final messages =
      await MessagingService.getMessages(
        conversationId:
        widget.conversationId,
      );

      messages.sort(
            (a, b) {
          final dateA =
          DateTime.tryParse(
            a['createdAt']
                ?.toString() ??
                '',
          );

          final dateB =
          DateTime.tryParse(
            b['createdAt']
                ?.toString() ??
                '',
          );

          if (dateA == null ||
              dateB == null) {
            return 0;
          }

          return dateA.compareTo(
            dateB,
          );
        },
      );

      if (!mounted) return;

      final wasAtBottom =
      _isNearBottom();

      final messageCountChanged =
          messages.length !=
              _messages.length;

      setState(() {
        _messages = messages;
        _loading = false;
        _hasInitialLoad = true;
      });

      if (scrollToBottom ||
          (!wasAtBottom &&
              !messageCountChanged)) {
        return;
      }

      if (scrollToBottom ||
          wasAtBottom ||
          !_hasInitialLoad) {
        WidgetsBinding.instance
            .addPostFrameCallback(
              (_) => _scrollToBottom(
            animated: scrollToBottom,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      debugPrint(
        'Error loading messages: $e',
      );

      if (!_hasInitialLoad) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to load messages.',
            ),
          ),
        );
      }
    }
  }

  // ==========================================================================
  // SEND
  // ==========================================================================

  Future<void> _sendMessage() async {

    final text =
    _messageController.text.trim();


    if (
    text.isEmpty ||
        _sending
    ) {
      return;
    }


    setState(() {
      _sending = true;
    });


    try {

      if (widget.isAI) {

        await AIChatService.sendMessage(
          conversationId:
          widget.conversationId,

          message:
          text,
        );

      } else {

        await MessagingService.sendMessage(
          conversationId:
          widget.conversationId,

          content:
          text,
        );
      }


      _messageController.clear();


      await _loadMessages(
        showLoader: false,
        scrollToBottom: true,
      );


    } catch (e) {

      debugPrint(
          'Error sending message: $e'
      );


      if (!mounted) {
        return;
      }


      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            widget.isAI
                ? 'Failed to contact the AI assistant.'
                : 'Failed to send message.',
          ),
        ),
      );


    } finally {

      if (!mounted) {
        return;
      }


      setState(() {
        _sending = false;
      });
    }
  }

  // ==========================================================================
  // SCROLLING
  // ==========================================================================

  bool _isNearBottom() {
    if (!_scrollController
        .hasClients) {
      return true;
    }

    final position =
        _scrollController.position;

    return position.maxScrollExtent -
        position.pixels <
        120;
  }

  void _scrollToBottom({
    bool animated = true,
  }) {
    if (!_scrollController
        .hasClients) {
      return;
    }

    final target =
        _scrollController
            .position
            .maxScrollExtent;

    if (animated) {
      _scrollController.animateTo(
        target,
        duration:
        const Duration(
          milliseconds: 250,
        ),
        curve:
        Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(
        target,
      );
    }
  }

  // ==========================================================================
  // MESSAGE DATA
  // ==========================================================================

  String _getSenderId(
      Map<String, dynamic> message,
      ) {
    final sender =
    message['sender'];

    if (sender is Map) {
      return (
          sender['id'] ??
              sender['_id']
      )?.toString() ??
          '';
    }

    return sender?.toString() ??
        '';
  }

  String _getSenderName(
      Map<String, dynamic> message,
      ) {
    final sender =
    message['sender'];

    if (sender is Map) {
      final firstName =
          sender['firstName']
              ?.toString() ??
              '';

      final lastName =
          sender['lastName']
              ?.toString() ??
              '';

      final name =
      '$firstName $lastName'
          .trim();

      return name.isEmpty
          ? 'User'
          : name;
    }

    return 'User';
  }

  String? _getProfilePicture(
      Map<String, dynamic> message,
      ) {
    final sender =
    message['sender'];

    if (sender is Map) {
      final value =
      sender['profilePicture']
          ?.toString();

      if (value != null &&
          value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String _getInitial(
      String name,
      ) {
    if (name.trim().isEmpty) {
      return '?';
    }

    return name
        .trim()
        .substring(0, 1)
        .toUpperCase();
  }

  String _getTime(
      Map<String, dynamic> message,
      ) {
    final raw =
    message['createdAt']
        ?.toString();

    if (raw == null ||
        raw.isEmpty) {
      return '';
    }

    final date =
    DateTime.tryParse(raw);

    if (date == null) {
      return '';
    }

    final local =
    date.toLocal();

    final hour =
    local.hour
        .toString()
        .padLeft(2, '0');

    final minute =
    local.minute
        .toString()
        .padLeft(2, '0');

    return '$hour:$minute';
  }

  // ==========================================================================
  // AVATAR
  // ==========================================================================

  Widget _buildAvatar({
    required String name,
    required String? profilePicture,
  }) {
    return AppAvatar(source: profilePicture, name: name, radius: 18);
  }

  // ==========================================================================
  // MESSAGE BUBBLE
  // ==========================================================================

  Widget _buildMessage(
      Map<String, dynamic> message,
      ) {
    final senderId = _getSenderId(message);

    final isMe =
        senderId.isNotEmpty &&
            senderId == widget.currentUserId;

    final text =
        message['content']?.toString() ?? '';

    final senderName =
    _getSenderName(message);

    final profilePicture =
    _getProfilePicture(message);

    final time =
    _getTime(message);

    // --------------------------------------------------------------------------
    // MY MESSAGE
    // --------------------------------------------------------------------------

    if (isMe) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 70,
          right: 12,
          top: 5,
          bottom: 5,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 330,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 11,
              ),
              decoration: const BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(19),
                  topRight: Radius.circular(19),
                  bottomLeft: Radius.circular(19),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        height: 1.35,
                      ),
                    ),
                  ),

                  if (time.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // --------------------------------------------------------------------------
    // INCOMING MESSAGE
    // --------------------------------------------------------------------------

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 70,
        top: 5,
        bottom: 5,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        mainAxisAlignment:
        MainAxisAlignment.start,
        children: [
          // Avatar
          _buildAvatar(
            name: senderName,
            profilePicture: profilePicture,
          ),

          const SizedBox(width: 9),

          // Name + message
          Flexible(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------------------
                // USER NAME
                // --------------------------------------------------------------

                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    bottom: 4,
                  ),
                  child: Text(
                    senderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // --------------------------------------------------------------
                // MESSAGE BUBBLE
                // --------------------------------------------------------------

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(19),
                      topRight: Radius.circular(19),
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(19),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Color(0xFF202A35),
                            fontSize: 15.5,
                            height: 1.35,
                          ),
                        ),
                      ),

                      if (time.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10.5,
                            ),
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
    );
  }

  // ==========================================================================
  // EMPTY STATE
  // ==========================================================================

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'No messages yet',
      subtitle: 'Send the first message.',
      topSpacing: 100,
    );
  }

  // ==========================================================================
  // INPUT
  // ==========================================================================

  Widget _buildMessageInput() {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.07),
            blurRadius: 14,
            offset:
            const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints:
                const BoxConstraints(
                  maxHeight: 130,
                ),
                decoration:
                BoxDecoration(
                  color:
                  const Color(0xFFF3F5F7),
                  borderRadius:
                  BorderRadius.circular(
                    22,
                  ),
                ),
                child: TextField(
                  controller:
                  _messageController,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction:
                  TextInputAction.newline,
                  decoration:
                  const InputDecoration(
                    hintText:
                    'Write a message...',
                    border:
                    InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Material(
              color: _blue,
              shape:
              const CircleBorder(),
              child: InkWell(
                customBorder:
                const CircleBorder(),
                onTap: _sending
                    ? null
                    : _sendMessage,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: _sending
                        ? const SizedBox(
                      width: 21,
                      height: 21,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<
                            Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Icon(
                      Icons
                          .arrow_upward_rounded,
                      color:
                      Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      _background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        Colors.white,
        foregroundColor:
        _navy,

        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 21,
          ),
          onPressed: () =>
              Navigator.pop(context),
        ),

        titleSpacing: 0,

        title: Row(
          children: [
            _buildHeaderAvatar(),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                : RefreshIndicator(
              onRefresh: () =>
                  _loadMessages(
                    showLoader: false,
                    scrollToBottom: false,
                  ),
              child:
              _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller:
                _scrollController,
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding:
                const EdgeInsets.fromLTRB(
                  0,
                  14,
                  0,
                  18,
                ),
                itemCount:
                _messages.length,
                itemBuilder:
                    (_, index) =>
                    _buildMessage(
                      _messages[index],
                    ),
              ),
            ),
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }
}