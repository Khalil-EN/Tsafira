const express = require("express");

const router = express.Router();

const asyncHandler = require("../../../middlewares/asyncHandler");

const socialAuth = require("../socialAuth");

const MessagingController = require("./messagingController");

const {
  validateParticipant,
  validateConversationId,
  validateSendMessage,
} = require("./messagingValidator");

router.use(socialAuth);

router.get(
  "/chats",
  asyncHandler(
    MessagingController.getInbox
  )
);

router.post(
  "/chats",
  validateParticipant,
  asyncHandler(
    MessagingController.getOrCreateDirectChat
  )
);

router.get(
  "/chats/:conversationId/messages",
  validateConversationId,
  asyncHandler(
    MessagingController.getMessages
  )
);

router.post(
  "/chats/:conversationId/read",
  validateConversationId,
  asyncHandler(
    MessagingController.markConversationAsRead
  )
);

router.post(
  "/messages",
  validateSendMessage,
  asyncHandler(
    MessagingController.sendMessage
  )
);

module.exports = router;