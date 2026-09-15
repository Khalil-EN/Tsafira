const {
    ValidationError,
} = require("../../../exceptions");

function validateParticipant(req, res, next) {

    if (!req.body.participantId) {
        throw new ValidationError(
            "participantId is required."
        );
    }

    next();
}

function validateConversationId(req, res, next) {

    if (!req.params.conversationId) {
        throw new ValidationError(
            "conversationId is required."
        );
    }

    next();
}

function validateSendMessage(req, res, next) {

    const {
        conversationId,
        content,
    } = req.body;

    if (!conversationId) {
        throw new ValidationError(
            "conversationId is required."
        );
    }

    if (
        typeof content !== "string" ||
        content.trim().length === 0
    ) {
        throw new ValidationError(
            "Message content is required."
        );
    }

    next();
}

module.exports = {
    validateParticipant,
    validateConversationId,
    validateSendMessage,
};