const NotificationDAO = require('../../../dao/notificationDAO');
const UserDAO         = require('../../../dao/userDAO');

// Firebase Admin SDK — initialised once in app.js / server.js via:
//   admin.initializeApp({ credential: admin.credential.applicationDefault() })
// If you haven't set up Firebase Admin yet, install:
//   npm install firebase-admin
let admin;
try {
  admin = require('firebase-admin');
} catch {
  console.warn('[NotificationService] firebase-admin not installed — push disabled');
}

const NotificationService = {
  /**
   * Create a notification record in DB and send an FCM push if the user
   * has a registered device token.
   *
   * @param {Object} opts
   * @param {string}  opts.recipientId  - User._id
   * @param {string}  opts.type         - notificationSchema enum value
   * @param {string}  opts.title
   * @param {string}  opts.body
   * @param {string}  [opts.refModel]
   * @param {string}  [opts.refId]
   */
  async send({ recipientId, type, title, body, refModel = null, refId = null }) {
    // 1. Persist to DB
    const notification = await NotificationDAO.create({
      recipient: recipientId,
      type,
      title,
      body,
      refModel,
      refId,
    });

    // 2. Send FCM push (fire-and-forget — never block the caller)
    NotificationService._sendPush(recipientId, title, body, notification._id)
      .catch(err => console.error('[NotificationService] Push failed:', err.message));

    return notification;
  },

  /**
   * Send the same notification to multiple users at once.
   * Useful for e.g. notifying all community members of a new post.
   */
  async sendToMany({ recipientIds, type, title, body, refModel = null, refId = null }) {
    if (!recipientIds?.length) return;

    const docs = recipientIds.map(id => ({
      recipient: id, type, title, body, refModel, refId,
    }));

    await NotificationDAO.createMany(docs);

    // Batch FCM (max 500 per multicast call)
    NotificationService._sendPushToMany(recipientIds, title, body)
      .catch(err => console.error('[NotificationService] Batch push failed:', err.message));
  },

  // ── Internal helpers ───────────────────────────────────────────────────────

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

    // Fetch all FCM tokens in one query
    const users = await UserDAO.getUsersByIds(userIds, { fcmToken: 1 });
    const tokens = users.map(u => u.fcmToken).filter(Boolean);
    if (!tokens.length) return;

    // FCM multicast — split into batches of 500
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