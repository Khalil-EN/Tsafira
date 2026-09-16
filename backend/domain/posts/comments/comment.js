class Comment {
  constructor({
    id,
    post,
    author,
    content,
    parentComment = null,
    likes = [],
    repliesCount = 0,
    isEdited = false,
    isDeleted = false,
    createdAt,
    updatedAt,
  }) {
    this.id = id;
    this.post = post;
    this.author = author;
    this.content = content;
    this.parentComment = parentComment;
    this.likes = likes;
    this.repliesCount = repliesCount;
    this.isEdited = isEdited;
    this.isDeleted = isDeleted;
    this.createdAt = createdAt || new Date();
    this.updatedAt = updatedAt || this.createdAt;
  }

  canEdit(userId) {
    if (!userId || !this.author) return false;

    const authorId =
      this.author._id?.toString() ??
      this.author.id?.toString() ??
      this.author.toString();

    return authorId === userId.toString();
  }

  isReply() {
    return this.parentComment != null;
  }

  getLikesCount() {
    return Array.isArray(this.likes) ? this.likes.length : 0;
  }

  toJSON() {
    return { ...this };
  }
}

module.exports = Comment;