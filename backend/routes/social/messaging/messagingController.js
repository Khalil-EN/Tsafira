const systemManager =
    require("../../../system/SystemManager");

const MessagingController = {

    async getInbox(req, res) {

        const page =
            Number(req.query.page) || 1;

        const limit =
            Number(req.query.limit) || 20;

        const chats =
            await systemManager.getInbox(
                req.user.id,
                page,
                limit
            );

        return res.status(200).json({
            success: true,
            data: chats,
        });
    },

    async getOrCreateDirectChat(req, res) {

        const conversation =
            await systemManager.getOrCreateDirectChat(
                req.user.id,
                req.body.participantId
            );

        return res.status(200).json({
            success: true,
            data: conversation,
        });
    },

    async getMessages(req, res) {

        const page =
            Number(req.query.page) || 1;

        const limit =
            Number(req.query.limit) || 30;

        const messages =
            await systemManager.getMessages(
                req.user.id,
                req.params.conversationId,
                page,
                limit
            );

        return res.status(200).json({
            success: true,
            data: messages,
        });
    },

    async sendMessage(req, res) {

        const message =
            await systemManager.sendMessage(
                req.user.id,
                req.body.conversationId,
                req.body.content.trim()
            );

        return res.status(201).json({
            success: true,
            data: message,
        });
    },

    async markConversationAsRead(req, res) {
        const userId = req.user.id;

        const conversationId =
            req.params.conversationId;

        await systemManager.markConversationAsRead(
            userId,
            conversationId
        );

        return res.status(200).json({
            success: true,
        });
        },

};

module.exports = MessagingController;