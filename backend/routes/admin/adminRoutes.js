const express = require("express");
const router = express.Router();

const asyncHandler =
  require("../../middlewares/asyncHandler");

const adminAuth =
  require("../../middlewares/adminAuth");

const {
  authenticateToken,
} = require("../../middlewares/authMiddleware");

const AdminController =
  require("./adminController");

const {
  validateUsersQuery,
  validateUserId,
  validateAnalyticsEventsQuery,
  validateAnalyticsDauQuery,
  validateAnalyticsRecentQuery,
  validateBroadcast,
} = require("./adminValidator");

// ======================================================
// ADMIN AUTHORIZATION
// ======================================================

router.use(
  authenticateToken,
  adminAuth
);

// ======================================================
// USERS
// ======================================================

router.get(
  "/users",
  validateUsersQuery,
  asyncHandler(
    AdminController.getUsers
  )
);

router.patch(
  "/users/:id/ban",
  validateUserId,
  asyncHandler(
    AdminController.banUser
  )
);

router.patch(
  "/users/:id/unban",
  validateUserId,
  asyncHandler(
    AdminController.unbanUser
  )
);

// ======================================================
// CONTENT MODERATION
// ======================================================

router.delete(
  "/posts/:id",
  validateUserId,
  asyncHandler(
    AdminController.deletePost
  )
);

// ======================================================
// ANALYTICS
// ======================================================

router.get(
  "/analytics/events",
  validateAnalyticsEventsQuery,
  asyncHandler(
    AdminController.getEventCounts
  )
);

router.get(
  "/analytics/dau",
  validateAnalyticsDauQuery,
  asyncHandler(
    AdminController.getDailyActiveUsers
  )
);

router.get(
  "/analytics/recent",
  validateAnalyticsRecentQuery,
  asyncHandler(
    AdminController.getRecentEvents
  )
);

// ======================================================
// BROADCAST
// ======================================================

router.post(
  "/notifications/broadcast",
  validateBroadcast,
  asyncHandler(
    AdminController.broadcastNotification
  )
);

module.exports = router;