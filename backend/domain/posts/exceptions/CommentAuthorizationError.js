const AppError = require('../../../exceptions/Apperror');

/**
 * Thrown when a user attempts to delete a comment they did not author.
 * Owned by the post domain alongside Comment.
 */
class CommentAuthorizationError extends AppError {
  constructor(message = 'You can only delete your own comments') {
    super(message, 403);
  }
}

module.exports = CommentAuthorizationError;