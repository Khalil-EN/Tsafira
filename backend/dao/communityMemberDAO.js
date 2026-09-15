const CommunityMemberModel = require("../schemas/communityMemberSchema");

const CommunityMemberDAO = {
  async addMember(data) {
    const member = new CommunityMemberModel(data);
    console.log(member);
    return await member.save();
  },

  async getMember(communityId, userId) {
    return await CommunityMemberModel.findOne({
      community: communityId,
      user: userId,
    }).lean();
  },

  async getMembersByCommunity(communityId) {
    return await CommunityMemberModel.find({
      community: communityId,
      status: "active",
    })
      .populate("user", "firstName lastName profilePicture")
      .lean();
  },

  async getUserCommunities(userId) {
    return await CommunityMemberModel.find({
      user: userId,
      status: "active",
    })
      .populate("community", "name privacy")
      .lean();
  },

  async updateMemberRole(communityId, userId, role) {
      return await CommunityMemberModel.findOneAndUpdate(
          {
              community: communityId,
              user: userId,
          },
          {
              role,
          },
          {
              new: true,
              runValidators: true,
          }
      ).lean();
  },

  async updateMemberStatus(communityId, userId, status) {
      return await CommunityMemberModel.findOneAndUpdate(
          {
              community: communityId,
              user: userId,
          },
          {
              status,
          },
          {
              new: true,
              runValidators: true,
          }
      ).lean();
  },

  async removeMember(communityId, userId) {
    return await CommunityMemberModel.findOneAndDelete({
      community: communityId,
      user: userId,
    });
  },
  async getPendingMembersByCommunity(communityId) {
    return await CommunityMemberModel.find({
      community: communityId,
      status: "pending",
    })
      .populate("user", "firstName lastName profilePicture")
      .sort({ createdAt: -1 })
      .lean();
  },

  async removeAllMembersForCommunity(communityId) {
    return await CommunityMemberModel.deleteMany({
      community: communityId,
    });
  },

  async removeAllMembersForUser(userId) {
    return await CommunityMemberModel.deleteMany({ user: userId });
  },

  async getActiveMembersExceptUser(communityId, userId) {
    return await CommunityMember.find({
      community: communityId,
      user: { $ne: userId },
      isActive: true,
    })
      .sort({ createdAt: 1 })
      .populate(
        "user",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  async getNextOwnerCandidate(
    communityId,
    excludedUserId
  ) {
    const members =
      await CommunityMemberModel.find({
        community: communityId,
        user: { $ne: excludedUserId },
        status: "active",
      })
        .populate(
          "user",
          "firstName lastName profilePicture"
        )
        .lean();

    const rolePriority = {
      admin: 1,
      moderator: 2,
      member: 3,
    };

    members.sort((a, b) => {
      const priorityA =
        rolePriority[a.role] ?? 99;

      const priorityB =
        rolePriority[b.role] ?? 99;

      if (priorityA !== priorityB) {
        return priorityA - priorityB;
      }

      return (
        new Date(a.createdAt) -
        new Date(b.createdAt)
      );
    });

    return members[0] ?? null;
  }
};

module.exports = CommunityMemberDAO;
