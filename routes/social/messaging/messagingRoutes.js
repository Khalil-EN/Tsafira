const express = require("express");

const router = express.Router();

const asyncHandler =
  require("../../../middlewares/asyncHandler");

const socialAuth =
  require("../../../backend/routes/social/socialAuth");

const MessagingController =
  require("./messagingController");

const {
  validateParticipant,
  validateConversationId,
  validateSendMessage,
} = require("./messagingValidator");

router.use(socialAuth);

// GET /chats
router.get(
  "/chats",
  asyncHandler(
    MessagingController.getInbox
  )
);

// POST /chats
router.post(
  "/chats",
  validateParticipant,
  asyncHandler(
    MessagingController.getOrCreateDirectChat
  )
);

// GET /chats/:conversationId/messages
router.get(
  "/chats/:conversationId/messages",
  validateConversationId,
  asyncHandler(
    MessagingController.getMessages
  )
);

// POST /chats/:conversationId/read
router.post(
  "/chats/:conversationId/read",
  validateConversationId,
  asyncHandler(
    MessagingController.markConversationAsRead
  )
);

// POST /messages
router.post(
  "/messages",
  validateSendMessage,
  asyncHandler(
    MessagingController.sendMessage
  )
);

module.exports = router;