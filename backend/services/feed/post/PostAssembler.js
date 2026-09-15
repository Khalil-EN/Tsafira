const PostDTO = require("./dto/PostDTO");
const Post = require("../../../domain/posts/post");

const PostAssembler = {
  toDomain(postData) {
    if (!postData) return null;

    return new Post({
      id: postData.id ?? postData._id ?? null,
      author: postData.author ?? null,
      community: postData.community ?? null,
      text: postData.text,
      images: postData.images ?? [],
      visibility: postData.visibility ?? "community",
      likes: postData.likes ?? [],
      likesCount: postData.likesCount ?? 0,
      commentsCount: postData.commentsCount ?? 0,
      isEdited: postData.isEdited ?? false,
      isDeleted: postData.isDeleted ?? false,
      createdAt: postData.createdAt ?? null,
      updatedAt: postData.updatedAt ?? null,
    });
  },

  toDTO(post, currentUserId = null) {
    if (!post) return null;

    const likes = Array.isArray(post.likes)
      ? post.likes
      : [];

    const liked = currentUserId
      ? likes.some(
          userId =>
            userId?.toString() ===
            currentUserId.toString()
        )
      : false;

    return new PostDTO({
      id: post.id,

      text: post.text,

      images: post.images ?? [],

      visibility: post.visibility,

      author: post.author
        ? {
            id:
              post.author._id?.toString() ??
              post.author.id?.toString() ??
              post.author.toString(),

            firstName:
              post.author.firstName ?? null,

            lastName:
              post.author.lastName ?? null,

            fullName:
              `${post.author.firstName ?? ""} ${
                post.author.lastName ?? ""
              }`.trim(),

            profilePicture:
              post.author.profilePicture ?? null,
          }
        : null,

      community: post.community
        ? {
            id:
              post.community._id?.toString() ??
              post.community.id?.toString(),

            name:
              post.community.name ?? null,
          }
        : null,

      likesCount: likes.length,

      liked,

      commentsCount:
        post.commentsCount ?? 0,

      isEdited:
        post.isEdited ?? false,

      createdAt:
        post.createdAt ?? null,
    });
  },

  toDTOList(posts, currentUserId = null) {
    return posts.map(post =>
      this.toDTO(post, currentUserId)
    );
  },
};

module.exports = PostAssembler;