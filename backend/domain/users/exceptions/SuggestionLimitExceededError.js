const AppError = require('../../../exceptions/Apperror');

/**
 * Thrown when a freemium user attempts to generate more suggestions
 * than their daily quota allows.
 * Owned by the user domain — this is a freemium business rule.
 */
class SuggestionLimitExceededError extends AppError {
  constructor(message = 'Daily suggestion limit reached. Upgrade to premium for unlimited suggestions.') {
    super(message, 429);
  }
}

module.exports = SuggestionLimitExceededError;