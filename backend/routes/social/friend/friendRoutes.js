const express = require("express");

const router = express.Router();

const asyncHandler = require("../../../middlewares/asyncHandler");

const socialAuth = require("../socialAuth");

const FriendController = require("./friendController");

const {
    validateSendFriendRequest,
} = require("./friendValidator");

router.use(socialAuth);

router.post(
    "/request",
    validateSendFriendRequest,
    asyncHandler(
        FriendController.sendFriendRequest
    )
);

router.get(
    "/",
    asyncHandler(
        FriendController.getFriends
    )
);

module.exports = router;