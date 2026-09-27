const systemManager = require("../../system/SystemManager");

const ItineraryController = {

    async generateSuggested(req, res) {

        const suggestedPlan = await systemManager.generateSuggestedItinerary(req.user.id, req.body);

        if (!suggestedPlan) {

            return res.status(429).json({
                success: false,
                error: "LIMIT_REACHED",
                message:
                    "You have reached your daily limit of plan suggestions.",
            });
        }
        return res.status(200).json({
                success: true,
                data: suggestedPlan,
            });
    },

};

module.exports = ItineraryController;