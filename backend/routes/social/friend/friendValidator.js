const { ValidationError } = require("../../../exceptions");

function validateSendFriendRequest(req, res, next) {
    const { targetUserId } = req.body;

    if (!targetUserId) {
        throw new ValidationError(
            "targetUserId is required."
        );
    }

    next();
}

module.exports = {
    validateSendFriendRequest,
};