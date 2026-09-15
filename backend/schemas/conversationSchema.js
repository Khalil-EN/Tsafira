const mongoose = require("mongoose");

const conversationSchema = new mongoose.Schema(
  {
    participants: {
      type: [
        {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
      ],
      required: true,

      validate: {
        validator(participants) {
          if (this.type === "ai") {
            return participants.length === 1;
          }

          return participants.length >= 2;
        },

        message:
          "A conversation must contain the required number of participants.",
      },
    },

    type: {
      type: String,
      enum: ["direct", "group", "ai"],
      default: "direct",
      required: true,
    },

    lastMessage: {
      type: String,
      default: "",
      trim: true,
      maxlength: 1000,
    },

    lastMessageAt: {
      type: Date,
      default: Date.now,
    },

    /*
     * User who sent the current last message.
     */
    lastMessageSender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    /*
     * Users who have read the current last message.
     *
     * Whenever a new message is sent, this is reset to [sender].
     *
     * When another participant opens the conversation,
     * their ID is added here.
     */
    lastMessageReadBy: {
      type: [
        {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
      ],
      default: [],
    },
  },
  {
    timestamps: true,
  }
);

conversationSchema.index({
  participants: 1,
});

conversationSchema.index({
  lastMessageAt: -1,
});

conversationSchema.index({
  type: 1,
  participants: 1,
});

module.exports = mongoose.model(
  "Conversation",
  conversationSchema
);