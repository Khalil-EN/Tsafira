const systemManager =
    require("../../system/SystemManager");

const ActivityController = {

    async getAll(req, res) {

        const activities =
            await systemManager.getAllActivities();

        return res.status(200).json({
            success: true,
            data: activities,
        });
    },

};

module.exports = ActivityController;