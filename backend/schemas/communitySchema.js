const mongoose = require("mongoose");

const communitySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    unique: true,
  },

  description: {
    type: String,
    default: "",
    trim: true,
  },

  coverImage: {
    type: String,
    default: null,
  },

  creator: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  owner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  privacy: {
    type: String,
    enum: [
      "public",
      "private",
    ],
    default: "public",
  },

  membersCount: {
    type: Number,
    default: 1,
    min: 0,
  },

  postsCount: {
    type: Number,
    default: 0,
    min: 0,
  },

  isActive: {
    type: Boolean,
    default: true,
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports =
  mongoose.models.Community ||
  mongoose.model(
    "Community",
    communitySchema
  );