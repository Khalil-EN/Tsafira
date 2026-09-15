const express = require("express");

const router = express.Router();

const asyncHandler =
    require("../../../middlewares/asyncHandler");

const socialAuth =
    require("../socialAuth");

const FriendController =
    require("./friendController");

const {
    validateSendFriendRequest,
} = require("./friendValidator");

router.use(socialAuth);

// POST /friends/request
router.post(
    "/request",
    validateSendFriendRequest,
    asyncHandler(
        FriendController.sendFriendRequest
    )
);

// GET /friends
router.get(
    "/",
    asyncHandler(
        FriendController.getFriends
    )
);

module.exports = router;