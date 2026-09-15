const {
    ValidationError,
} = require("../../exceptions");

function validateSuggestedItinerary(req, res, next) {

    if (!req.body || typeof req.body !== "object") {

        throw new ValidationError(
            "Request body is required."
        );
    }

    next();
}

module.exports = {
    validateSuggestedItinerary,
};