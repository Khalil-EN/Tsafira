const express = require("express");
const router = express.Router();

const asyncHandler = require("../../middlewares/asyncHandler");

const {
    authenticateToken,
} = require("../../middlewares/authMiddleware");

const UserController = require("./userController");

const { validateUpdateProfile } = require("./userValidator");

router.use(authenticateToken);

router.put(
    "/me",
    validateUpdateProfile,
    asyncHandler(UserController.updateProfile)
);

router.delete(
    "/me",
    asyncHandler(UserController.deleteProfile)
);

module.exports = router;