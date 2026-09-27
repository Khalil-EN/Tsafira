const CommunityMemberDAO = require("../../../dao/communityMemberDAO");
const CommunityDAO = require("../../../dao/communityDAO");
const RequestDAO = require("../../../dao/requestDAO");

// TODO : Must be refactored. For example : chain of validation for request to join

const CommunityMemberAssembler = require("./CommunityMemberAssembler");


const CommunityMemberMapper = require("./CommunityMemberMapper");

const CommunityMembershipPolicy = require("../../../domain/communities/communityMember/CommunityMembershipPolicy");

const {NotFoundError, UnauthorizedError, ConflictError} = require("../../../exceptions");

const {MemberRole, MemberStatus} = require("../../../domain/communities/enums/communityEnums");

const {RequestStatus} = require("../../../domain/request/enums/requestEnums");

const CommunityMemberService = {

  async getMember(communityId, userId) {

    const doc = await CommunityMemberDAO.getMember(communityId, userId);
    if (!doc) {
      return null;
    }

    return CommunityMemberMapper.fromPersistence(doc);
  },

  async getCommunityMembers(communityId) {

    const docs = await CommunityMemberDAO.getMembersByCommunity(communityId);

    const members = CommunityMemberAssembler.toDTOs(docs);

    return members;
  },

  async getPendingMembers(communityId, actingUserId) {

    const actingMember = await CommunityMemberService.getMember(communityId, actingUserId);

    CommunityMembershipPolicy.assertCanManageMembers(actingMember);

    const docs = await CommunityMemberDAO.getPendingMembersByCommunity(communityId);

    return CommunityMemberAssembler.toDTOs(docs);
  },

  async getUserMemberships(userId) {

    const docs = await CommunityMemberDAO.getUserCommunities(userId);

    return CommunityMemberAssembler.toMembershipDTOs(docs);
  },

  async requestToJoin(userId, communityId) {

    const community = await CommunityDAO.getCommunityById(communityId);
    if (!community) {
      throw new NotFoundError("Community not found.");
    }

    if (community.isActive === false) {
      throw new ConflictError("This community is no longer active.");
    }

    const existing = await CommunityMemberDAO.getMember(communityId, userId);
    if (existing?.status === MemberStatus.ACTIVE) {
      throw new ConflictError("You are already a member of this community.");
    }

    if (existing?.status === MemberStatus.PENDING) {
      throw new ConflictError("Your request to join this community is already pending.");
    }

    if (existing?.status === MemberStatus.BANNED) {
      throw new UnauthorizedError("You cannot join this community.");
    }

    const membership = await CommunityMemberDAO.addMember({user: userId, community: communityId,
                                                           role: MemberRole.MEMBER, sstatus: MemberStatus.PENDING,
      });

    await RequestDAO.create({sender: userId, recipient: null, community: communityId, type: "community",
                             status: RequestStatus.PENDING, relatedMembership: membership._id});
    const member = CommunityMemberMapper.fromPersistence(membership);

    return CommunityMemberAssembler.toDTO(member);
  },

  async addMemberDirectly(communityId, userId, role = MemberRole.MEMBER, options = {}) {

    const {incrementCount = true} = options;

    const existing = await CommunityMemberDAO.getMember(communityId, userId);

    if (existing) {
      const updatedRole = await CommunityMemberDAO.updateMemberRole(communityId, userId, role);
      const updatedStatus = await CommunityMemberDAO.updateMemberStatus(communityId, userId, MemberStatus.ACTIVE);
      const finalDoc = updatedStatus ?? updatedRole;
      const member = CommunityMemberMapper.fromPersistence(finalDoc);

      return CommunityMemberAssembler.toDTO(member);
    }

    const membership = await CommunityMemberDAO.addMember({community: communityId, user: userId, role,
                                                          status: MemberStatus.ACTIVE,
      });

    if (incrementCount) {
      await CommunityDAO.incrementMembersCount(communityId);
    }

    const member = CommunityMemberMapper.fromPersistence(membership);

    return CommunityMemberAssembler.toDTO(member);
  },

  async approveMember(communityId, userId, actingUserId) {

    const actingMember = await CommunityMemberService.getMember(communityId, actingUserId);

    CommunityMembershipPolicy.assertCanManageMembers(actingMember);

    const target = await CommunityMemberDAO.getMember(communityId, userId);
    if (!target) {
      throw new NotFoundError("Membership not found.");
    }

    if (target.status !== MemberStatus.PENDING) {
      throw new ConflictError("This membership is not pending.");
    }

    const updated = await CommunityMemberDAO.updateMemberStatus(communityId, userId, MemberStatus.ACTIVE);

    if (!updated) {
      throw new NotFoundError("Membership could not be activated.");
    }

    await CommunityDAO.incrementMembersCount(communityId);
    await RequestDAO.updateRequestByTypeAndRef("community", communityId, userId, RequestStatus.ACCEPTED);

    const member = CommunityMemberMapper.fromPersistence(updated);

    return CommunityMemberAssembler.toDTO(member);
  },

  async updateMemberRole(communityId, userId, role) {
    return await CommunityMemberDAO.updateMemberRole(communityId, userId, role);
  },

  async rejectMember(communityId, userId, actingUserId) {

    const actingMember = await CommunityMemberService.getMember(communityId, actingUserId);

    CommunityMembershipPolicy.assertCanManageMembers(actingMember);

    const target = await CommunityMemberDAO.getMember(communityId,userId);

    if (!target) {
      throw new NotFoundError("Membership not found.");
    }

    if (target.status !== MemberStatus.PENDING) {
      throw new ConflictError("Only pending memberships can be rejected.");
    }

    await CommunityMemberDAO.removeMember(communityId, userId);
    await RequestDAO.updateRequestByTypeAndRef("community", communityId, userId, RequestStatus.REJECTED);

    return { success: true};
  },

  async promoteMember(communityId, userId, newRole, actingUserId) {

    const actingMember = await CommunityMemberService.getMember(communityId, actingUserId);

    CommunityMembershipPolicy.assertCanPromoteMembers(actingMember);

    const validRoles = [MemberRole.MEMBER, MemberRole.MODERATOR, MemberRole.ADMIN,];

    if (!validRoles.includes(newRole)) {
      throw new ConflictError("Invalid community member role.");
    }

    if (actingUserId.toString() === userId.toString()) {
      throw new ConflictError("You cannot change your own community role.");
    }

    const target = await CommunityMemberDAO.getMember(communityId, userId);
    if (!target) {
      throw new NotFoundError("Membership not found.");
    }

    if (target.role === MemberRole.OWNER) {
      throw new ConflictError("The community owner cannot be promoted.");
    }

    if (target.status !== MemberStatus.ACTIVE) {
      throw new ConflictError("Only active members can be promoted.");
    }

    const updated = await CommunityMemberDAO.updateMemberRole(communityId, userId, newRole);

    if (!updated) {
      throw new NotFoundError("Membership could not be updated.");
    }

    const member = CommunityMemberMapper.fromPersistence(updated);

    return CommunityMemberAssembler.toDTO(member);
  },

  async banMember(communityId, userId, actingUserId) {

    const actingMember = await CommunityMemberService.getMember(communityId, actingUserId);

    CommunityMembershipPolicy.assertCanBanMembers(actingMember);
    if (actingUserId.toString() === userId.toString()) {
      throw new ConflictError("You cannot ban yourself.");
    }

    const target = await CommunityMemberDAO.getMember(communityId, userId);

    if (!target) {
      throw new NotFoundError("Membership not found.");
    }

    if (target.role === MemberRole.OWNER) {
      throw new UnauthorizedError("The community owner cannot be banned.");
    }

    if (target.status === MemberStatus.BANNED) {
      throw new ConflictError("This member is already banned.");
    }

    const wasActive = target.status === MemberStatus.ACTIVE;

    const updated = await CommunityMemberDAO.updateMemberStatus(communityId, userId, MemberStatus.BANNED);

    if (!updated) {
      throw new NotFoundError("Membership could not be updated.");
    }

    if (wasActive) {
      await CommunityDAO.decrementMembersCount(communityId);
    }

    const member = CommunityMemberMapper.fromPersistence(updated);

    return CommunityMemberAssembler.toDTO(member);
  },

  async removeAllMembersForCommunity(communityId) {
    return await CommunityMemberDAO.removeAllMembersForCommunity(communityId);
  },


  async removeAllMembershipsForUser(userId) {

    const activeMemberships = await CommunityMemberDAO.getUserCommunities(userId);

    for (const membership of activeMemberships) {
      const communityId = membership.community?._id?.toString() ?? membership.community?.toString();

      if (communityId) {
        await CommunityDAO.decrementMembersCount(communityId);
      }
    }

    await CommunityMemberDAO.removeAllMembersForUser(userId);
  },

  async removeMember(communityId, userId, actingUserId) {

    const actingMember = await CommunityMemberService.getMember(communityId, actingUserId);

    CommunityMembershipPolicy.assertCanManageMembers(actingMember);

    if (actingUserId.toString() === userId.toString()) {
      throw new ConflictError("You cannot remove yourself through this action.");
    }

    const target = await CommunityMemberDAO.getMember(communityId, userId);

    if (!target) {
      throw new NotFoundError("Membership not found.");
    }

    if (target.role === MemberRole.OWNER) {
      throw new UnauthorizedError("The community owner cannot be removed.");
    }

    const wasActive = target.status === MemberStatus.ACTIVE;
    await CommunityMemberDAO.removeMember(communityId, userId);
    if (wasActive) {
      await CommunityDAO.decrementMembersCount(communityId);
    }

    return {success: true};
  },

  async getNextOwnerCandidate(communityId, userId){
    return await CommunityMemberDAO.getNextOwnerCandidate(communityId, userId);
  },
};

module.exports = CommunityMemberService;