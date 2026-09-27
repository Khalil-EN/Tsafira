const AppError = require('../../../exceptions/Apperror');

class PostAuthorizationError extends AppError {
  constructor(message = 'You can only edit or delete your own posts') {
    super(message, 403);
  }
}

module.exports = PostAuthorizationError;