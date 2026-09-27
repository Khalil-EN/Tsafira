
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