class PostDTO {
  constructor({
    id,
    text,
    images = [],
    visibility,
    author = null,
    community = null,
    likesCount = 0,
    liked = false,
    commentsCount = 0,
    isEdited = false,
    createdAt = null,
  }) {
    this.id = id;
    this.text = text;
    this.images = images;
    this.visibility = visibility;
    this.author = author;
    this.community = community;
    this.likesCount = likesCount;
    this.liked = liked;
    this.commentsCount = commentsCount;
    this.isEdited = isEdited;
    this.createdAt = createdAt;

    Object.freeze(this);
  }
}

module.exports = PostDTO;