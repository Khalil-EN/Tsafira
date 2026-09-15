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

// ======================================================
// REGISTER
// ======================================================

router.post(
  "/register",
  validateRegister,
  asyncHandler(authController.register)
);

// ======================================================
// LOGIN
// ======================================================

router.post(
  "/login",
  validateLogin,
  asyncHandler(authController.login)
);

// ======================================================
// REFRESH TOKEN
// ======================================================

router.post(
  "/refresh",
  validateRefreshToken,
  asyncHandler(authController.refresh)
);

// ======================================================
// LOGOUT
// ======================================================

router.post(
  "/logout",
  validateLogout,
  asyncHandler(authController.logout)
);

// ======================================================
// SEND VERIFICATION CODE
// ======================================================

router.post(
    "/send-verification",
    validateSendVerificationCode,
    asyncHandler(authController.sendVerificationCode)
);

// ======================================================
// VERIFY EMAIL
// ======================================================

router.post(
    "/verify-email",
    validateVerifyEmail,
    asyncHandler(authController.verifyEmail)
);

// ======================================================
// RESEND VERIFICATION CODE
// ======================================================

router.post(
    "/resend-verification",
    validateResendVerificationCode,
    asyncHandler(authController.resendVerificationCode)
);
// ======================================================
// CURRENT USER
// ======================================================

router.get(
  "/me",
  authenticateToken,
  asyncHandler(authController.getCurrentUser)
);

module.exports = router;