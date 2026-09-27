const CommunityDAO = require("../../dao/communityDAO");
const RequestDAO = require("../../dao/requestDAO");

const CommunityAssembler = require("./CommunityAssembler");

const CommunityMapper = require("./CommunityMapper");

const CommunityMemberService = require("./communityMember/CommunityMemberService");

const CommunityMembershipPolicy = require("../../domain/communities/communityMember/CommunityMembershipPolicy");

const {NotFoundError, UnauthorizedError} = require("../../exceptions");

// TODO : Must be refactored. For example, a a strategy for transfering community ownership is required instead of hardcoding the rules in this service

const CommunityService = {

  async _getCommunity(id) {
    const doc = await CommunityDAO.getCommunityById(id);

    if (!doc) {
      throw new NotFoundError("Community not found.");
    }

    return CommunityMapper.fromPersistence(doc);
  },

  async _getAllCommunities(filter = {}) {
    const docs = await CommunityDAO.getAllCommunities(filter);

    return CommunityMapper.fromPersistenceList(docs);
  },

  async _assertOwner(communityId, userId) {

    const community = await CommunityService._getCommunity(communityId);
    const ownerId = community.owner ?? community.creator;
    if (!ownerId || ownerId.toString() !== userId.toString()) {
      throw new UnauthorizedError("Only the community owner can perform this action.");
    }

    return community;
  },

  async createCommunity(creatorUser, communityData) {

    const creatorId = creatorUser?.id ?? creatorUser?._id;
    if (!creatorId) {
      throw new UnauthorizedError("User identity is required.");
    }

    const doc = await CommunityDAO.createCommunity({...communityData, creator: creatorId, owner: creatorId,
                                                    membersCount: 1,
      });

    await CommunityMemberService.addMemberDirectly(doc._id, creatorId, "owner", {incrementCount: false});

    const community = CommunityMapper.fromPersistence(doc);

    return CommunityAssembler.toDTO(community);
  },

  async getCommunityById(id, userId) {

    const community = await CommunityService._getCommunity(id);
    let membership = null;
    if (userId) {
      const found = await CommunityMemberService.getMember(id, userId);

      if (found?.isActive()) {
        membership = found;
      }
    }

    return CommunityAssembler.toDetailDTO(community, membership);
  },

  async getAllCommunities(filter = {}) {

    const communities = await CommunityService._getAllCommunities(filter);

    return CommunityAssembler.toDTOList(communities);
  },

  async updateCommunity(id, updates, user) {

    const userId = user?.id ?? user?._id;
    if (!userId) {
      throw new UnauthorizedError("User identity is required.");
    }

    await CommunityService._getCommunity(id);

    const membership = await CommunityMemberService.getMember(id, userId);

    CommunityMembershipPolicy.assertCanEditCommunity(membership);

    const safeUpdates = {...updates};

    delete safeUpdates.creator;
    delete safeUpdates.owner;
    delete safeUpdates.membersCount;
    delete safeUpdates.postsCount;

    const updatedDoc = await CommunityDAO.updateCommunity(id, safeUpdates);
    if (!updatedDoc) {
      throw new NotFoundError("Community not found.");
    }

    const updatedCommunity = CommunityMapper.fromPersistence(updatedDoc);

    return CommunityAssembler.toDTO(updatedCommunity);
  },

  async _assertCanDelete(communityId, userId) {

    await CommunityService._getCommunity(communityId);

    const membership = await CommunityMemberService.getMember(communityId, userId);

    CommunityMembershipPolicy.assertCanDeleteCommunity(membership);
  },

  async assertCanDeleteCommunity(communityId, user) {

    const userId = user?.id ?? user?._id;

    if (!userId) {
      throw new UnauthorizedError("User identity is required.");
    }

    await CommunityService._assertCanDelete(communityId, userId);
  },

  async deleteCommunity(id, user) {

    const userId = user?.id ?? user?._id;

    if (!userId) {
      throw new UnauthorizedError("User identity is required.");
    }

    await CommunityService._assertCanDelete(id, userId);

    await CommunityMemberService.removeAllMembersForCommunity(id);

    await CommunityDAO.deleteCommunity(id);

    return { success: true };
  },

  async searchCommunities(userId, query) {

    const docs =await CommunityDAO.searchCommunities(query);
    if (!docs.length) {
      return [];
    }

    const communityIds = docs.map(doc => doc._id);
    const pendingRequests = await RequestDAO.getPendingCommunityRequestsSentTo(userId, communityIds);
    const pendingCommunityIds = new Set(pendingRequests.map(request =>request.community.toString()));

    const results = await Promise.all(docs.map(async doc => {
          const communityId = doc._id.toString();
          const membership = await CommunityMemberService.getMember(communityId, userId);

          return CommunityAssembler.toSearchResult(doc, userId, {isMember: membership?.isActive() ?? false,
                                                                 requestSent: pendingCommunityIds.has(communityId)}
          );
        })
      );

    return results.filter(Boolean);
  },

  async getUserMemberships(userId) {
    return await CommunityMemberService.getUserMemberships(userId);
  },

  async getPendingMembers(communityId, actingUserId) {
    return await CommunityMemberService.getPendingMembers(communityId, actingUserId);
  },

  async approveMember(communityId, userId, actingUserId) {
    return await CommunityMemberService.approveMember(communityId, userId, actingUserId);
  },

  async rejectMember(communityId, userId, actingUserId) {
    return await CommunityMemberService.rejectMember(communityId, userId, actingUserId);
  },

  async assertUserCanPost(userId, visibility, communityId) {

    if (visibility !== "community") {
      return true;
    }

    if (!communityId) {
      throw new NotFoundError("Community is required for a community post.");
    }

    const community = await CommunityService._getCommunity(communityId);
    if (!community.isActive) {
      throw new UnauthorizedError("This community is no longer active.");
    }

    const membership = await CommunityMemberService.getMember(communityId, userId);

    CommunityMembershipPolicy.assertCanPost(membership);

    return true;
  },

  async assertUserIsMember(userId, communityId) {

    const membership = await CommunityMemberService.getMember(communityId, userId);

    CommunityMembershipPolicy.assertMember(membership);

    return true;
  },

  async handleOwnedCommunitiesBeforeUserDeletion(userId) {
    if (!userId) {
      return;
    }

    const ownedCommunities = await CommunityDAO.getCommunitiesOwnedByUser(userId);
    if (!ownedCommunities.length) {
      return;
    }

    for (const community of ownedCommunities) {
      const communityId = community._id;
      const nextOwner = await CommunityMemberService.getNextOwnerCandidate(communityId, userId);
      if (!nextOwner?.user?._id) {
        await CommunityMemberService.removeAllMembersForCommunity(communityId);

        await CommunityDAO.deleteCommunity(communityId);

        continue;
      }

      const nextOwnerId = nextOwner.user._id;
      await CommunityDAO.updateOwner(communityId, nextOwnerId);

      await CommunityMemberService.updateMemberRole(communityId, nextOwnerId, "owner");
    }
  },
};

module.exports = CommunityService;