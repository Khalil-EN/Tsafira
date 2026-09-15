const express = require("express");

const router = express.Router();

const asyncHandler =
    require("../../middlewares/asyncHandler");

const {
    authenticateToken,
    authorizeRoles,
} = require("../../middlewares/authMiddleware");

const NotificationController =
    require("./notificationController");

const {
    validateNotificationId,
    validateFcmToken,
    validatePagination,
} = require("./notificationValidator");


const auth = [
    authenticateToken,
    authorizeRoles(
        "admin",
        "premium",
        "freemium"
    ),
];


// ======================================================
// NOTIFICATIONS
// ======================================================

router.get(
    "/",
    ...auth,
    validatePagination,
    asyncHandler(
        NotificationController.getNotifications
    )
);


// ======================================================
// MARK ONE AS READ
// ======================================================

router.patch(
    "/:id/read",
    ...auth,
    validateNotificationId,
    asyncHandler(
        NotificationController.markAsRead
    )
);


// ======================================================
// MARK ALL AS READ
// ======================================================

router.patch(
    "/read-all",
    ...auth,
    asyncHandler(
        NotificationController.markAllAsRead
    )
);


// ======================================================
// FCM TOKEN
// ======================================================

router.post(
    "/fcm-token",
    ...auth,
    validateFcmToken,
    asyncHandler(
        NotificationController.saveFcmToken
    )
);


module.exports = router;