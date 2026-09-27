const AppError = require('../../../exceptions/Apperror');


class UnauthorizedCommunityActionError extends AppError {
  constructor(message = 'You do not have permission to perform this action in this community') {
    super(message, 403);
  }
}

module.exports = UnauthorizedCommunityActionError;