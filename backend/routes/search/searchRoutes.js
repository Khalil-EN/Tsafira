const express = require("express");

const router = express.Router();

const asyncHandler = require("../../middlewares/asyncHandler");

const {
    authenticateToken,
} = require("../../middlewares/authMiddleware");

const SearchController = require("./searchController");

const {
    validateUserCommunitySearch,
    validateSearchFilters,
} = require("./searchValidator");


router.use(authenticateToken);


// POST /search/users-communities
router.post(
    "/users-communities",
    validateUserCommunitySearch,
    asyncHandler(SearchController.searchUsersAndCommunities)
);


// POST /search/residences
router.post(
    "/residences",
    validateSearchFilters,
    asyncHandler(SearchController.searchResidences)
);


// POST /search/restaurants
router.post(
    "/restaurants",
    validateSearchFilters,
    asyncHandler(SearchController.searchRestaurants)
);


// POST /search/activities
router.post(
    "/activities",
    validateSearchFilters,
    asyncHandler(SearchController.searchActivities)
);


module.exports = router;

