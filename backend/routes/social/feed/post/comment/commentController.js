const systemManager =
    require("../../../../../system/SystemManager");

const CommentController = {

    async createComment(req, res) {

        const comment =
            await systemManager.addComment(
                req.user,
                req.body
            );

        return res.status(201).json({
            success: true,
            data: comment,
        });
    },

    async likeComment(req, res) {

        const comment =
            await systemManager.likeComment(
                req.user,
                req.params.id
            );

        return res.status(200).json({
            success: true,
            data: comment,
        });
    },

    async deleteComment(req, res) {

        await systemManager.deleteComment(
            req.user,
            req.params.id
        );

        return res.status(200).json({
            success: true,
            data: {
                message:
                    "Comment deleted successfully.",
            },
        });
    },

    async updateComment(req, res) {

        const comment =
            await systemManager.updateComment(
                req.user,
                req.params.id,
                req.body.text
            );

        return res.status(200).json({
            success: true,
            data: comment,
        });
    },

};

module.exports = CommentController;