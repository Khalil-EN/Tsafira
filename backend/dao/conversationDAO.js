const Conversation = require("../schemas/conversationSchema");

const ConversationDAO = {

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
        lastMessageReadBy: [senderId],
      },
      {
        new: true,
      }
    );
  },

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

  async isUnreadForUser(
    conversationId,
    userId
  ) {
    const conversation =
      await Conversation.findOne({
        _id: conversationId,
        participants: userId,
        lastMessageSender: {
          $ne: userId,
        },
        lastMessageReadBy: {
          $ne: userId,
        },
      }).select("_id");

    return !!conversation;
  },

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