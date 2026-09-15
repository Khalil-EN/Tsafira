const systemManager = require("../../system/SystemManager");

const AdminController = {

  // ======================================================
  // USERS
  // ======================================================

  async getUsers(req, res) {
    const {
      page,
      limit,
    } = req.query;

    const result =
      await systemManager.getAllUsers({
        page,
        limit,
      });

    return res.status(200).json({
      success: true,
      data: result,
    });
  },

  async banUser(req, res) {
    const user = await systemManager.banUser(
      req.user.id,
      req.params.id
    );

    return res.status(200).json({
      success: true,
      data: user,
    });
  },

  async unbanUser(req, res) {
    const user = await systemManager.unbanUser(
      req.user.id,
      req.params.id
    );

    return res.status(200).json({
      success: true,
      data: user,
    });
  },

  // ======================================================
  // CONTENT MODERATION
  // ======================================================

  async deletePost(req, res) {
    await systemManager.adminDeletePost(
      req.user.id,
      req.params.id
    );

    return res.status(200).json({
      success: true,
      data: {
        message: "Post deleted successfully.",
      },
    });
  },

  // ======================================================
  // ANALYTICS
  // ======================================================

  async getEventCounts(req, res) {
    const {
      from,
      to,
      groupBy,
    } = req.query;

    const data =
      await systemManager.getAnalyticsEventCounts({
        from,
        to,
        groupBy,
      });

    return res.status(200).json({
      success: true,
      data,
    });
  },

  async getDailyActiveUsers(req, res) {
    const {
      from,
      to,
    } = req.query;

    const data =
      await systemManager.getAnalyticsDailyActiveUsers({
        from,
        to,
      });

    return res.status(200).json({
      success: true,
      data,
    });
  },

  async getRecentEvents(req, res) {
    const {
      limit,
      event,
      userId,
    } = req.query;

    const data =
      await systemManager.getAnalyticsRecentEvents({
        limit,
        event,
        userId,
      });

    return res.status(200).json({
      success: true,
      data,
    });
  },

  // ======================================================
  // NOTIFICATIONS
  // ======================================================

  async broadcastNotification(req, res) {
    const {
      recipientIds,
      title,
      body,
    } = req.body;

    const sent =
      await systemManager.sendSystemNotification(
        req.user.id,
        {
          recipientIds,
          title,
          body,
        }
      );

    return res.status(200).json({
      success: true,
      data: {
        sent,
      },
    });
  },
};

module.exports = AdminController;