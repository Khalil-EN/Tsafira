class CommentDTO {
  constructor({
    id,
    postId,
    text,
    author = null,
    parentCommentId = null,
    likesCount = 0,
    liked = false,
    repliesCount = 0,
    isEdited = false,
    createdAt = null,
    updatedAt = null,
  }) {
    this.id = id;
    this.postId = postId;
    this.text = text;
    this.author = author;
    this.parentCommentId = parentCommentId;
    this.likesCount = likesCount;
    this.liked = liked;
    this.repliesCount = repliesCount;
    this.isEdited = isEdited;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;

    Object.freeze(this);
  }
}

module.exports = CommentDTO;