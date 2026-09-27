const RequestModel = require("../schemas/requestSchema");

const {
  RequestStatus,
} = require("../domain/request/enums/requestEnums");

const RequestDAO = {

  async create(data) {
    return await new RequestModel(data).save();
  },

  async getReceivedRequests(userId) {
    return await RequestModel.find({
      recipient: userId,
      status: RequestStatus.PENDING,
    })
      .populate(
        "sender",
        "firstName lastName profilePicture"
      )
      .populate(
        "recipient",
        "firstName lastName profilePicture"
      )
      .populate(
        "community",
        "name coverImage owner"
      )
      .sort({
        createdAt: -1,
      })
      .lean();
  },

  async getSentRequests(userId) {
    return await RequestModel.find({
      sender: userId,
      status: RequestStatus.PENDING,
    })
      .populate(
        "recipient",
        "firstName lastName profilePicture"
      )
      .populate(
        "community",
        "name coverImage"
      )
      .sort({
        createdAt: -1,
      })
      .lean();
  },

  async deleteRequestsForUser(userId) {
    if (!userId) {
      return;
    }

    return await RequestModel.deleteMany({
      $or: [
        { sender: userId },
        { recipient: userId },
      ],
    });
  },

  async getRequestById(requestId) {
    return await RequestModel.findById(requestId)
      .populate(
        "sender",
        "firstName lastName profilePicture"
      )
      .populate(
        "recipient",
        "firstName lastName profilePicture"
      )
      .populate(
        "community",
        "name coverImage"
      )
      .lean();
  },

  async findPendingRequest(
    senderId,
    recipientId,
    type
  ) {
    return await RequestModel.findOne({
      sender: senderId,
      recipient: recipientId,
      type,
      status: RequestStatus.PENDING,
    }).lean();
  },

  async updateRequestStatus(
    requestId,
    status
  ) {
    return await RequestModel.findByIdAndUpdate(
      requestId,
      {
        status,
      },
      {
        new: true,
      }
    ).lean();
  },

  async updateRequestByTypeAndRef(
    type,
    communityId,
    userId,
    status
  ) {
    return await RequestModel.findOneAndUpdate(
      {
        type,
        community: communityId,
        sender: userId,
        status: RequestStatus.PENDING,
      },
      {
        status,
      },
      {
        new: true,
      }
    ).lean();
  },

  async getPendingFriendRequestsSentTo(
    senderId,
    recipientIds
  ) {
    if (!recipientIds?.length) {
      return [];
    }

    return await RequestModel.find({
      sender: senderId,
      recipient: { $in: recipientIds },
      type: 'friend',
      status: RequestStatus.PENDING,
    })
      .select('recipient')
      .lean();
  },

  async getPendingCommunityRequestsSentTo(
    senderId,
    communityIds
  ) {
    if (!communityIds?.length) {
      return [];
    }

    return await RequestModel.find({
      sender: senderId,
      community: { $in: communityIds },
      type: 'community',
      status: RequestStatus.PENDING,
    })
      .select('community')
      .lean();
  },
};

module.exports = RequestDAO;