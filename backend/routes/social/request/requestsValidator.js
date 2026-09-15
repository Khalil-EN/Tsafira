const {
    ValidationError,
} = require("../../../exceptions");

function validateRequestId(req, res, next) {

    if (!req.params.id) {
        throw new ValidationError(
            "Request id is required."
        );
    }

    next();
}

module.exports = {
    validateRequestId,
};