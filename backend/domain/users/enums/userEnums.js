/**
 * User domain enumerations.
 * Import these wherever you need to reason about user roles or statuses
 * instead of using magic strings.
 */

const UserRole = Object.freeze({
  FREEMIUM: 'freemium',
  PREMIUM:  'premium',
  ADMIN:    'admin',
});

const UserStatus = Object.freeze({
  ACTIVE:   'active',
  INACTIVE: 'inactive',
  SUSPENDED: 'suspended',
});

module.exports = { UserRole, UserStatus };