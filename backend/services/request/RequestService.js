const RequestDAO = require("../../dao/requestDAO");
const RequestHandlerRegistry =
  require(
    "../../domain/request/RequestHandlerRegistry"
  );

const {
  RequestType,
  RequestStatus,
} =
  require(
    "../../domain/request/enums/requestEnums"
  );

const {
  assembleRequests,
} =
  require("./RequestAssembler");

const NotFoundError =
  require(
    "../../exceptions/NotFoundError"
  );

const FriendService =
  require(
    "../user/friend/FriendService"
  );

const CommunityService =
  require(
    "../community/CommunityService"
  );

// ============================================================================
// FRIEND REQUEST HANDLER
// ============================================================================

RequestHandlerRegistry.register(
  RequestType.FRIEND,
  {
    async onAccept(request) {
      await FriendService.addFriend(
        request.sender._id,
        request.recipient._id
      );
    },
  }
);

// ============================================================================
// COMMUNITY REQUEST HANDLER
// ============================================================================

RequestHandlerRegistry.register(
  RequestType.COMMUNITY,
  {
    async onAccept(request) {
      const communityId =
        request.community?._id;

      const userId =
        request.sender?._id;

      if (!communityId || !userId) {
        throw new Error(
          "Community request is missing community or sender."
        );
      }

      await CommunityService.addMember(
        communityId,
        userId
      );
    },
  }
);

// ============================================================================
// SERVICE
// ============================================================================

const RequestService = {
  // ==========================================================================
  // GET REQUESTS
  // ==========================================================================

  async getRequests(userId) {
    const [
      received,
      sent,
    ] = await Promise.all([
      RequestDAO.getReceivedRequests(
        userId
      ),

      RequestDAO.getSentRequests(
        userId
      ),
    ]);

    return assembleRequests({
      received,
      sent,
    });
  },

  // ==========================================================================
  // ACCEPT
  // ==========================================================================

  async acceptRequest(requestId) {
    const request = await RequestDAO.getRequestById(requestId);

    if (
        !request ||
        request.status !== RequestStatus.PENDING
    ) {
        throw new NotFoundError(
            "Request not found or already handled"
        );
    }

    await RequestHandlerRegistry.dispatch(request);

    await RequestDAO.updateRequestStatus(
        requestId,
        RequestStatus.ACCEPTED
    );

    return request;
  },
  // ==========================================================================
  // REJECT
  // ==========================================================================

  async rejectRequest(requestId) {
    const request =
      await RequestDAO.getRequestById(
        requestId
      );

    if (
      !request ||
      request.status !==
        RequestStatus.PENDING
    ) {
      throw new NotFoundError(
        "Request not found or already handled"
      );
    }

    await RequestDAO.updateRequestStatus(
      requestId,
      RequestStatus.REJECTED
    );
  },

  async deleteRequestsForUser(userId) {
    return await RequestDAO.deleteRequestsForUser(userId);
  },
};

module.exports =
  RequestService;