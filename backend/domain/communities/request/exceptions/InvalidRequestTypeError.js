const AppError = require('../../../../exceptions/Apperror');

/**
 * Thrown when a request with an unrecognised type is dispatched.
 * Owned by the request domain — request types are a request business concept.
 */
class InvalidRequestTypeError extends AppError {
  constructor(type) {
    super(`Unknown request type: "${type}"`, 400);
    this.requestType = type;
  }
}

module.exports = InvalidRequestTypeError;