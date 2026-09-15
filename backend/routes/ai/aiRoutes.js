const express =
  require("express");

const AIController =
  require("./aiController");

const router =
  express.Router();

  const asyncHandler =
    require("../../middlewares/asyncHandler");

const {
    authenticateToken,
    authorizeRoles,
} = require("../../middlewares/authMiddleware");

const auth = [
    authenticateToken,
    authorizeRoles("admin", "premium", "freemium"),
];


// POST /ai/conversation

router.post(
  "/conversation",
  ...auth,
  asyncHandler(AIController.getOrCreateConversation)
);


// POST /ai/chat

router.post(
  "/chat",
  ...auth,
  asyncHandler(AIController.sendMessage)
);


module.exports =
  router;