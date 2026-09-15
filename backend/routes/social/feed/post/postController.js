const systemManager =
  require("../../../../system/SystemManager");

const PostController = {
  // ============================================================
  // CREATE
  // ============================================================

  async createPost(req, res) {
    const post =
      await systemManager.createPost(
        req.user,
        req.body
      );

    return res.status(201).json({
      success: true,
      data: post,
    });
  },

  // ============================================================
  // GET SINGLE POST
  // ============================================================

  async getPost(req, res) {
    const post =
      await systemManager.getPostById(
        req.user,
        req.params.id
      );

    return res.status(200).json({
      success: true,
      data: post,
    });
  },


  // ============================================================
  // LIKE
  // ============================================================

  async likePost(req, res) {
    const post =
      await systemManager.likePost(
        req.user,
        req.params.id
      );

    return res.status(200).json({
      success: true,
      data: post,
    });
  },

  // ============================================================
  // DELETE
  // ============================================================

  async updatePost(req, res) {
    const post = await systemManager.updatePost(
        req.user,
        req.params.id,
        req.body
    );

    return res.status(200).json({
        success: true,
        data: post,
    });
  },

  async deletePost(req, res) {
    await systemManager.deletePost(req.user, req.params.id);

    return res.status(200).json({
        success: true,
        data: { message: "Post deleted." },
    });
  },

  // ============================================================
  // COMMENTS
  // ============================================================

  async getComments(req, res) {
    const comments =
      await systemManager.getCommentsByPost(
        req.user,
        req.params.id
      );

    return res.status(200).json({
      success: true,
      data: comments,
    });
  },
};

module.exports = PostController;