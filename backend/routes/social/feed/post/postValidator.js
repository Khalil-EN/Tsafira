const {
    ValidationError,
} = require("../../../../exceptions");

function validateCreatePost(req, res, next) {
    const { text } = req.body;

    if (
        typeof text !== "string" ||
        text.trim().length === 0
    ) {
        throw new ValidationError(
            "Post text is required."
        );
    }

    next();
}

function validatePostId(req, res, next) {

    if (!req.params.id) {
        throw new ValidationError(
            "Post id is required."
        );
    }

    next();
}

module.exports = {
    validateCreatePost,
    validatePostId,
};