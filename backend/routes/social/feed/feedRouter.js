const express = require("express");

const router = express.Router();

const asyncHandler =
    require("../../../middlewares/asyncHandler");

const socialAuth =
    require("../socialAuth");

const FeedController =
    require("./feedController");

router.use(socialAuth);

// GET /feed
router.get(
    "/",
    asyncHandler(
        FeedController.getFeed
    )
);

module.exports = router;