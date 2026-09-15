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

  // Moderators can delete posts/comments but not edit community settings
}

module.exports = Moderator;