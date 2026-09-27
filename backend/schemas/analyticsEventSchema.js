const mongoose = require('mongoose');

const analyticsEventSchema = new mongoose.Schema(
  {
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
    },
    properties: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
    ip:        { type: String, default: null },
    userAgent: { type: String, default: null },
  },
  {
    timestamps: true,
    versionKey: false,
  }
);

analyticsEventSchema.index(
  { createdAt: 1 },
  { expireAfterSeconds: 365 * 24 * 60 * 60 }
);

module.exports = mongoose.model('AnalyticsEvent', analyticsEventSchema);