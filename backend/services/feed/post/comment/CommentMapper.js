const Comment =
  require("../../../../domain/posts/comments/comment");

const CommentMapper = {
  fromPersistence(doc) {
    if (!doc) return null;

    return new Comment({
      id: doc._id?.toString() ?? doc.id?.toString(),

      post:
        doc.post?._id?.toString() ??
        doc.post?.id?.toString() ??
        doc.post?.toString(),

      author: doc.author ?? null,

      content: doc.content,

      parentComment:
        doc.parentComment?._id?.toString() ??
        doc.parentComment?.id?.toString() ??
        doc.parentComment?.toString() ??
        null,

      likes: Array.isArray(doc.likes)
        ? [...doc.likes]
        : [],

      repliesCount: doc.repliesCount ?? 0,

      isEdited: doc.isEdited ?? false,

      isDeleted: doc.isDeleted ?? false,

      createdAt: doc.createdAt ?? null,

      updatedAt: doc.updatedAt ?? null,
    });
  },

  fromPersistenceList(docs) {
    if (!Array.isArray(docs)) return [];

    return docs
      .map(doc => this.fromPersistence(doc))
      .filter(Boolean);
  },
};

module.exports = CommentMapper;