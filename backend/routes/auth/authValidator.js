const {
    ValidationError,
} = require("../../exceptions");

const {
    AVATAR_OPTIONS,
} = require("../../domain/users/avatarOptions");

function validateRegister(req, res, next) {
    const {
        firstName,
        lastName,
        email,
        phoneNumber,
        birthDate,
        password,
        profilePicture,
    } = req.body;

    if (
        !firstName ||
        !lastName ||
        !email ||
        !birthDate ||
        !password
    ) {
        throw new ValidationError(
            "All registration fields are required."
        );
    }

    console.log(profilePicture);

    if (
        profilePicture &&
        !AVATAR_OPTIONS.includes(profilePicture)
    ) {
        throw new ValidationError(
            "Invalid profile picture."
        );
    }

    next();
}

function validateLogin(req, res, next) {
    const {
        email,
        password,
    } = req.body;

    if (!email || !password) {
        throw new ValidationError(
            "Email and password are required."
        );
    }

    next();
}

function validateRefreshToken(req, res, next) {
    const { refreshToken } = req.body;

    if (!refreshToken) {
        throw new ValidationError(
            "Refresh token is required."
        );
    }

    next();
}

function validateLogout(req, res, next) {
    const { refreshToken } = req.body;

    if (!refreshToken) {
        throw new ValidationError(
            "Refresh token is required."
        );
    }

    next();
}

// ======================================================
// SEND VERIFICATION CODE
// ======================================================

function validateSendVerificationCode(req, res, next) {
    const { email } = req.body;

    if (!email) {
        throw new ValidationError(
            "Email is required."
        );
    }

    next();
}

// ======================================================
// VERIFY EMAIL
// ======================================================

function validateVerifyEmail(req, res, next) {
    const {
        email,
        code,
    } = req.body;

    if (!email || !code) {
        throw new ValidationError(
            "Email and verification code are required."
        );
    }

    if (!/^\d{4}$/.test(String(code))) {
        throw new ValidationError(
            "Verification code must be 4 digits."
        );
    }

    next();
}

// ======================================================
// RESEND VERIFICATION CODE
// ======================================================

function validateResendVerificationCode(req, res, next) {
    const { email } = req.body;

    if (!email) {
        throw new ValidationError(
            "Email is required."
        );
    }

    next();
}

module.exports = {
    validateRegister,
    validateLogin,
    validateRefreshToken,
    validateLogout,
    validateSendVerificationCode,
    validateVerifyEmail,
    validateResendVerificationCode,
};