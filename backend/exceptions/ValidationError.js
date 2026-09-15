const AppError = require('./Apperor');

class ValidationError extends AppError {
  constructor(message = 'Invalid input') {
    super(message, 400);
  }
}

module.exports = ValidationError;