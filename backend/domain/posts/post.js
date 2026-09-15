const {
    ValidationError,
} = require("../../exceptions");

class Post {
  constructor({
    id,
    author,
    community = null,
    text,
    images = [],
    visibility = 'community',
    likes = [],
    likesCount = 0,
    commentsCount = 0,
    isEdited = false,
    isDeleted = false,
    createdAt,
    updatedAt,
  }) {
    this.id = id;
    this.author = author;
    this.community = community;
    this.text = text;
    this.images = images;
    this.visibility = visibility;
    this.likes = likes;
    this.likesCount = likesCount;
    this.commentsCount = commentsCount;
    this.isEdited = isEdited;
    this.isDeleted = isDeleted;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  isAuthor(userId) {
    if (!userId || !this.author) {
      return false;
    }

    const authorId =
      this.author._id?.toString() ??
      this.author.id?.toString() ??
      this.author.toString();

    return authorId === userId.toString();
  }

  canEdit(userId) {
    return this.isAuthor(userId);
  }

  canDelete(userId) {
    return this.isAuthor(userId);
  }

  editContent({ text, images }) {
    if (typeof text === "string") {
        const trimmedText = text.trim();

        if (!trimmedText) {
            throw new ValidationError(
                "Post text cannot be empty."
            );
        }

        this.text = trimmedText;
    }

    if (Array.isArray(images)) {
        this.images = [...images];
    }

    this.isEdited = true;
    this.updatedAt = new Date();
  }

  validateVisibility() {
    if (!["community", "friends", "private"].includes(this.visibility)) {
      throw new ValidationError("Invalid post visibility.");
    }

    if ( this.visibility === "community" && !this.community ) {
      throw new ValidationError( "A community post must belong to a community.");
    }

    if ( (this.visibility === "friends" || this.visibility === "private") && this.community ) {
      throw new ValidationError(
        "Friends and private posts cannot belong to a community."
      );
    }

    return true;
  }

  incrementLikes() {
    this.likesCount++;
  }

  decrementLikes() {
    if (this.likesCount > 0) {
      this.likesCount--;
    }
  }

  incrementComments() {
    this.commentsCount++;
  }

  decrementComments() {
    if (this.commentsCount > 0) {
      this.commentsCount--;
    }
  }

  toJSON() {
    return { ...this };
  }
}

module.exports = Post;