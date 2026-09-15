const {
    ValidationError,
} = require("../../exceptions");

function validateNotificationId(req, res, next) {

    if (!req.params.id) {
        throw new ValidationError(
            "Notification id is required."
        );
    }

    next();
}


function validateFcmToken(req, res, next) {

    const { token } = req.body;

    if (
        typeof token !== "string" ||
        token.trim().length === 0
    ) {
        throw new ValidationError(
            "FCM token is required."
        );
    }

    next();
}


function validatePagination(req, res, next) {

    const page =
        Number(req.query.page ?? 1);

    const limit =
        Number(req.query.limit ?? 20);

    if (
        !Number.isInteger(page) ||
        page < 1
    ) {
        throw new ValidationError(
            "page must be a positive integer."
        );
    }

    if (
        !Number.isInteger(limit) ||
        limit < 1 ||
        limit > 100
    ) {
        throw new ValidationError(
            "limit must be between 1 and 100."
        );
    }

    next();
}


module.exports = {
    validateNotificationId,
    validateFcmToken,
    validatePagination,
};