const systemManager = require("../../system/SystemManager");

const SearchController = {

    async searchUsersAndCommunities(req, res) {

        const {query, types} = req.body;

        const results = await systemManager.searchUsersAndCommunities(req.user.id, query, types);

        return res.status(200).json({
            success: true,
            data: results,
        });
    },

    async searchResidences(req, res) {

        const results = await systemManager.searchResidences(req.body);

        return res.status(200).json({
            success: true,
            data: results,
        });
    },

    async searchRestaurants(req, res) {

        const results = await systemManager.searchRestaurants(req.body);

        return res.status(200).json({
            success: true,
            data: results,
        });
    },

    async searchActivities(req, res) {

        const results = await systemManager.searchActivities(req.body);

        return res.status(200).json({
            success: true,
            data: results,
        });
    },
};


module.exports = SearchController;