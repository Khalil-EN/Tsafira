const express = require("express");

const router = express.Router();

const asyncHandler = require("../../../middlewares/asyncHandler");

const socialAuth = require("../socialAuth");

const CommunityController = require("./communityController");

const {
    validateCreateCommunity,
    validateCommunityId,
    validateJoinCommunity,
} = require("./communityValidator");

router.use(socialAuth);

router.post(
    "/",
    validateCreateCommunity,
    asyncHandler(
        CommunityController.createCommunity
    )
);

router.get(
    "/",
    asyncHandler(
        CommunityController.getAllCommunities
    )
);

router.get(
    "/mine",
    asyncHandler(
        CommunityController.getMyMemberships
    )
);

router.get(
    "/:id",
    validateCommunityId,
    asyncHandler(
        CommunityController.getCommunityById
    )
);

router.put(
    "/:id",
    validateCommunityId,
    asyncHandler(
        CommunityController.updateCommunity
    )
);

router.delete(
    "/:id",
    validateCommunityId,
    asyncHandler(
        CommunityController.deleteCommunity
    )
);

router.post(
    "/:id/join",
    validateCommunityId,
    asyncHandler(
        CommunityController.joinCommunity
    )
);

router.get(
    "/:id/members",
    validateCommunityId,
    asyncHandler(
        CommunityController.getMembers
    )
);

router.post(
    "/:id/members/:userId/approve",
    validateCommunityId,
    asyncHandler(
        CommunityController.approveMember
    )
);

router.get(
    "/:id/requests",
    validateCommunityId,
    asyncHandler(CommunityController.getPendingRequests)
);

router.post(
    "/:id/members/:userId/reject",
    validateCommunityId,
    asyncHandler(CommunityController.rejectMember)
);

router.get(
    "/:id/posts",
    validateCommunityId,
    asyncHandler(CommunityController.getCommunityFeed)
);

router.post(
    "/:id/members/:userId/promote",
    validateCommunityId,
    asyncHandler(CommunityController.promoteMember)
);

router.post(
    "/:id/members/:userId/ban",
    validateCommunityId,
    asyncHandler(CommunityController.banMember)
);


module.exports = router;