const express = require("express");

const router = express.Router();

const ResidenceController =
    require("./residenceController");

const asyncHandler =
    require("../../middlewares/asyncHandler");

const {
    authenticateToken,
    authorizeRoles,
} = require("../../middlewares/authMiddleware");

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
    asyncHandler(ResidenceController.getAll)
);

module.exports = router;