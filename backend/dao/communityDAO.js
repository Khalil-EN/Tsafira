const CommunityModel = require("../schemas/communitySchema");

const CommunityDAO = {
  async createCommunity(data) {
    const community =
      new CommunityModel(data);

    return await community.save();
  },

  async getCommunityById(id) {
    return await CommunityModel
      .findById(id)
      .lean();
  },

  async getCommunityByName(name) {
    return await CommunityModel
      .findOne({ name })
      .lean();
  },

  async updateCommunity(
    id,
    updateData
  ) {
    return await CommunityModel
      .findByIdAndUpdate(
        id,
        updateData,
        {
          new: true,
          runValidators: true,
        }
      )
      .lean();
  },

  async deleteCommunity(id) {
    return await CommunityModel
      .findByIdAndDelete(id);
  },

  async getAllCommunities(
    filter = {}
  ) {
    return await CommunityModel
      .find(filter)
      .sort({
        createdAt: -1,
      })
      .lean();
  },

  async incrementMembersCount(
    communityId
  ) {
    return await CommunityModel
      .findByIdAndUpdate(
        communityId,
        {
          $inc: {
            membersCount: 1,
          },
        },
        {
          new: true,
        }
      )
      .lean();
  },

  async decrementMembersCount(
    communityId
  ) {
    return await CommunityModel
      .findOneAndUpdate(
        {
          _id: communityId,
          membersCount: {
            $gt: 0,
          },
        },
        {
          $inc: {
            membersCount: -1,
          },
        },
        {
          new: true,
        }
      )
      .lean();
  },

  async incrementPostsCount(
    communityId
  ) {
    return await CommunityModel
      .findByIdAndUpdate(
        communityId,
        {
          $inc: {
            postsCount: 1,
          },
        },
        {
          new: true,
        }
      )
      .lean();
  },

  async decrementPostsCount(
    communityId
  ) {
    return await CommunityModel
      .findOneAndUpdate(
        {
          _id: communityId,
          postsCount: {
            $gt: 0,
          },
        },
        {
          $inc: {
            postsCount: -1,
          },
        },
        {
          new: true,
        }
      )
      .lean();
  },

  async searchCommunities(query) {
    return await CommunityModel
      .find({
        name: {
          $regex: query,
          $options: "i",
        },
      })
      .lean();
  },

  async getCommunitiesOwnedByUser(userId) {
    return await CommunityModel.find({
      owner: userId,
    }).lean();
  },

   async updateOwner(communityId, ownerId) {
    return await CommunityModel.findByIdAndUpdate(
      communityId,
      {
        owner: ownerId,
      },
      {
        new: true,
      }
    ).lean();
  },
};

module.exports = CommunityDAO;