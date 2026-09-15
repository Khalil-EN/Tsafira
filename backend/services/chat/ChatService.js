const ConversationDAO =
  require("../../dao/conversationDAO");

const MessageDAO =
  require("../../dao/messageDAO");

const ChatAssembler =
  require("./ChatAssembler");

const ChatService = {

  // ─────────────────────────────────────────────────────────────
  // Inbox
  // ─────────────────────────────────────────────────────────────

  async getInbox(
    userId,
    page = 1,
    limit = 20
  ) {
    const conversations =
      await ConversationDAO.getUserConversations(
        userId,
        page,
        limit
      );

    return ChatAssembler.toConversationDTOs(
      conversations,
      userId
    );
  },

  // ─────────────────────────────────────────────────────────────
  // Messages
  // ─────────────────────────────────────────────────────────────

  async getMessages(
    userId,
    conversationId,
    page = 1,
    limit = 30
  ) {
    const exists =
      await ConversationDAO.exists(
        conversationId
      );

    if (!exists) {
      throw new Error(
        "Conversation not found."
      );
    }

    const isParticipant =
      await ConversationDAO.isParticipant(
        conversationId,
        userId
      );

    if (!isParticipant) {
      throw new Error(
        "You are not allowed to access this conversation."
      );
    }

    const messages =
      await MessageDAO.getMessages(
        conversationId,
        page,
        limit
      );

    /*
     * Opening/loading the conversation means
     * the user has seen the latest message.
     */
    await ConversationDAO.markAsRead(
      conversationId,
      userId
    );

    return ChatAssembler.toMessageDTOs(
      messages
    );
  },

  // ─────────────────────────────────────────────────────────────
  // Explicit mark as read
  // ─────────────────────────────────────────────────────────────

  async markConversationAsRead(
    userId,
    conversationId
  ) {
    const exists =
      await ConversationDAO.exists(
        conversationId
      );

    if (!exists) {
      throw new Error(
        "Conversation not found."
      );
    }

    const isParticipant =
      await ConversationDAO.isParticipant(
        conversationId,
        userId
      );

    if (!isParticipant) {
      throw new Error(
        "You are not allowed to access this conversation."
      );
    }

    await ConversationDAO.markAsRead(
      conversationId,
      userId
    );
  },

  // ─────────────────────────────────────────────────────────────
  // Send
  // ─────────────────────────────────────────────────────────────

  async sendMessage(
    senderId,
    conversationId,
    content
  ) {
    if (
      !content ||
      !content.trim()
    ) {
      throw new Error(
        "Message content cannot be empty."
      );
    }

    const exists =
      await ConversationDAO.exists(
        conversationId
      );

    if (!exists) {
      throw new Error(
        "Conversation not found."
      );
    }

    const isParticipant =
      await ConversationDAO.isParticipant(
        conversationId,
        senderId
      );

    if (!isParticipant) {
      throw new Error(
        "You are not a participant of this conversation."
      );
    }

    const cleanContent =
      content.trim();

    const message =
      await MessageDAO.createMessage({
        conversation:
          conversationId,
        sender:
          senderId,
        content:
          cleanContent,
      });

    await ConversationDAO.updateLastMessage(
      conversationId,
      {
        content: cleanContent,
        senderId,
      }
    );

    return ChatAssembler.toMessageDTO(
      message
    );
  },

  // ─────────────────────────────────────────────────────────────
  // Direct chat
  // ─────────────────────────────────────────────────────────────

  async getOrCreateDirectChat(
    userId,
    participantId
  ) {
    if (
      userId.toString() ===
      participantId.toString()
    ) {
      throw new Error(
        "You cannot create a conversation with yourself."
      );
    }

    const existing =
      await ConversationDAO.findDirectConversation(
        userId,
        participantId
      );

    if (existing) {
      return ChatAssembler.toConversationDTO(
        existing,
        userId
      );
    }

    const conversation =
      await ConversationDAO.createConversation({
        type: "direct",
        participants: [
          userId,
          participantId,
        ],
      });

    return ChatAssembler.toConversationDTO(
      conversation,
      userId
    );
  },

  async deleteDirectConversationsForUser(userId) {
    return await ConversationDAO.deleteDirectConversationsForUser(
      userId
    );
  },

  async deleteAIConversationForUser(userId){
    return await ConversationDAO.deleteAIConversationForUser(
      userId
    );
  }
};

module.exports = ChatService;