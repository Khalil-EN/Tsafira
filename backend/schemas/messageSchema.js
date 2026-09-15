const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema(
  {
    conversation: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Conversation",
      required: true,
      index: true,
    },

    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: function () {
        return this.senderType === "user";
      },
      default: null,
    },

    senderType: {
      type: String,
      enum: [
        "user",
        "ai",
      ],
      default: "user",
      required: true,
    },

    content: {
      type: String,
      required: true,
      trim: true,
      maxlength: 5000,
    },

    type: {
      type: String,
      enum: ["text"],
      default: "text",
    },

    editedAt: {
      type: Date,
      default: null,
    },

    deleted: {
      type: Boolean,
      default: false,
    },
  },

  {
    timestamps: true,
  }
);

messageSchema.index({
  conversation: 1,
  createdAt: 1,
});

messageSchema.index({
  sender: 1,
});

messageSchema.index({
  content: "text",
});

module.exports = mongoose.model(
  "Message",
  messageSchema
);