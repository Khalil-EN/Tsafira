const systemManager =
    require("../../system/SystemManager");

const ResidenceController = {

    async getAll(req, res) {

        const residences =
            await systemManager.getAllResidences();

        return res.status(200).json({
            success: true,
            data: residences,
        });
    },

};

module.exports = ResidenceController;