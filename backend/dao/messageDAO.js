const Message = require("../schemas/messageSchema");

const MessageDAO = {

  /*
  |--------------------------------------------------------------------------
  | Read
  |--------------------------------------------------------------------------
  */

  async getMessages(conversationId, page = 1, limit = 30) {
    return await Message.find({
      conversation: conversationId,
      deleted: false,
    })
      .populate(
        "sender",
        "firstName lastName profilePicture"
      )
      .sort({
        createdAt: 1,
      })
      .skip((page - 1) * limit)
      .limit(limit)
      .lean();
  },

  async getById(messageId) {
    return await Message.findById(messageId)
      .populate(
        "sender",
        "firstName lastName profilePicture"
      );
  },

  async getLastMessage(conversationId) {
    return await Message.findOne({
      conversation: conversationId,
      deleted: false,
    })
      .sort({
        createdAt: -1,
      })
      .populate(
        "sender",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  async getRecentMessages(
    conversationId,
    limit = 20
  ) {
    const messages =
      await Message.find({
        conversation: conversationId,
        deleted: false,
      })
        .populate(
          "sender",
          "firstName lastName profilePicture"
        )
        .sort({
          createdAt: -1,
        })
        .limit(limit)
        .lean();

    return messages.reverse();
  },

  /*
  |--------------------------------------------------------------------------
  | Create
  |--------------------------------------------------------------------------
  */

  async createMessage(data) {
    const message = await Message.create(data);

    return await Message.findById(message._id)
      .populate(
        "sender",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  /*
  |--------------------------------------------------------------------------
  | Update
  |--------------------------------------------------------------------------
  */

  async updateMessage(messageId, updates) {
    return await Message.findByIdAndUpdate(
      messageId,
      updates,
      {
        new: true,
      }
    );
  },

  /*
  |--------------------------------------------------------------------------
  | Soft delete
  |--------------------------------------------------------------------------
  */

  async deleteMessage(messageId) {
    return await Message.findByIdAndUpdate(
      messageId,
      {
        deleted: true,
      },
      {
        new: true,
      }
    );
  },

};

module.exports = MessageDAO;