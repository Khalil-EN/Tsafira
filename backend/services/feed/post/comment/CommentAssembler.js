const CommentDTO = require("./dto/CommentDTO");

const CommentAssembler = {
  toDTO(comment, currentUserId = null) {
    if (!comment) return null;

    const likes = Array.isArray(comment.likes)
      ? comment.likes
      : [];

    const liked = currentUserId
      ? likes.some(
          userId =>
            userId?.toString() === currentUserId.toString()
        )
      : false;

    return new CommentDTO({
      id: comment.id,

      postId: comment.post,

      text: comment.content,

      author: comment.author
        ? {
            id:
              comment.author._id?.toString() ??
              comment.author.id?.toString() ??
              comment.author.toString(),

            firstName:
              comment.author.firstName ?? null,

            lastName:
              comment.author.lastName ?? null,

            fullName:
              `${comment.author.firstName ?? ""} ${
                comment.author.lastName ?? ""
              }`.trim(),

            profilePicture:
              comment.author.profilePicture ?? null,
          }
        : null,

      parentCommentId:
        comment.parentComment ?? null,

      likesCount:
        likes.length,

      liked,

      repliesCount:
        comment.repliesCount ?? 0,

      isEdited:
        comment.isEdited ?? false,

      createdAt:
        comment.createdAt ?? null,

      updatedAt:
        comment.updatedAt ?? null,
    });
  },

  toDTOList(comments, currentUserId = null) {
    return comments.map(comment =>
      this.toDTO(comment, currentUserId)
    );
  },
};

module.exports = CommentAssembler;