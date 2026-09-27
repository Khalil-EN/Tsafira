const express = require("express");

const router = express.Router();

const asyncHandler = require("../../../../../middlewares/asyncHandler");

const socialAuth = require("../../../socialAuth");

const CommentController = require("./commentController");

const {
    validateCreateComment,
    validateCommentId,
} = require("./commentValidator");

router.use(socialAuth);

router.post(
    "/",
    validateCreateComment,
    asyncHandler(
        CommentController.createComment
    )
);

router.post(
    "/:id/like",
    validateCommentId,
    asyncHandler(
        CommentController.likeComment
    )
);

router.delete(
    "/:id",
    validateCommentId,
    asyncHandler(
        CommentController.deleteComment
    )
);

router.put(
    "/:id",
    validateCommentId,
    asyncHandler(
        CommentController.updateComment
    )
);

module.exports = router;