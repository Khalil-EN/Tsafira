const AppError = require('../../../exceptions/Apperror');

/**
 * Thrown when a community member attempts an action their role does not permit
 * (e.g. a regular member trying to ban someone, a non-owner trying to delete).
 * Owned by the community domain.
 */
class UnauthorizedCommunityActionError extends AppError {
  constructor(message = 'You do not have permission to perform this action in this community') {
    super(message, 403);
  }
}

module.exports = UnauthorizedCommunityActionError;