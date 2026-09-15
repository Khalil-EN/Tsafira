const {
    ValidationError,
} = require("../../exceptions");


function validateUserCommunitySearch(
    req,
    res,
    next
) {

    const {
        query,
    } = req.body;

    if (
        typeof query !== "string" ||
        query.trim().length === 0
    ) {
        throw new ValidationError(
            "Search query is required."
        );
    }

    next();
}


function validateSearchFilters(
    req,
    res,
    next
) {

    if (
        !req.body ||
        typeof req.body !== "object" ||
        Array.isArray(req.body)
    ) {
        throw new ValidationError(
            "Search filters must be an object."
        );
    }

    next();
}


module.exports = {
    validateUserCommunitySearch,
    validateSearchFilters,
};