const systemManager =
    require("../../../system/SystemManager");

const RequestController = {

    async getRequests(req, res) {

        const {
            received,
            sent,
        } = await systemManager.getRequests(
            req.user.id
        );

        return res.status(200).json({
            success: true,
            data: {
                received,
                sent,
            },
        });
    },

    async acceptRequest(req, res) {

        await systemManager.acceptRequest(
            req.params.id,
            req.user.id
        );

        return res.status(200).json({
            success: true,
            data: {
                message: "Friend request accepted.",
            },
        });
    },

    async rejectRequest(req, res) {

        await systemManager.rejectRequest(
            req.params.id,
            req.user.id
        );

        return res.status(200).json({
            success: true,
            data: {
                message: "Friend request rejected.",
            },
        });
    },

};

module.exports = RequestController;