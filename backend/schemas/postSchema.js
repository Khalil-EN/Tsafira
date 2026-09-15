const mongoose = require("mongoose");

const visibilityTypes = ["community", "friends", "private"];

const postSchema = new mongoose.Schema({
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    index: true,
  },

  text: {
    type: String,
    required: true,
    trim: true,
  },

  images: [
    {
      type: String, 
    },
  ],

  visibility: {
    type: String,
    enum: visibilityTypes,
    default: "community",
    index: true,
  },

  likes: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
  ],

  commentsCount: {
    type: Number,
    default: 0,
  },

  isEdited: {
    type: Boolean,
    default: false,
  },

  isDeleted: {
    type: Boolean,
    default: false,
  },

  createdAt: {
    type: Date,
    default: Date.now,
    index: true,
  },

  updatedAt: {
    type: Date,
    default: Date.now,
  },
  community: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Community",
    default: null,
    index: true,
    },

});

module.exports = mongoose.model("Post", postSchema);
