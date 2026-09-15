const mongoose = require('mongoose');

const analyticsEventSchema = new mongoose.Schema(
  {
    // null for anonymous / guest users
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
      index: true,
    },
    event: {
      type: String,
      required: true,
      index: true,
      // e.g. 'login', 'view_hotel', 'search_activities', 'create_post',
      //      'send_friend_request', 'book_activity', 'plan_generated'
    },
    properties: {
      // Flexible bag of extra context — keep lightweight
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
    // Derived from request for geo/device analytics
    ip:        { type: String, default: null },
    userAgent: { type: String, default: null },
  },
  {
    timestamps: true,
    // Don't create _id index on subdocs — keep writes fast
    versionKey: false,
  }
);

// Auto-delete events older than 1 year
analyticsEventSchema.index(
  { createdAt: 1 },
  { expireAfterSeconds: 365 * 24 * 60 * 60 }
);

module.exports = mongoose.model('AnalyticsEvent', analyticsEventSchema);