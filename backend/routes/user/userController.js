const systemManager = require("../../system/SystemManager");

const UserController = {

    async updateProfile(req, res) {

        const user =
            await systemManager.updateProfile(
                req.user.id,
                req.body
            );

        return res.status(200).json({
            success: true,
            data: user,
        });
    },

    async deleteProfile(req, res) {

        await systemManager.deleteProfile(req.user);

        return res.status(200).json({
            success: true,
            data: {
                message: "Account deleted successfully.",
            },
        });
    },

};

module.exports = UserController;