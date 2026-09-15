const express = require("express");

const router = express.Router();

const ActivityController =
    require("./activityController");

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

// ======================================================
// GET ALL ACTIVITIES
// ======================================================

router.get(
    "/",
    ...auth,
    asyncHandler(ActivityController.getAll)
);

module.exports = router;