const mongoose = require("mongoose");

const requestSchema =
  new mongoose.Schema(
    {
      // ======================================================================
      // TYPE
      // ======================================================================

      type: {
        type: String,
        enum: [
          "friend",
          "community",
        ],
        required: true,
      },

      // ======================================================================
      // SENDER
      // ======================================================================

      sender: {
        type:
          mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
      },

      // ======================================================================
      // USER RECIPIENT
      //
      // Used for friend requests.
      // ======================================================================

      recipient: {
        type:
          mongoose.Schema.Types.ObjectId,
        ref: "User",
        default: null,
      },

      // ======================================================================
      // COMMUNITY
      //
      // Used for community join requests.
      // ======================================================================

      community: {
        type:
          mongoose.Schema.Types.ObjectId,
        ref: "Community",
        default: null,
      },

      // ======================================================================
      // STATUS
      // ======================================================================

      status: {
        type: String,
        enum: [
          "pending",
          "accepted",
          "rejected",
        ],
        default: "pending",
      },

      // ======================================================================
      // CREATED
      // ======================================================================

      createdAt: {
        type: Date,
        default: Date.now,
      },
    },
    {
      timestamps: false,
    }
  );

// ============================================================================
// VALIDATE REQUEST RELATIONSHIPS
// ============================================================================
//
// Friend request:
//   sender    = User
//   recipient = User
//   community = null
//
// Community request:
//   sender    = User
//   recipient = null
//   community = Community
// ============================================================================

requestSchema.pre("validate", function () {
  if (this.type === "friend") {
    if (!this.recipient) {
      throw new Error(
        "A friend request requires a recipient."
      );
    }

    this.community = null;
  }

  if (this.type === "community") {
    if (!this.community) {
      throw new Error(
        "A community request requires a community."
      );
    }

    this.recipient = null;
  }
});

// ============================================================================
// INDEXES
// ============================================================================

requestSchema.index({
  sender: 1,
  status: 1,
});

requestSchema.index({
  recipient: 1,
  status: 1,
});

requestSchema.index({
  community: 1,
  status: 1,
});

requestSchema.index({
  type: 1,
  sender: 1,
  recipient: 1,
  status: 1,
});

requestSchema.index({
  type: 1,
  sender: 1,
  community: 1,
  status: 1,
});

module.exports =
  mongoose.model(
    "Request",
    requestSchema
  );