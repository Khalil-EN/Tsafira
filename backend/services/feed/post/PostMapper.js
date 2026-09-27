const Post = require('../../../domain/posts/post');

const PostMapper = {

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

    return docs.map(doc => this.fromPersistence(doc)).filter(Boolean);
  },

  toPersistence(post) {
    if (!post) {
      return null;
    }

    if (typeof post === 'object' && !post.constructor?.name?.includes('Post')) {
      return post;
    }

    return {
      author: post.author,
      community: post.community,
      text: post.text,
      images: post.images || [],
      visibility: post.visibility || 'community',
      likes: post.likes || [],
      isEdited: post.isEdited || false,
      isDeleted: post.isDeleted || false,
      ...(post.id && { _id: post.id }),
      ...(post.createdAt && { createdAt: post.createdAt }),
      ...(post.updatedAt && { updatedAt: post.updatedAt }),
    };
  },

  toPersistenceForUpdate(post) {
    if (!post) {
      return null;
    }

    if (typeof post === 'object' && !post.constructor?.name?.includes('Post')) {
      return post;
    }

    const updateData = {};
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
    
    updateData.updatedAt = new Date();

    return updateData;
  },


};

module.exports = PostMapper;