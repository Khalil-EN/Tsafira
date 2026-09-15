/**
 * Community domain enumerations.
 */

const MemberRole = Object.freeze({
  OWNER:     'owner',
  ADMIN:     'admin',
  MODERATOR: 'moderator',
  MEMBER:    'member',
});

const MemberStatus = Object.freeze({
  ACTIVE:  'active',
  PENDING: 'pending',
  BANNED:  'banned',
});

const CommunityPrivacy = Object.freeze({
  PUBLIC:  'public',
  PRIVATE: 'private',
});

module.exports = { MemberRole, MemberStatus, CommunityPrivacy };