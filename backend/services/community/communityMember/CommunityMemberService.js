const CommunityMemberDAO = require(
  "../../../dao/communityMemberDAO"
);

const CommunityMemberAssembler = require(
  "./CommunityMemberAssembler"
);


const CommunityMemberMapper = require("./CommunityMemberMapper");

const CommunityMembershipPolicy = require(
  "../../../domain/communities/communityMember/CommunityMembershipPolicy"
);

const RequestDAO = require(
  "../../../dao/requestDAO"
);

const CommunityDAO = require(
  "../../../dao/communityDAO"
);

const {
  NotFoundError,
  UnauthorizedError,
  ConflictError,
} = require("../../../exceptions");

const {
  MemberRole,
  MemberStatus,
} = require("../../../domain/communities/enums/communityEnums");

const {
    RequestStatus,
} = require(
    "../../../domain/request/enums/requestEnums"
);

const CommunityMemberService = {
  // ==========================================================================
  // GET MEMBER
  // ==========================================================================

  async getMember(
    communityId,
    userId
  ) {
    const doc =
      await CommunityMemberDAO.getMember(
        communityId,
        userId
      );

    if (!doc) {
      return null;
    }

    return CommunityMemberMapper.fromPersistence(
      doc
    );
  },

  // ==========================================================================
  // GET COMMUNITY MEMBERS
  // ==========================================================================

  async getCommunityMembers(communityId) {
    const docs =
        await CommunityMemberDAO.getMembersByCommunity(
            communityId
        );


      const members =
          CommunityMemberAssembler.toDTOs(docs);

    

      return members;
  },

  async getPendingMembers(communityId, actingUserId) {
    const actingMember = await CommunityMemberService.getMember(
      communityId,
      actingUserId
    );

    CommunityMembershipPolicy.assertCanManageMembers(actingMember);

    const docs = await CommunityMemberDAO.getPendingMembersByCommunity(
      communityId
    );

    return CommunityMemberAssembler.toDTOs(docs);
  },

  // ==========================================================================
  // GET USER COMMUNITIES
  // ==========================================================================

  async getUserMemberships(userId) {
    const docs =
      await CommunityMemberDAO
        .getUserCommunities(userId);

    /*
     * These documents contain populated
     * community data.
     *
     * We intentionally use the membership
     * information from CommunityMember as the
     * authoritative membership state.
     */
    return CommunityMemberAssembler.toMembershipDTOs(
      docs
    );
  },

  // ==========================================================================
  // REQUEST TO JOIN
  // ==========================================================================

  async requestToJoin(
    userId,
    communityId
  ) {
    const community =
      await CommunityDAO.getCommunityById(
        communityId
      );

    if (!community) {
      throw new NotFoundError(
        "Community not found."
      );
    }

    if (community.isActive === false) {
      throw new ConflictError(
        "This community is no longer active."
      );
    }

    const existing =
      await CommunityMemberDAO.getMember(
        communityId,
        userId
      );

    /*
     * Already an active member.
     */
    if (
      existing?.status ===
      MemberStatus.ACTIVE
    ) {
      throw new ConflictError(
        "You are already a member of this community."
      );
    }

    /*
     * Already waiting for approval.
     */
    if (
      existing?.status ===
      MemberStatus.PENDING
    ) {
      throw new ConflictError(
        "Your request to join this community is already pending."
      );
    }

    /*
     * Banned users cannot submit a new request.
     */
    if (
      existing?.status ===
      MemberStatus.BANNED
    ) {
      throw new UnauthorizedError(
        "You cannot join this community."
      );
    }

    /*
     * Keep your current workflow:
     *
     * both public and private communities use
     * a membership request and become active only
     * after approval.
     *
     * If you later want public communities to
     * auto-approve, that can be changed here.
     */
    const membership =
      await CommunityMemberDAO.addMember({
        user: userId,
        community: communityId,
        role: MemberRole.MEMBER,
        status: MemberStatus.PENDING,
      });

    /*
     * Create the corresponding Request record.
     */
    await RequestDAO.create({
      sender: userId,
      recipient: null,
      community: communityId,
      type: "community",
      status: RequestStatus.PENDING,
      relatedMembership:
        membership._id,
    });

    const member =
      CommunityMemberMapper.fromPersistence(
        membership
      );

    return CommunityMemberAssembler.toDTO(
      member
    );
  },

  // ==========================================================================
  // DIRECT MEMBER CREATION
  // ==========================================================================

  async addMemberDirectly(
    communityId,
    userId,
    role = MemberRole.MEMBER,
    options = {}
  ) {
    const {
      incrementCount = true,
    } = options;

    const existing =
      await CommunityMemberDAO.getMember(
        communityId,
        userId
      );

    /*
     * If membership already exists, update it
     * instead of causing the unique compound
     * index to fail.
     */
    if (existing) {
      const updatedRole =
        await CommunityMemberDAO.updateMemberRole(
          communityId,
          userId,
          role
        );

      const updatedStatus =
        await CommunityMemberDAO.updateMemberStatus(
          communityId,
          userId,
          MemberStatus.ACTIVE
        );

      const finalDoc =
        updatedStatus ??
        updatedRole;

      const member =
        CommunityMemberMapper.fromPersistence(
          finalDoc
        );

      return CommunityMemberAssembler.toDTO(
        member
      );
    }

    const membership =
      await CommunityMemberDAO.addMember({
        community: communityId,
        user: userId,
        role,
        status: MemberStatus.ACTIVE,
      });

    if (incrementCount) {
      await CommunityDAO.incrementMembersCount(
        communityId
      );
    }

    const member =
      CommunityMemberMapper.fromPersistence(
        membership
      );

    return CommunityMemberAssembler.toDTO(
      member
    );
  },

  // ==========================================================================
  // APPROVE MEMBER
  // ==========================================================================

  async approveMember(
    communityId,
    userId,
    actingUserId
  ) {
    const actingMember =
      await CommunityMemberService.getMember(
        communityId,
        actingUserId
      );

    CommunityMembershipPolicy
      .assertCanManageMembers(
        actingMember
      );

    const target =
      await CommunityMemberDAO.getMember(
        communityId,
        userId
      );

    if (!target) {
      throw new NotFoundError(
        "Membership not found."
      );
    }

    if (
      target.status !==
      MemberStatus.PENDING
    ) {
      throw new ConflictError(
        "This membership is not pending."
      );
    }

    const updated =
      await CommunityMemberDAO.updateMemberStatus(
        communityId,
        userId,
        MemberStatus.ACTIVE
      );

    if (!updated) {
      throw new NotFoundError(
        "Membership could not be activated."
      );
    }

    /*
     * Now that the membership is active,
     * increase the community count.
     */
    await CommunityDAO.incrementMembersCount(
      communityId
    );

    /*
     * Update the corresponding request.
     */
    await RequestDAO.updateRequestByTypeAndRef(
      "community",
      communityId,
      userId,
      RequestStatus.ACCEPTED
    );

    const member =
      CommunityMemberMapper.fromPersistence(
        updated
      );

    return CommunityMemberAssembler.toDTO(
      member
    );
  },

  async updateMemberRole(
    communityId,
    userId,
    role
  ) {
    return await CommunityMemberDAO.updateMemberRole(
      communityId,
      userId,
      role
    );
  },

  // ==========================================================================
  // REJECT MEMBER
  // ==========================================================================

  async rejectMember(
    communityId,
    userId,
    actingUserId
  ) {
    const actingMember =
      await CommunityMemberService.getMember(
        communityId,
        actingUserId
      );

    CommunityMembershipPolicy
      .assertCanManageMembers(
        actingMember
      );

    const target =
      await CommunityMemberDAO.getMember(
        communityId,
        userId
      );

    if (!target) {
      throw new NotFoundError(
        "Membership not found."
      );
    }

    if (
      target.status !==
      MemberStatus.PENDING
    ) {
      throw new ConflictError(
        "Only pending memberships can be rejected."
      );
    }

    await CommunityMemberDAO.removeMember(
      communityId,
      userId
    );

    /*
     * Update the corresponding request.
     */
    await RequestDAO.updateRequestByTypeAndRef(
      "community",
      communityId,
      userId,
      RequestStatus.REJECTED
    );

    return {
      success: true,
    };
  },

  // ==========================================================================
  // PROMOTE MEMBER
  // ==========================================================================

  async promoteMember(
    communityId,
    userId,
    newRole,
    actingUserId
  ) {
    const actingMember =
      await CommunityMemberService.getMember(
        communityId,
        actingUserId
      );

    CommunityMembershipPolicy
      .assertCanPromoteMembers(
        actingMember
      );

    const validRoles = [
      MemberRole.MEMBER,
      MemberRole.MODERATOR,
      MemberRole.ADMIN,
    ];

    if (
      !validRoles.includes(newRole)
    ) {
      throw new ConflictError(
        "Invalid community member role."
      );
    }

    if (
      actingUserId.toString() ===
      userId.toString()
    ) {
      throw new ConflictError(
        "You cannot change your own community role."
      );
    }

    const target =
      await CommunityMemberDAO.getMember(
        communityId,
        userId
      );

    if (!target) {
      throw new NotFoundError(
        "Membership not found."
      );
    }

    if (
      target.role === MemberRole.OWNER
    ) {
      throw new ConflictError(
        "The community owner cannot be promoted."
      );
    }

    if (
      target.status !==
      MemberStatus.ACTIVE
    ) {
      throw new ConflictError(
        "Only active members can be promoted."
      );
    }

    const updated =
      await CommunityMemberDAO.updateMemberRole(
        communityId,
        userId,
        newRole
      );

    if (!updated) {
      throw new NotFoundError(
        "Membership could not be updated."
      );
    }

    const member =
      CommunityMemberMapper.fromPersistence(
        updated
      );

    return CommunityMemberAssembler.toDTO(
      member
    );
  },

  // ==========================================================================
  // BAN MEMBER
  // ==========================================================================

  async banMember(
    communityId,
    userId,
    actingUserId
  ) {
    const actingMember =
      await CommunityMemberService.getMember(
        communityId,
        actingUserId
      );

    CommunityMembershipPolicy
      .assertCanBanMembers(
        actingMember
      );

    if (
      actingUserId.toString() ===
      userId.toString()
    ) {
      throw new ConflictError(
        "You cannot ban yourself."
      );
    }

    const target =
      await CommunityMemberDAO.getMember(
        communityId,
        userId
      );

    if (!target) {
      throw new NotFoundError(
        "Membership not found."
      );
    }

    if (
      target.role === MemberRole.OWNER
    ) {
      throw new UnauthorizedError(
        "The community owner cannot be banned."
      );
    }

    if (
      target.status ===
      MemberStatus.BANNED
    ) {
      throw new ConflictError(
        "This member is already banned."
      );
    }

    const wasActive =
      target.status ===
      MemberStatus.ACTIVE;

    const updated =
      await CommunityMemberDAO.updateMemberStatus(
        communityId,
        userId,
        MemberStatus.BANNED
      );

    if (!updated) {
      throw new NotFoundError(
        "Membership could not be updated."
      );
    }

    if (wasActive) {
      await CommunityDAO.decrementMembersCount(
        communityId
      );
    }

    const member =
      CommunityMemberMapper.fromPersistence(
        updated
      );

    return CommunityMemberAssembler.toDTO(
      member
    );
  },

  async removeAllMembersForCommunity(communityId) {
    return await CommunityMemberDAO.removeAllMembersForCommunity(communityId);
  },


  async removeAllMembershipsForUser(userId) {

    const activeMemberships =
      await CommunityMemberDAO.getUserCommunities(userId);

    for (const membership of activeMemberships) {
      const communityId =
        membership.community?._id?.toString() ??
        membership.community?.toString();

      if (communityId) {
        await CommunityDAO.decrementMembersCount(communityId);
      }
    }

    await CommunityMemberDAO.removeAllMembersForUser(userId);
  },

  // ==========================================================================
  // REMOVE MEMBER
  // ==========================================================================

  async removeMember(
    communityId,
    userId,
    actingUserId
  ) {
    const actingMember =
      await CommunityMemberService.getMember(
        communityId,
        actingUserId
      );

    CommunityMembershipPolicy
      .assertCanManageMembers(
        actingMember
      );

    if (
      actingUserId.toString() ===
      userId.toString()
    ) {
      throw new ConflictError(
        "You cannot remove yourself through this action."
      );
    }

    const target =
      await CommunityMemberDAO.getMember(
        communityId,
        userId
      );

    if (!target) {
      throw new NotFoundError(
        "Membership not found."
      );
    }

    if (
      target.role === MemberRole.OWNER
    ) {
      throw new UnauthorizedError(
        "The community owner cannot be removed."
      );
    }

    const wasActive =
      target.status ===
      MemberStatus.ACTIVE;

    await CommunityMemberDAO.removeMember(
      communityId,
      userId
    );

    if (wasActive) {
      await CommunityDAO.decrementMembersCount(
        communityId
      );
    }

    return {
      success: true,
    };
  },

  async getNextOwnerCandidate(communityId, userId){
    return await CommunityMemberDAO.getNextOwnerCandidate(communityId, userId);
  },
};

module.exports =
  CommunityMemberService;