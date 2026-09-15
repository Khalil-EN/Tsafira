const systemManager =
    require("../../system/SystemManager");

const RestaurantController = {

    async getAll(req, res) {

        const restaurants =
            await systemManager.getAllRestaurants();


        return res.status(200).json({
            success: true,
            data: restaurants,
        });
    },

};

module.exports = RestaurantController;