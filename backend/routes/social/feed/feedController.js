const systemManager =
    require("../../../system/SystemManager");

const FeedController = {

    async getFeed(req, res) {

        const feed =
            await systemManager.getFeed(
                req.user.id,
                req.query
            );

        return res.status(200).json({
            success: true,
            data: feed,
        });
    },

};

module.exports = FeedController;