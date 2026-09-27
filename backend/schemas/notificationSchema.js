const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    recipient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    type: {
      type: String,
      enum: [
        'friend_request',
        'friend_accepted',
        'community_invite',
        'community_accepted',
        'new_post',
        'post_like',
        'post_comment',
        'system',
      ],
      required: true,
    },
    title: { type: String, required: true },
    body:  { type: String, required: true },
    refModel: {
      type: String,
      enum: ['User', 'CommunityPost', 'Request', 'Community', null],
      default: null,
    },
    refId: {
      type: mongoose.Schema.Types.ObjectId,
      default: null,
    },
    read: { type: Boolean, default: false, index: true },
  },
  { timestamps: true }
);

notificationSchema.index({ createdAt: 1 }, { expireAfterSeconds: 60 * 24 * 60 * 60 });

module.exports = mongoose.model('Notification', notificationSchema);