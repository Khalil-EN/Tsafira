const express = require("express");

const router = express.Router();

const ItineraryController =
    require("./itineraryController");

const asyncHandler =
    require("../../middlewares/asyncHandler");

const {
    authenticateToken,
    authorizeRoles,
} = require("../../middlewares/authMiddleware");

const {
    validateSuggestedItinerary,
} = require("./itineraryValidator");

const auth = [
    authenticateToken,
    authorizeRoles("admin", "premium", "freemium"),
];

// ======================================================
// GENERATE SUGGESTED ITINERARY
// ======================================================

router.post(
    "/suggest",
    ...auth,
    validateSuggestedItinerary,
    asyncHandler(
        ItineraryController.generateSuggested
    )
);

module.exports = router;