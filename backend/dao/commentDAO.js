const CommentModel = require("../schemas/commentSchema");

const CommentDAO = {
  async createComment(commentData) {
    const comment = await CommentModel.create(commentData);

    return await CommentModel.findById(comment._id)
      .populate(
        "author",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  async getCommentsByPost(postId) {
    return await CommentModel.find({
      post: postId,
      isDeleted: false,
    })
      .populate(
        "author",
        "firstName lastName profilePicture"
      )
      .sort({ createdAt: 1 })
      .lean();
  },

  async getCommentById(commentId) {
    return await CommentModel.findById(commentId)
      .populate(
        "author",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  async deleteComment(commentId) {
    return await CommentModel.findByIdAndUpdate(
      commentId,
      {
        isDeleted: true,
      },
      {
        new: true,
      }
    ).lean();
  },

  async addLike(commentId, userId) {
    return await CommentModel.findByIdAndUpdate(
      commentId,
      {
        $addToSet: {
          likes: userId,
        },
      },
      {
        new: true,
      }
    )
      .populate(
        "author",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  async removeLike(commentId, userId) {
    return await CommentModel.findByIdAndUpdate(
      commentId,
      {
        $pull: {
          likes: userId,
        },
      },
      {
        new: true,
      }
    )
      .populate(
        "author",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  async hasLiked(commentId, userId) {
    const comment = await CommentModel.findOne({
      _id: commentId,
      likes: userId,
    })
      .select("_id")
      .lean();

    return !!comment;
  },

  async incrementReplies(commentId) {
    return await CommentModel.findByIdAndUpdate(
      commentId,
      {
        $inc: {
          repliesCount: 1,
        },
      },
      {
        new: true,
      }
    ).lean();
  },

  async decrementReplies(commentId) {
    return await CommentModel.findByIdAndUpdate(
      commentId,
      {
        $inc: {
          repliesCount: -1,
        },
      },
      {
        new: true,
      }
    ).lean();
  },

    async updateComment(commentId, content) {
    return await CommentModel.findByIdAndUpdate(
      commentId,
      {
        content,
        isEdited: true,
      },
      {
        new: true,
      }
    )
      .populate(
        "author",
        "firstName lastName profilePicture"
      )
      .lean();
  },

  async getReplies(parentCommentId) {
    return await CommentModel.find({
      parentComment: parentCommentId,
      isDeleted: false,
    })
      .select("_id")
      .lean();
  },

  async deleteManyByIds(commentIds) {
    return await CommentModel.updateMany(
      {
        _id: { $in: commentIds },
      },
      {
        isDeleted: true,
      }
    );
  },

  async getCommentsByAuthor(userId) {
    return await CommentModel.find({
      author: userId,
      isDeleted: false,
    }).lean();
  },

  async deleteCommentAndReplies(commentId) {
    const result = await CommentModel.updateMany(
      {
        $or: [
          { _id: commentId },
          { parentComment: commentId },
        ],
      },
      {
        isDeleted: true,
      }
    );

    return result;
  },

  async removeLikesByUser(userId) {
    return await CommentModel.updateMany(
      {
        likes: userId,
      },
      {
        $pull: {
          likes: userId,
        },
      }
    );
  },
};

module.exports = CommentDAO;