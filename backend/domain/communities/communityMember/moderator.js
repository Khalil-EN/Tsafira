const CommunityMember = require("./communityMember");

class Moderator extends CommunityMember {
  constructor(data) {
    super({ ...data, role: 'moderator' });
  }

  canModerate() {
    return this.isActive();
  }

  canManageMembers() {
    return this.isActive();
  }

  canBanMembers() {
    return this.isActive();
  }
}

module.exports = Moderator;