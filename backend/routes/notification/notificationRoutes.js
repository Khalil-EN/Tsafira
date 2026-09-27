const express = require("express");

const router = express.Router();

const asyncHandler = require("../../middlewares/asyncHandler");

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

router.get(
    "/",
    ...auth,
    validatePagination,
    asyncHandler(
        NotificationController.getNotifications
    )
);

router.patch(
    "/:id/read",
    ...auth,
    validateNotificationId,
    asyncHandler(
        NotificationController.markAsRead
    )
);


router.patch(
    "/read-all",
    ...auth,
    asyncHandler(
        NotificationController.markAllAsRead
    )
);

router.post(
    "/fcm-token",
    ...auth,
    validateFcmToken,
    asyncHandler(
        NotificationController.saveFcmToken
    )
);


module.exports = router;