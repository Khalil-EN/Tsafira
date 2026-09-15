const Notification = require('../schemas/notificationSchema');

const NotificationDAO = {
  async create(data) {
    return await new Notification(data).save();
  },

  async createMany(docs) {
    return await Notification.insertMany(docs, { ordered: false });
  },

  async getForUser(userId, { limit = 20, skip = 0 } = {}) {
    return await Notification.find({ recipient: userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();
  },

  async getUnreadCount(userId) {
    return await Notification.countDocuments({ recipient: userId, read: false });
  },

  async markRead(notificationId, userId) {
    return await Notification.findOneAndUpdate(
      { _id: notificationId, recipient: userId },
      { read: true },
      { new: true }
    ).lean();
  },

  async markAllRead(userId) {
    return await Notification.updateMany(
      { recipient: userId, read: false },
      { read: true }
    );
  },

  async deleteForUser(userId) {
    return await Notification.deleteMany({ recipient: userId });
  },
};

module.exports = NotificationDAO;