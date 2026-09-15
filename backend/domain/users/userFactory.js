const BaseUser = require('./basicUser');

const FreemiumUser =
  require('./freemiumUser');

const PremiumUser =
  require('./premiumUser');

const AdminUser =
  require('./adminUser');


function userFactory(userData) {

  switch (userData.role) {

    case 'premium':
      return new PremiumUser(userData);

    case 'admin':
      return new AdminUser(userData);

    case 'freemium':
    default:
      return new FreemiumUser(userData);
  }
}

userFactory.normalizeEmail = BaseUser.normalizeEmail;

module.exports = userFactory;