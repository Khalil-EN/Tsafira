const PostDAO = require('../../../dao/postDAO');
const PostMapper = require('./PostMapper');
const PostAssembler = require('./PostAssembler');

const PostVisibilityPolicy = require(
  "../../../domain/posts/PostVisibilityPolicy"
);

const CommentService = require('./comment/CommentService');

const {
  NotFoundError,
  UnauthorizedError,
} = require('../../../exceptions/Apperror');

const PostService = {

  async createPost(user, postData) {
    const post = PostAssembler.toDomain({
      ...postData,
      author: user.id,
    });

    post.validateVisibility();

    const doc = await PostDAO.createPost({
      author: user.id,
      community: post.community,
      text: post.text,
      images: post.images,
      visibility: post.visibility,
    });

    const savedPost =
      PostMapper.fromPersistence(doc);

    return PostAssembler.toDTO(
      savedPost,
      user.id
    );
  },

  async getPostById(user, postId, friendIds, communityIds) {
    const post =
      await PostService._getPostDomainById(postId);

    PostVisibilityPolicy.assertCanView(
      post,
      user.id,
      friendIds,
      communityIds
    );

    return PostAssembler.toDTO(
      post,
      user.id
    );
  },


    async getFeedPosts(filter, options = {}, currentUserId = null) {
    const docs = await PostDAO.getPosts(filter, options);
    const posts = PostMapper.fromPersistenceList(docs);
    return PostAssembler.toDTOList(posts, currentUserId);
  },

  async getCommunityFeed(userId, communityId, options = {}) {
    const docs = await PostDAO.getPostsByCommunity(communityId, options);
    const posts = PostMapper.fromPersistenceList(docs);
    return PostAssembler.toDTOList(posts, userId);
  },

  // ============================================================
  // LIKE / UNLIKE
  // ============================================================

  async likePost(user, postId, friendIds, communityIds) {
    const post =
      await PostService._getPostDomainById(
        postId
      );

    PostVisibilityPolicy.assertCanView(
      post,
      user.id,
      friendIds,
      communityIds
    );

    const liked =
      await PostDAO.hasLiked(
        postId,
        user.id
      );

    const updated =
      liked
        ? await PostDAO.removeLike(
            postId,
            user.id
          )
        : await PostDAO.addLike(
            postId,
            user.id
          );

    if (!updated) {
      throw new NotFoundError(
        "Post not found"
      );
    }

    const updatedPost =
      PostMapper.fromPersistence(updated);

    return PostAssembler.toDTO(
      updatedPost,
      user.id
    );
  },

  // ============================================================
  // DELETE
  // ============================================================

  async deletePost(user, postId) {
    const post =
      await PostService._getPostDomainById(
        postId
      );

    const isAdmin =
      user?.role === "admin";

    const canDeleteOwnPost =
      post.canDelete(user?.id);

    if (
      !isAdmin &&
      !canDeleteOwnPost
    ) {
      throw new UnauthorizedError(
        "You can only delete your own posts."
      );
    }

    return await PostDAO.deletePost(
      postId
    );
  },

   async updatePost(user, postId, updateData) {
    const post =
        await PostService._getPostDomainById(postId);

    if (!post.canEdit(user.id)) {
        throw new UnauthorizedError(
            "You can only edit your own posts."
        );
    }

    post.editContent(updateData);

    const updated =
        await PostDAO.updatePost(
            postId,
            PostMapper.toPersistence(post)
        );

    if (!updated) {
        throw new NotFoundError("Post not found");
    }

    const updatedPost =
        PostMapper.fromPersistence(updated);

    return PostAssembler.toDTO(
        updatedPost,
        user.id
    );
  },

  async deletePostsByCommunity(communityId) {
    const postIds =
      await PostDAO.getPostIdsByCommunity(communityId);

    if (postIds.length) {
      await CommentService.deleteCommentsByPostIds(postIds);
    }

    await PostDAO.deleteManyByCommunity(communityId);
  },

  async deleteUserPosts(userId) {
    const postIds =
      await PostDAO.getPostIdsByAuthor(userId);

    if (postIds.length) {
      await CommentService.deleteCommentsByPostIds(postIds);
    }

    await PostDAO.deleteManyByAuthor(userId);
  },

  async removeLikesByUser(userId) {
    await PostDAO.removeLikesByUser(userId);
  },

  // ============================================================
  // AUTHORIZATION
  // ============================================================

  async assertCanView(userId, postId, friendIds, communityIds) {

    const post =
      await PostService._getPostDomainById(postId);

    PostVisibilityPolicy.assertCanView(
      post,
      userId,
      friendIds,
      communityIds
    );
  },

  // ============================================================
  // INTERNAL POST LOADER
  // ============================================================

  async _getPostDomainById(id) {
    const doc =
      await PostDAO.getPostById(id);

    if (!doc) {
      throw new NotFoundError(
        "Post not found"
      );
    }

    return PostMapper.fromPersistence(doc);
  },
};

module.exports = PostService;