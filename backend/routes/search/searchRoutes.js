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

router.post(
    "/users-communities",
    validateUserCommunitySearch,
    asyncHandler(SearchController.searchUsersAndCommunities)
);

router.post(
    "/residences",
    validateSearchFilters,
    asyncHandler(SearchController.searchResidences)
);

router.post(
    "/restaurants",
    validateSearchFilters,
    asyncHandler(SearchController.searchRestaurants)
);

router.post(
    "/activities",
    validateSearchFilters,
    asyncHandler(SearchController.searchActivities)
);


module.exports = router;

