const express = require("express");

const router = express.Router();

const RestaurantController =
    require("./restaurantController");

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
// GET ALL RESTAURANTS
// ======================================================

router.get(
    "/",
    ...auth,
    asyncHandler(RestaurantController.getAll)
);

module.exports = router;