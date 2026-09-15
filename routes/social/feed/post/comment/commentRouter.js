const express = require("express");

const router = express.Router();

const asyncHandler =
    require("../../../../middlewares/asyncHandler");

const socialAuth =
    require("../../../../../backend/routes/social/socialAuth");

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

// DELETE /comments/:id
router.delete(
    "/:id",
    validateCommentId,
    asyncHandler(
        CommentController.deleteComment
    )
);

module.exports = router;