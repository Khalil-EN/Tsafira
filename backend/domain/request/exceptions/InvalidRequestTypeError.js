const AppError = require('../../../exceptions/Apperror');

class InvalidRequestTypeError extends AppError {
  constructor(type) {
    super(`Unknown request type: "${type}"`, 400);
    this.requestType = type;
  }
}

module.exports = InvalidRequestTypeError;