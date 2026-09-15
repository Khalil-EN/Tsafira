const { NotFoundError } = require("../exceptions");

const notFoundHandler = (req, res, next) => {

    next(
        new NotFoundError(
            `Route ${req.method} ${req.originalUrl} was not found.`
        )
    );

};

module.exports = notFoundHandler;