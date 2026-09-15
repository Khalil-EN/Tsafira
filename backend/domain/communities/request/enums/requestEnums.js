/**
 * Request domain enumerations.
 */

const RequestType = Object.freeze({
  FRIEND:    'friend',
  COMMUNITY: 'community',
});

const RequestStatus = Object.freeze({
  PENDING:  'pending',
  ACCEPTED: 'accepted',
  REJECTED: 'rejected',
});

module.exports = { RequestType, RequestStatus };