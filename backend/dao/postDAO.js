const PostModel = require("../schemas/postSchema");

const PostDAO = {
  async createPost(postData) {
    const post = await PostModel.create(postData);

    return await PostModel.findById(post._id)
      .populate("author", "firstName lastName profilePicture")
      .populate("community", "name")
      .lean();
  },

  async getPostById(id) {
    return await PostModel.findById(id)
      .populate("author", "firstName lastName profilePicture")
      .populate("community", "name")
      .lean();
  },

  async getPosts(filter = {}, options = {}) {
    const limit = Number(options.limit) || 20;
    const page = Number(options.page) || 1;
    const skip = (page - 1) * limit;

    return await PostModel.find(filter)
        .populate("author", "firstName lastName profilePicture")
        .populate("community", "name")
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean();
  },

  async getPostsByCommunity(communityId, options = {}) {
      const limit = Number(options.limit) || 20;
      const page = Number(options.page) || 1;
      const skip = (page - 1) * limit;

      return await PostModel.find({
          community: communityId,
          visibility: "community",
          isDeleted: { $ne: true },
      })
          .populate("author", "firstName lastName profilePicture")
          .populate("community", "name")
          .sort({ createdAt: -1 })
          .skip(skip)
          .limit(limit)
          .lean();
  },

  async updatePost(id, updateData) {
    return await PostModel.findByIdAndUpdate(
      id,
      updateData,
      { new: true }
    ).lean();
  },

  async deletePost(id) {
    return await PostModel.findByIdAndDelete(id);
  },

  async addLike(postId, userId) {
    return await PostModel.findByIdAndUpdate(
      postId,
      {
        $addToSet: {
          likes: userId,
        },
      },
      { new: true }
    )
      .populate("author", "firstName lastName profilePicture")
      .populate("community", "name")
      .lean();
  },

  async removeLike(postId, userId) {
    return await PostModel.findByIdAndUpdate(
      postId,
      {
        $pull: {
          likes: userId,
        },
      },
      { new: true }
    )
      .populate("author", "firstName lastName profilePicture")
      .populate("community", "name")
      .lean();
  },

  async hasLiked(postId, userId) {
    const post = await PostModel.findOne({
      _id: postId,
      likes: userId,
    })
      .select("_id")
      .lean();

    return !!post;
  },

  async incrementComments(postId) {
    return await PostModel.findByIdAndUpdate(
      postId,
      {
        $inc: {
          commentsCount: 1,
        },
      },
      { new: true }
    ).lean();
  },

  async decrementComments(postId) {
    return await PostModel.findByIdAndUpdate(
      postId,
      {
        $inc: {
          commentsCount: -1,
        },
      },
      {
        new: true,
      }
    ).lean();
  },
    async getPostIdsByCommunity(communityId) {
    const docs = await PostModel.find({ community: communityId })
      .select("_id")
      .lean();

    return docs.map(doc => doc._id);
  },

  async deleteManyByCommunity(communityId) {
    return await PostModel.deleteMany({ community: communityId });
  },

  async getPostIdsByAuthor(userId) {
    const docs = await PostModel.find({ author: userId })
      .select("_id")
      .lean();

    return docs.map(doc => doc._id);
  },

  async deleteManyByAuthor(userId) {
    return await PostModel.deleteMany({ author: userId });
  },
};

module.exports = PostDAO;