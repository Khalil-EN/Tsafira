const express = require("express");

const router = express.Router();

const asyncHandler =
    require("../../../middlewares/asyncHandler");

const socialAuth =
    require("../../../backend/routes/social/socialAuth");

const CommunityController =
    require("./communityController");

const {
    validateCreateCommunity,
    validateCommunityId,
    validateJoinCommunity,
} = require("./communityValidator");

router.use(socialAuth);

// POST /communities
router.post(
    "/",
    validateCreateCommunity,
    asyncHandler(
        CommunityController.createCommunity
    )
);

// GET /communities
router.get(
    "/",
    asyncHandler(
        CommunityController.getAllCommunities
    )
);

// GET /communities/mine
router.get(
    "/mine",
    asyncHandler(
        CommunityController.getMyMemberships
    )
);

// GET /communities/:id
router.get(
    "/:id",
    validateCommunityId,
    asyncHandler(
        CommunityController.getCommunityById
    )
);

// PUT /communities/:id
router.put(
    "/:id",
    validateCommunityId,
    asyncHandler(
        CommunityController.updateCommunity
    )
);

// DELETE /communities/:id
router.delete(
    "/:id",
    validateCommunityId,
    asyncHandler(
        CommunityController.deleteCommunity
    )
);

// POST /communities/:id/join
router.post(
    "/:id/join",
    validateCommunityId,
    asyncHandler(
        CommunityController.joinCommunity
    )
);

// GET /communities/:id/members
router.get(
    "/:id/members",
    validateCommunityId,
    asyncHandler(
        CommunityController.getMembers
    )
);

// POST /communities/:id/members/:userId/approve
router.post(
    "/:id/members/:userId/approve",
    validateCommunityId,
    asyncHandler(
        CommunityController.approveMember
    )
);

// GET /communities/:id/requests
router.get(
    "/:id/requests",
    validateCommunityId,
    asyncHandler(CommunityController.getPendingRequests)
);

// POST /communities/:id/members/:userId/reject
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

// POST /communities/:id/members/:userId/promote  { role: "moderator" | "admin" | "member" }
router.post(
    "/:id/members/:userId/promote",
    validateCommunityId,
    asyncHandler(CommunityController.promoteMember)
);

// POST /communities/:id/members/:userId/ban
router.post(
    "/:id/members/:userId/ban",
    validateCommunityId,
    asyncHandler(CommunityController.banMember)
);


module.exports = router;