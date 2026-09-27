const AppError = require('../../../exceptions/Apperror');

class SuggestionLimitExceededError extends AppError {
  constructor(message = 'Daily suggestion limit reached. Upgrade to premium for unlimited suggestions.') {
    super(message, 429);
  }
}

module.exports = SuggestionLimitExceededError;