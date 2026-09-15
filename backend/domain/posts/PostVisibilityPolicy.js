const UnauthorizedError= require("../../exceptions/UnauthorizedError");

const PostVisibilityPolicy = {
  canView(
    post,
    userId,
    friendIds = [],
    communityIds = []
  ) {
    if (!post || !userId) {
      return false;
    }

    if (post.isDeleted) {
      return false;
    }

    const currentUserId = userId.toString();

    const authorId =
      post.author?._id?.toString() ??
      post.author?.id?.toString() ??
      post.author?.toString();

    if (authorId === currentUserId) {
      return true;
    }

    if (post.visibility === "private") {
      return false;
    }

    if (post.visibility === "friends") {
      return friendIds.some(
        id => id.toString() === authorId
      );
    }


    if (post.visibility === "community") {
      const communityId =
        post.community?._id?.toString() ??
        post.community?.id?.toString() ??
        post.community?.toString();

      if (!communityId) {
        return false;
      }

      return communityIds.some(
        id => id.toString() === communityId
      );
    }

    return false;
  },

  assertCanView(
    post,
    userId,
    friendIds = [],
    communityIds = []
  ) {
    const allowed = this.canView(
      post,
      userId,
      friendIds,
      communityIds
    );

    console.log(allowed);

    if (!allowed) {
      throw new UnauthorizedError(
        "You are not allowed to access this post."
      );
    }

    return true;
  },
};

module.exports = PostVisibilityPolicy;