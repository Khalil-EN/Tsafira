const express = require("express");

const AIController = require("./aiController");

const router = express.Router();

const asyncHandler = require("../../middlewares/asyncHandler");

const {
    authenticateToken,
    authorizeRoles,
} = require("../../middlewares/authMiddleware");

const auth = [
    authenticateToken,
    authorizeRoles("admin", "premium", "freemium"),
];



router.post(
  "/conversation",
  ...auth,
  asyncHandler(AIController.getOrCreateConversation)
);

router.post(
  "/chat",
  ...auth,
  asyncHandler(AIController.sendMessage)
);


module.exports = router;