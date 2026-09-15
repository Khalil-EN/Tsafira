const AppError = require("./Apperror");

class ConflictError extends AppError {
  constructor(message = 'Resource already exists') {
    super(message, 409);
  }
}

module.exports = ConflictError;