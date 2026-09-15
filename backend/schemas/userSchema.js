const mongoose = require("mongoose");

const roles = ["freemium", "premium", "admin"];
const statuses = ["active", "inactive", "suspended"];

const userSchema = new mongoose.Schema({
    firstName: {
        type: String,
        required: true,
        trim: true,
    },

    lastName: {
        type: String,
        required: true,
        trim: true,
    },
    

    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true,
    },

    phoneNumber: {
        type: String,
        required: false,
        trim: true,
    },

    birthDate: {
        type: Date,
        required: true,
    },

    passwordHash: {
        type: String,
        required: true,
        select: false,
    },

    // Avatar selected from the application's built-in avatars.
    // Example: "avatar_01", "avatar_02", etc.
    profilePicture: {
        type: String,
        default: "avatar_01",
        trim: true,
    },

    location: {
        type: String,
        default: null,
    },

    lastLoginDate: {
        type: Date,
        default: null,
    },

    status: {
        type: String,
        enum: statuses,
        default: "active",
    },

    role: {
        type: String,
        enum: roles,
        default: "freemium",
    },

    emailVerified: {
        type: Boolean,
        default: false,
    },

    emailVerificationCode: {
      type: String,
      default: null,
      select: false,
  },

  emailVerificationExpiresAt: {
      type: Date,
      default: null,
      select: false,
  },

    isActive: {
        type: Boolean,
        default: true,
    },

    refreshToken: {
        type: String,
        default: null,
        select: false,
    },

    fcmToken: {
        type: String,
        default: null,
        select: false,
    },

    suggestionCountToday: {
        type: Number,
        default: 0,
    },

    lastSuggestionDate: {
        type: Date,
        default: null,
    },

    createdAt: {
        type: Date,
        default: Date.now,
    },

    friends: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
        },
    ],

    communities: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Community",
        },
    ],

    postsCount: {
        type: Number,
        default: 0,
    },
});

userSchema.index(
    { phoneNumber: 1 },
    {
        unique: true,
        partialFilterExpression: {
            phoneNumber: { $type: "string" },
        },
    }
);

module.exports = mongoose.model("User", userSchema);