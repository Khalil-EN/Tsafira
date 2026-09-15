const CommunityMember = require("./communityMember");

class Owner extends CommunityMember {
  constructor(data) {
    super({
      ...data,
      role: "owner",
    });
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

  canDeleteCommunity() {
    return this.isActive();
  }

  canPromoteMembers() {
    return this.isActive();
  }

  canBanMembers() {
    return this.isActive();
  }
}

module.exports = Owner;