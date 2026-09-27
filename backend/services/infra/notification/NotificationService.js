const NotificationDAO = require('../../../dao/notificationDAO');
const UserDAO         = require('../../../dao/userDAO');

let admin;

try {
  admin = require('firebase-admin');
} catch {
  console.warn('[NotificationService] firebase-admin not installed — push disabled');
}

const NotificationService = {
  /**

   * @param {Object} opts
   * @param {string}  opts.recipientId  
   * @param {string}  opts.type      
   * @param {string}  opts.title
   * @param {string}  opts.body
   * @param {string}  [opts.refModel]
   * @param {string}  [opts.refId]
   */
  async send({ recipientId, type, title, body, refModel = null, refId = null }) {
    const notification = await NotificationDAO.create({recipient: recipientId, type, title, body,
                                                      refModel, refId
    });

    NotificationService._sendPush(recipientId, title, body, notification._id)
      .catch(err => console.error('[NotificationService] Push failed:', err.message));

    return notification;
  },

  async sendToMany({ recipientIds, type, title, body, refModel = null, refId = null }) {
    if (!recipientIds?.length) return;

    const docs = recipientIds.map(id => ({recipient: id, type, title, body, refModel, refId}));

    await NotificationDAO.createMany(docs);

    NotificationService._sendPushToMany(recipientIds, title, body)
      .catch(err => console.error('[NotificationService] Batch push failed:', err.message));
  },

  async _sendPush(userId, title, body, notificationId) {
    if (!admin) return;

    const user = await UserDAO.getUserById(userId, { fcmToken: 1 });
    if (!user?.fcmToken) return;

    await admin.messaging().send({
      token: user.fcmToken,
      notification: { title, body },
      data: { notificationId: notificationId.toString() },
      android: { priority: 'high' },
      apns:    { payload: { aps: { sound: 'default' } } },
    });
  },

  async _sendPushToMany(userIds, title, body) {
    if (!admin) return;

    const users = await UserDAO.getUsersByIds(userIds, { fcmToken: 1 });
    const tokens = users.map(u => u.fcmToken).filter(Boolean);
    if (!tokens.length) return;

    for (let i = 0; i < tokens.length; i += 500) {
      const batch = tokens.slice(i, i + 500);
      await admin.messaging().sendEachForMulticast({
        tokens: batch,
        notification: { title, body },
        android: { priority: 'high' },
        apns:    { payload: { aps: { sound: 'default' } } },
      });
    }
  },
};

module.exports = NotificationService;