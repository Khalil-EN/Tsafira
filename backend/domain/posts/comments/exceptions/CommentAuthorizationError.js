const AppError = require('../../../../exceptions/Apperror');

class CommentAuthorizationError extends AppError {
  constructor(message = 'You can only delete your own comments') {
    super(message, 403);
  }
}

module.exports = CommentAuthorizationError;