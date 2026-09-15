const CommunityMemberFactory = require(
  "../../../domain/communities/communityMember/communityMemberFactory"
);

const CommunityMemberMapper = {
  fromPersistence(data) {
    if (!data) {
      return null;
    }

    return CommunityMemberFactory.create({
      _id:
        data._id?.toString() ??
        data.id?.toString() ??
        null,

      user:
        data.user?._id?.toString() ??
        data.user?.id?.toString() ??
        data.user?.toString() ??
        null,

      community:
        data.community?._id?.toString() ??
        data.community?.id?.toString() ??
        data.community?.toString() ??
        null,

      role:
        data.role ?? "member",

      status:
        data.status ?? "active",

      joinedAt:
        data.joinedAt ??
        data.createdAt ??
        null,
    });
  },

  fromPersistenceList(data = []) {
    return data
      .map(item => this.fromPersistence(item))
      .filter(Boolean);
  },

  toPersistence(member) {
    if (!member) {
      return null;
    }

    return {
      user: member.user,
      community: member.community,
      role: member.role,
      status: member.status,
      joinedAt: member.joinedAt,
    };
  },
};

module.exports =
  CommunityMemberMapper;