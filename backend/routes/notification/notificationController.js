const systemManager =
    require("../../system/SystemManager");

const NotificationController = {

    // ======================================================
    // GET NOTIFICATIONS
    // ======================================================

    async getNotifications(req, res) {

        const page =
            Number(req.query.page) || 1;

        const limit =
            Number(req.query.limit) || 20;

        const skip =
            (page - 1) * limit;

        const notifications =
            await systemManager.getNotifications(
                req.user.id,
                {
                    limit,
                    skip,
                }
            );

        const unread =
            await systemManager.getUnreadNotificationCount(
                req.user.id
            );

        return res.status(200).json({
            success: true,
            data: {
                notifications,
                unread,
                page,
                limit,
            },
        });
    },


    // ======================================================
    // MARK ONE AS READ
    // ======================================================

    async markAsRead(req, res) {

        const notification =
            await systemManager.markNotificationRead(
                req.params.id,
                req.user.id
            );

        if (!notification) {
            return res.status(404).json({
                success: false,
                error: "Notification not found.",
            });
        }

        return res.status(200).json({
            success: true,
            data: notification,
        });
    },


    // ======================================================
    // MARK ALL AS READ
    // ======================================================

    async markAllAsRead(req, res) {

        await systemManager.markAllNotificationsRead(
            req.user.id
        );

        return res.status(200).json({
            success: true,
            data: {
                message: "All notifications marked as read.",
            },
        });
    },


    // ======================================================
    // SAVE FCM TOKEN
    // ======================================================

    async saveFcmToken(req, res) {

        await systemManager.saveFcmToken(
            req.user.id,
            req.body.token
        );

        return res.status(200).json({
            success: true,
            data: {
                message: "FCM token saved successfully.",
            },
        });
    },
};


module.exports = NotificationController;