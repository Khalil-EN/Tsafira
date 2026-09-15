const { AppError } = require("../exceptions");

const errorHandler = (err, req, res, next) => {

    if (res.headersSent) {
        return next(err);
    }

    if (err instanceof AppError) {

        return res.status(err.statusCode).json({
            success: false,
            error: {
                type: err.name,
                message: err.message,
            },
        });

    }

    console.error(err);

    return res.status(500).json({
        success: false,
        error: {
            type: "InternalServerError",
            message: "An unexpected error occurred.",
        },
    });

};

module.exports = errorHandler;