const express = require("express");

const router = express.Router();

const asyncHandler =
  require("../../../../middlewares/asyncHandler");

const socialAuth =
  require("../../socialAuth");

const PostController =
  require("./postController");

const {
  validateCreatePost,
  validatePostId,
} = require("./postValidator");

router.use(socialAuth);

// ============================================================
// CREATE POST
// ============================================================

router.post(
  "/",
  validateCreatePost,
  asyncHandler(
    PostController.createPost
  )
);

// ============================================================
// GET SINGLE POST
// ============================================================

router.get(
  "/:id",
  validatePostId,
  asyncHandler(
    PostController.getPost
  )
);

// ============================================================
// LIKE / UNLIKE
// ============================================================

router.post(
  "/:id/like",
  validatePostId,
  asyncHandler(
    PostController.likePost
  )
);

// ============================================================
// DELETE
// ============================================================

router.delete(
  "/:id",
  validatePostId,
  asyncHandler(
    PostController.deletePost
  )
);

// ============================================================
// COMMENTS
// ============================================================

router.get(
  "/:id/comments",
  validatePostId,
  asyncHandler(
    PostController.getComments
  )
);

router.put("/:id", validatePostId, asyncHandler(PostController.updatePost));
router.delete("/:id", validatePostId, asyncHandler(PostController.deletePost));


module.exports = router;