const UnauthorizedCommunityActionError =
  require(
    "../exceptions/UnauthorizedCommunityActionError"
  );

const CommunityMembershipPolicy = {
  assertMember(member) {
    if (!member) {
      throw new UnauthorizedCommunityActionError(
        "You are not a member of this community."
      );
    }

    if (!member.isActive()) {
      throw new UnauthorizedCommunityActionError(
        "You must be an active member of this community."
      );
    }

    return true;
  },

  assertCanPost(member) {
    this.assertMember(member);

    if (!member.canPost()) {
      throw new UnauthorizedCommunityActionError(
        "You do not have permission to post in this community."
      );
    }

    return true;
  },

  assertCanComment(member) {
    this.assertMember(member);

    if (!member.canComment()) {
      throw new UnauthorizedCommunityActionError(
        "You do not have permission to comment in this community."
      );
    }

    return true;
  },

  assertCanManageMembers(member) {
    this.assertMember(member);

    if (!member.canManageMembers()) {
      throw new UnauthorizedCommunityActionError(
        "You do not have permission to manage community members."
      );
    }

    return true;
  },

  assertCanPromoteMembers(member) {
    this.assertMember(member);

    if (!member.canPromoteMembers()) {
      throw new UnauthorizedCommunityActionError(
        "You do not have permission to promote community members."
      );
    }

    return true;
  },

  assertCanBanMembers(member) {
    this.assertMember(member);

    if (!member.canBanMembers()) {
      throw new UnauthorizedCommunityActionError(
        "You do not have permission to ban community members."
      );
    }

    return true;
  },

  assertCanEditCommunity(member) {
    this.assertMember(member);

    if (!member.canEditCommunity()) {
      throw new UnauthorizedCommunityActionError(
        "You do not have permission to edit this community."
      );
    }

    return true;
  },

  assertCanDeleteCommunity(member) {
    this.assertMember(member);

    if (!member.canDeleteCommunity()) {
      throw new UnauthorizedCommunityActionError(
        "You do not have permission to delete this community."
      );
    }

    return true;
  },
};

module.exports =
  CommunityMembershipPolicy;