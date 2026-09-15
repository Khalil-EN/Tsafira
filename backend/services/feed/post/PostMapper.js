const Post = require('../../../domain/posts/post');

const PostMapper = {
  // ===========================================================================
  // FROM PERSISTENCE (Database to Domain)
  // ===========================================================================
  fromPersistence(doc) {
    if (!doc) {
      return null;
    }

    return new Post({
      id: doc._id?.toString() ?? doc.id?.toString(),
      author: doc.author ?? null,
      community: doc.community ?? null,
      text: doc.text,
      images: Array.isArray(doc.images) ? [...doc.images] : [],
      visibility: doc.visibility ?? 'community',
      likes: Array.isArray(doc.likes) ? [...doc.likes] : [],
      likesCount: Array.isArray(doc.likes) ? doc.likes.length : 0,
      commentsCount: doc.commentsCount ?? 0,
      isEdited: doc.isEdited ?? false,
      isDeleted: doc.isDeleted ?? false,
      createdAt: doc.createdAt ?? null,
      updatedAt: doc.updatedAt ?? null,
    });
  },

  fromPersistenceList(docs) {
    if (!Array.isArray(docs)) {
      return [];
    }

    return docs
      .map(doc => this.fromPersistence(doc))
      .filter(Boolean);
  },

  // ===========================================================================
  // TO PERSISTENCE (Domain to Database) - ADD THIS METHOD
  // ===========================================================================
  toPersistence(post) {
    if (!post) {
      return null;
    }

    // If post is already a plain object, return it directly
    if (typeof post === 'object' && !post.constructor?.name?.includes('Post')) {
      return post;
    }

    // Convert from domain Post object to plain object for database
    return {
      author: post.author,
      community: post.community,
      text: post.text,
      images: post.images || [],
      visibility: post.visibility || 'community',
      likes: post.likes || [],
      isEdited: post.isEdited || false,
      isDeleted: post.isDeleted || false,
      // Handle both domain model and plain object
      ...(post.id && { _id: post.id }),
      ...(post.createdAt && { createdAt: post.createdAt }),
      ...(post.updatedAt && { updatedAt: post.updatedAt }),
    };
  },

  // ===========================================================================
  // TO PERSISTENCE FOR UPDATE (Domain to Database - Partial Updates)
  // ===========================================================================
  toPersistenceForUpdate(post) {
    if (!post) {
      return null;
    }

    // If post is already a plain object, return it with only updateable fields
    if (typeof post === 'object' && !post.constructor?.name?.includes('Post')) {
      return post;
    }

    // Create a clean update object with only the fields that can be updated
    const updateData = {};

    // Only include fields that exist in the domain object
    if (post.text !== undefined) {
      updateData.text = post.text;
    }

    if (post.images !== undefined) {
      updateData.images = post.images;
    }

    if (post.visibility !== undefined) {
      updateData.visibility = post.visibility;
    }

    if (post.likes !== undefined) {
      updateData.likes = post.likes;
    }

    if (post.isEdited !== undefined) {
      updateData.isEdited = post.isEdited;
    }

    if (post.isDeleted !== undefined) {
      updateData.isDeleted = post.isDeleted;
    }

    // Always update the updatedAt timestamp
    updateData.updatedAt = new Date();

    return updateData;
  },


};

module.exports = PostMapper;