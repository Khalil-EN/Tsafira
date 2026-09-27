const express = require("express");
const router = express.Router();

const asyncHandler = require("../../middlewares/asyncHandler");

const {
  authenticateToken,
} = require("../../middlewares/authMiddleware");

const {
    validateRegister,
    validateLogin,
    validateRefreshToken,
    validateLogout,
    validateSendVerificationCode,
    validateVerifyEmail,
    validateResendVerificationCode,
} = require("./authValidator");

const authController = require("./authController");


router.post(
  "/register",
  validateRegister,
  asyncHandler(authController.register)
);


router.post(
  "/login",
  validateLogin,
  asyncHandler(authController.login)
);


router.post(
  "/refresh",
  validateRefreshToken,
  asyncHandler(authController.refresh)
);


router.post(
  "/logout",
  validateLogout,
  asyncHandler(authController.logout)
);


router.post(
    "/send-verification",
    validateSendVerificationCode,
    asyncHandler(authController.sendVerificationCode)
);


router.post(
    "/verify-email",
    validateVerifyEmail,
    asyncHandler(authController.verifyEmail)
);


router.post(
    "/resend-verification",
    validateResendVerificationCode,
    asyncHandler(authController.resendVerificationCode)
);

router.get(
  "/me",
  authenticateToken,
  asyncHandler(authController.getCurrentUser)
);

module.exports = router;