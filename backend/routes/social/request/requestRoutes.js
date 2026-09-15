const express = require("express");

const router = express.Router();

const asyncHandler =
    require("../../../middlewares/asyncHandler");

const socialAuth =
    require("../socialAuth");

const RequestController =
    require("./requestController");

const {
    validateRequestId,
} = require("./requestValidator");

router.use(socialAuth);

// GET /requests
router.get(
    "/",
    asyncHandler(
        RequestController.getRequests
    )
);

// POST /requests/:id/accept
router.post(
    "/:id/accept",
    validateRequestId,
    asyncHandler(
        RequestController.acceptRequest
    )
);

// POST /requests/:id/reject
router.post(
    "/:id/reject",
    validateRequestId,
    asyncHandler(
        RequestController.rejectRequest
    )
);

module.exports = router;