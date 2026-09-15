const {
    ValidationError,
} = require("../../../exceptions");

function validateCreateCommunity(req, res, next) {

    const {
        name,
        description,
    } = req.body;

    if (
        typeof name !== "string" ||
        name.trim().length === 0
    ) {
        throw new ValidationError(
            "Community name is required."
        );
    }

    if (
        description !== undefined &&
        typeof description !== "string"
    ) {
        throw new ValidationError(
            "Community description must be a string."
        );
    }

    next();
}

function validateCommunityId(req, res, next) {

    if (!req.params.id) {
        throw new ValidationError(
            "Community id is required."
        );
    }

    next();
}

function validateJoinCommunity(req, res, next) {

    if (!req.body.communityId) {
        throw new ValidationError(
            "communityId is required."
        );
    }

    next();
}

module.exports = {
    validateCreateCommunity,
    validateCommunityId,
    validateJoinCommunity,
};