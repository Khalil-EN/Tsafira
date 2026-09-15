const AppError = require('../../../exceptions/Apperror');

/**
 * Thrown when a user attempts to edit or delete a post they did not author.
 * Owned by the post domain — authorship is a post business rule.
 */
class PostAuthorizationError extends AppError {
  constructor(message = 'You can only edit or delete your own posts') {
    super(message, 403);
  }
}

module.exports = PostAuthorizationError;