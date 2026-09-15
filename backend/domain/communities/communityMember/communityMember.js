class CommunityMember {
  constructor({
    user,
    community,
    role = "member",
    status = "active",
    _id = null,
    joinedAt = null,
  }) {
    this._id = _id;
    this.user = user;
    this.community = community;
    this.role = role;
    this.status = status;
    this.joinedAt = joinedAt;
  }

  isActive() {
    return this.status === "active";
  }

  isPending() {
    return this.status === "pending";
  }

  isBanned() {
    return this.status === "banned";
  }

  canPost() {
    return this.isActive();
  }

  canComment() {
    return this.isActive();
  }

  canModerate() {
    return false;
  }

  canManageMembers() {
    return false;
  }

  canEditCommunity() {
    return false;
  }

  canDeleteCommunity() {
    return false;
  }

  canPromoteMembers() {
    return false;
  }

  canBanMembers() {
    return false;
  }
}

module.exports = CommunityMember;