const {
  UserPreviewDTO,
} = require("./UserPreviewDTO");

// ============================================================================
// RECEIVED REQUEST
// ============================================================================

function ReceivedRequestDTO(request) {
  if (!request) {
    return null;
  }

  const isCommunity =
    request.type === "community";

  return {
    requestId:
      request._id?.toString() ??
      request.id,

    type:
      request.type,

    status:
      request.status,

    createdAt:
      request.createdAt,

    from:
      UserPreviewDTO(
        request.sender
      ),

    // Useful for community requests.
    community:
      isCommunity &&
      request.community
        ? {
            id:
              request.community._id
                ?.toString() ??
              request.community.id
                ?.toString() ??
              null,

            name:
              request.community.name ??
              "Community",

            coverImage:
              request.community.coverImage ??
              null,
          }
        : null,
  };
}

// ============================================================================
// SENT REQUEST
// ============================================================================

function SentRequestDTO(request) {
  if (!request) {
    return null;
  }

  const isCommunity =
    request.type === "community";

  let to = null;

  // --------------------------------------------------------------------------
  // COMMUNITY REQUEST
  // --------------------------------------------------------------------------

  if (isCommunity) {
    const community =
      request.community;

    to = {
      id:
        community?._id?.toString() ??
        community?.id?.toString() ??
        null,

      type:
        "community",

      name:
        community?.name ??
        "Community",

      coverImage:
        community?.coverImage ??
        null,
    };
  }

  // --------------------------------------------------------------------------
  // FRIEND REQUEST
  // --------------------------------------------------------------------------

  else {
    const user =
      request.recipient;

    to = {
      id:
        user?._id?.toString() ??
        user?.id?.toString() ??
        null,

      type:
        "user",

      fullName:
        `${user?.firstName ?? ""} ${
          user?.lastName ?? ""
        }`.trim(),

      profilePicture:
        user?.profilePicture ??
        null,
    };
  }

  return {
    requestId:
      request._id?.toString() ??
      request.id,

    type:
      request.type,

    status:
      request.status,

    createdAt:
      request.createdAt,

    to,
  };
}

module.exports = {
  ReceivedRequestDTO,
  SentRequestDTO,
};