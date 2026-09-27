const RequestDAO = require("../../dao/requestDAO");
const RequestHandlerRegistry = require("../../domain/request/RequestHandlerRegistry");

const {RequestType, RequestStatus} = require("../../domain/request/enums/requestEnums");

const {assembleRequests} = require("./RequestAssembler");

const NotFoundError = require("../../exceptions/NotFoundError");

const FriendService = require("../user/friend/FriendService");

const CommunityService = require("../community/CommunityService");

// TODO : This must be refactored by using the chain of responsability pattern correctly


RequestHandlerRegistry.register(
  RequestType.FRIEND,
  {
    async onAccept(request) {
      await FriendService.addFriend(request.sender._id, request.recipient._id);
    },
  }
);

RequestHandlerRegistry.register(
  RequestType.COMMUNITY,
  {
    async onAccept(request) {
      const communityId = request.community?._id;
      const userId = request.sender?._id;

      if (!communityId || !userId) {
        throw new Error("Community request is missing community or sender.");
      }

      await CommunityService.addMember(communityId, userId);
    },
  }
);

const RequestService = {

  async getRequests(userId) {

    const [received, sent] = await Promise.all([RequestDAO.getReceivedRequests(userId),
                                                RequestDAO.getSentRequests(userId),
    ]);

    return assembleRequests({received, sent});
  },

  async acceptRequest(requestId) {
    const request = await RequestDAO.getRequestById(requestId);

    if (!request || request.status !== RequestStatus.PENDING) {
        throw new NotFoundError("Request not found or already handled");
    }

    await RequestHandlerRegistry.dispatch(request);

    await RequestDAO.updateRequestStatus(requestId, RequestStatus.ACCEPTED);

    return request;
  },

  async rejectRequest(requestId) {
    const request = await RequestDAO.getRequestById(requestId);

    if (!request || request.status !== RequestStatus.PENDING) {
      throw new NotFoundError("Request not found or already handled");
    }

    await RequestDAO.updateRequestStatus(requestId, RequestStatus.REJECTED);
  },

  async deleteRequestsForUser(userId) {
    return await RequestDAO.deleteRequestsForUser(userId);
  },
};

module.exports = RequestService;