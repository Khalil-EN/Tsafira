const AppError = require("./Apperror");

class ForbiddenError extends AppError {

    constructor(message = "Access denied.") {
        super(message, 403);
    }

}

module.exports = ForbiddenError;