const FriendService = require("../user/friend/FriendService");
const PostService = require("./post/PostService");
const UserService = require("../user/UserService");

const FeedService = {
  async getUserFeed(userId, options = {}) {
    const [
      friendIds,
      communityIds,
    ] = await Promise.all([
      FriendService.getFriendIds(userId),
      UserService.getUserCommunityIds(userId),
    ]);

    const filter = {
      isDeleted: { $ne: true },

      $or: [
        {
          author: userId,
        },

        {
          visibility: "friends",
          author: { $in: friendIds },
        },
        {
          visibility: "community",
          community: { $in: communityIds },
        },
      ],
    };

    const page = Math.max(
      1,
      parseInt(options.page, 10) || 1
    );

    const limit = Math.min(
      50,
      Math.max(1, parseInt(options.limit, 10) || 20)
    );

    const skip = (page - 1) * limit;

    return await PostService.getFeedPosts(
      filter,
      { limit, skip },
      userId
    );
  },
};

module.exports = FeedService;