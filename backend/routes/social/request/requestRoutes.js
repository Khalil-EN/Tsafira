const express = require("express");

const router = express.Router();

const asyncHandler = require("../../../middlewares/asyncHandler");

const socialAuth = require("../socialAuth");

const RequestController = require("./requestController");

const {
    validateRequestId,
} = require("./requestValidator");

router.use(socialAuth);

router.get(
    "/",
    asyncHandler(
        RequestController.getRequests
    )
);

router.post(
    "/:id/accept",
    validateRequestId,
    asyncHandler(
        RequestController.acceptRequest
    )
);

router.post(
    "/:id/reject",
    validateRequestId,
    asyncHandler(
        RequestController.rejectRequest
    )
);

module.exports = router;