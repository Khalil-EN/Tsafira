const express = require("express");

const router = express.Router();

const asyncHandler =
    require("../../../../../middlewares/asyncHandler");

const socialAuth =
    require("../../../socialAuth");

const CommentController =
    require("./commentController");

const {
    validateCreateComment,
    validateCommentId,
} = require("./commentValidator");

router.use(socialAuth);

// POST /comments
router.post(
    "/",
    validateCreateComment,
    asyncHandler(
        CommentController.createComment
    )
);

// POST /comments/:id/like
router.post(
    "/:id/like",
    validateCommentId,
    asyncHandler(
        CommentController.likeComment
    )
);

// DELETE /comments/:id
router.delete(
    "/:id",
    validateCommentId,
    asyncHandler(
        CommentController.deleteComment
    )
);

// PUT /comments/:id
router.put(
    "/:id",
    validateCommentId,
    asyncHandler(
        CommentController.updateComment
    )
);

module.exports = router;