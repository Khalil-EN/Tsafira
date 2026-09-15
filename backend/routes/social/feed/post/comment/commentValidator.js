const {
    ValidationError,
} = require("../../../../../exceptions");

function validateCreateComment(req, res, next) {

    const {
        postId,
        text,
        parentCommentId,
    } = req.body;

    if (
        !postId ||
        typeof postId !== "string" ||
        postId.trim().length === 0
    ) {
        throw new ValidationError(
            "postId is required."
        );
    }

    if (
        typeof text !== "string" ||
        text.trim().length === 0
    ) {
        throw new ValidationError(
            "Comment content is required."
        );
    }

    if (text.trim().length > 2000) {
        throw new ValidationError(
            "Comment cannot exceed 2000 characters."
        );
    }

    if (
        parentCommentId !== undefined &&
        parentCommentId !== null &&
        (
            typeof parentCommentId !== "string" ||
            parentCommentId.trim().length === 0
        )
    ) {
        throw new ValidationError(
            "parentCommentId must be a valid comment id."
        );
    }

    next();
}

function validateCommentId(req, res, next) {

    if (
        !req.params.id ||
        typeof req.params.id !== "string" ||
        req.params.id.trim().length === 0
    ) {
        throw new ValidationError(
            "Comment id is required."
        );
    }

    next();
}

module.exports = {
    validateCreateComment,
    validateCommentId,
};