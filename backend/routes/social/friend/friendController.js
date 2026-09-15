const systemManager = require("../../../system/SystemManager");

const FriendController = {

    async sendFriendRequest(req, res) {

        await systemManager.sendFriendRequest(
            req.user.id,
            req.body.targetUserId
        );

        return res.status(200).json({
            success: true,
            data: {
                message: "Friend request sent successfully.",
            },
        });
    },

    async getFriends(req, res) {

        const friends =
            await systemManager.getFriends(
                req.user.id
            );

        return res.status(200).json({
            success: true,
            data: friends,
        });
    },

};

module.exports = FriendController;