const CommentDAO = require('../../../../dao/commentDAO');
const PostDAO = require('../../../../dao/postDAO');
const CommentMapper = require('./CommentMapper');
const CommentAssembler = require('./CommentAssembler');


// TODO : Feed is aggregat root so systemmanager should manage to feed instead of managing feed, post, comment, etc
// As a result, feed will be called in order to use post methods, and post will be called in order to use
// comment methods. So postDAO won't be imported here anymore 

const {
  NotFoundError,
  UnauthorizedError,
  ValidationError
} = require('../../../../exceptions');

const CommentService = {
  async addComment(user, commentData) {
    const parentCommentId =
      commentData.parentCommentId ?? null;

    const doc = await CommentDAO.createComment({
      post: commentData.postId,
      content: commentData.text.trim(),
      author: user.id,
      parentComment: parentCommentId,
    });

    if (parentCommentId) {
      await CommentDAO.incrementReplies(parentCommentId);
    }

    await PostDAO.incrementComments(commentData.postId);

    const comment =
      CommentMapper.fromPersistence(doc);

    return CommentAssembler.toDTO(
      comment,
      user.id
    );
  },

  async getCommentsByPost(postId, currentUserId) {
    const docs =
      await CommentDAO.getCommentsByPost(postId);

    const comments =
      CommentMapper.fromPersistenceList(docs);

    return CommentAssembler.toDTOList(
      comments,
      currentUserId
    );
  },

  async likeComment(user, commentId) {
    const liked =
      await CommentDAO.hasLiked(
        commentId,
        user.id
      );

    const updated = liked
      ? await CommentDAO.removeLike(
          commentId,
          user.id
        )
      : await CommentDAO.addLike(
          commentId,
          user.id
        );

    if (!updated) {
      throw new NotFoundError(
        "Comment not found"
      );
    }

    const comment =
      CommentMapper.fromPersistence(updated);

    return CommentAssembler.toDTO(
      comment,
      user.id
    );
  },

    async updateComment(user, commentId, text) {
    const comment =
      await CommentService._getCommentDomainById(
        commentId
      );

    if (!comment.canEdit(user.id)) {
      throw new UnauthorizedError(
        "You can only edit your own comments"
      );
    }

    const trimmed = text?.trim();

    if (!trimmed) {
      throw new ValidationError(
        "Comment text cannot be empty."
      );
    }

    const updated =
      await CommentDAO.updateComment(
        commentId,
        trimmed
      );

    if (!updated) {
      throw new NotFoundError(
        "Comment not found"
      );
    }

    const updatedComment =
      CommentMapper.fromPersistence(updated);

    return CommentAssembler.toDTO(
      updatedComment,
      user.id
    );
  },

  async deleteComment(user, commentId) {
    const comment =
      await CommentService._getCommentDomainById(
        commentId
      );

    if (!comment.canEdit(user.id)) {
      throw new UnauthorizedError(
        "You can only delete your own comments"
      );
    }

    const replies =
      await CommentDAO.getReplies(commentId);

    await CommentDAO.deleteComment(commentId);

    if (replies.length > 0) {
      await CommentDAO.deleteManyByIds(
        replies.map((reply) => reply._id)
      );
    }

    await PostDAO.decrementComments(
      comment.post,
      1 + replies.length
    );
  },

  async deleteCommentsByAuthor(user) {
    const docs = await CommentDAO.getCommentsByAuthor(user.id);

    for (const doc of docs) {

      await CommentService.deleteComment(
        user,
        doc._id.toString()
      );
    }
  },

  async removeLikesByUser(userId) {
    await CommentDAO.removeLikesByUser(userId);
  },

  async _getCommentDomainById(commentId) {
    const doc =
      await CommentDAO.getCommentById(
        commentId
      );

    if (!doc) {
      throw new NotFoundError(
        "Comment not found"
      );
    }

    return CommentMapper.fromPersistence(doc);
  },
};

module.exports = CommentService;