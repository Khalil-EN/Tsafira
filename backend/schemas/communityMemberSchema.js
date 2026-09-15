const mongoose = require("mongoose");

const communityMemberSchema = new mongoose.Schema(
  {
    community: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Community",
      required: true,
      index: true,
    },

    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    role: {
      type: String,
      enum: [
        "member",
        "moderator",
        "admin",
        "owner",
      ],
      default: "member",
    },

    status: {
      type: String,
      enum: [
        "active",
        "pending",
        "banned",
      ],
      default: "active",
    },

    joinedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

communityMemberSchema.index(
  {
    community: 1,
    user: 1,
  },
  {
    unique: true,
  }
);

module.exports =
  mongoose.models.CommunityMember ||
  mongoose.model("CommunityMember", communityMemberSchema);