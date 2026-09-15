const AppError = require("./Apperror");

class UnauthorizedError extends AppError {

    constructor(message = "Authentication required.") {
        super(message, 401);
    }

}

module.exports = UnauthorizedError;