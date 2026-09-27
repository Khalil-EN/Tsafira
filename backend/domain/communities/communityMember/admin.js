const CommunityMember = require("./communityMember");

class Admin extends CommunityMember {
  constructor(data) {
    super({ ...data, role: 'admin' });
  }

  canModerate() {
    return this.isActive();
  }

  canManageMembers() {
    return this.isActive();
  }

  canEditCommunity() {
    return this.isActive();
  }

  canPromoteMembers() {
    return this.isActive();
  }

  canBanMembers() {
    return this.isActive();
  }
}

module.exports = Admin;