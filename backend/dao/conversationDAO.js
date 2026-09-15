const Conversation = require("../schemas/conversationSchema");

const ConversationDAO = {

  // ─────────────────────────────────────────────────────────────
  // Inbox
  // ─────────────────────────────────────────────────────────────

  async getUserConversations(
    userId,
    page = 1,
    limit = 20
  ) {
    return await Conversation.find({
      participants: userId,
    })
      .populate(
        "participants",
        "firstName lastName profilePicture"
      )
      .populate(
        "lastMessageSender",
        "firstName lastName profilePicture"
      )
      .sort({
        lastMessageAt: -1,
      })
      .skip((page - 1) * limit)
      .limit(limit)
      .lean();
  },

  // ─────────────────────────────────────────────────────────────
  // Conversation lookup
  // ─────────────────────────────────────────────────────────────

  async getById(conversationId) {
    return await Conversation.findById(
      conversationId
    )
      .populate(
        "participants",
        "firstName lastName profilePicture"
      )
      .populate(
        "lastMessageSender",
        "firstName lastName profilePicture"
      );
  },

  async exists(conversationId) {
    return await Conversation.exists({
      _id: conversationId,
    });
  },

  // ─────────────────────────────────────────────────────────────
  // Security
  // ─────────────────────────────────────────────────────────────

  async isParticipant(
    conversationId,
    userId
  ) {
    const conversation =
      await Conversation.findOne({
        _id: conversationId,
        participants: userId,
      }).select("_id");

    return !!conversation;
  },

  // ─────────────────────────────────────────────────────────────
  // Last message
  // ─────────────────────────────────────────────────────────────

  async updateLastMessage(
    conversationId,
    {
      content,
      senderId,
    }
  ) {
    return await Conversation.findByIdAndUpdate(
      conversationId,
      {
        lastMessage: content,
        lastMessageAt: new Date(),
        lastMessageSender: senderId,

        /*
         * The sender has obviously read their own message.
         * Nobody else has read it yet.
         */
        lastMessageReadBy: [senderId],
      },
      {
        new: true,
      }
    );
  },

  // ─────────────────────────────────────────────────────────────
  // Mark conversation as read
  // ─────────────────────────────────────────────────────────────

  async markAsRead(
    conversationId,
    userId
  ) {
    return await Conversation.findOneAndUpdate(
      {
        _id: conversationId,
        participants: userId,
      },
      {
        $addToSet: {
          lastMessageReadBy: userId,
        },
      },
      {
        new: true,
      }
    );
  },

  // ─────────────────────────────────────────────────────────────
  // Unread check
  // ─────────────────────────────────────────────────────────────

  async isUnreadForUser(
    conversationId,
    userId
  ) {
    const conversation =
      await Conversation.findOne({
        _id: conversationId,
        participants: userId,

        /*
         * Latest message must have been sent by
         * somebody other than the current user.
         */
        lastMessageSender: {
          $ne: userId,
        },

        /*
         * Current user must not have read it.
         */
        lastMessageReadBy: {
          $ne: userId,
        },
      }).select("_id");

    return !!conversation;
  },

  // ─────────────────────────────────────────────────────────────
  // Direct conversations
  // ─────────────────────────────────────────────────────────────

  async findDirectConversation(
    userId1,
    userId2
  ) {
    return await Conversation.findOne({
      type: "direct",
      participants: {
        $all: [
          userId1,
          userId2,
        ],
        $size: 2,
      },
    })
      .populate(
        "participants",
        "firstName lastName profilePicture"
      )
      .populate(
        "lastMessageSender",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  // ─────────────────────────────────────────────────────────────
  // Creation
  // ─────────────────────────────────────────────────────────────

  async createConversation(data) {
    const conversation =
      new Conversation(data);

    await conversation.save();

    return await Conversation.findById(
      conversation._id
    )
      .populate(
        "participants",
        "firstName lastName profilePicture"
      )
      .populate(
        "lastMessageSender",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  async deleteDirectConversationsForUser(userId) {
    return await Conversation.deleteMany({
      type: "direct",
      participants: userId,
    });
  },

  async findAIConversation(
    userId
  ) {
    return await Conversation.findOne({
      type: "ai",

      participants: {
        $all: [userId],
        $size: 1,
      },
    })
      .populate(
        "participants",
        "firstName lastName profilePicture"
      )
      .populate(
        "lastMessageSender",
        "firstName lastName profilePicture"
      )
      .lean();
  },


  async isAIConversation(
    conversationId,
    userId
  ) {
    const conversation =
      await Conversation.findOne({
        _id: conversationId,

        type: "ai",

        participants: userId,
      }).select("_id");

    return !!conversation;
  },

  async deleteAIConversationForUser(
    userId
  ) {
    return await Conversation.deleteMany({
      type: "ai",

      participants: userId,
    });
  },
};

module.exports = ConversationDAO;