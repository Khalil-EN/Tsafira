const {UnauthorizedError,} = require("../exceptions");

const {JwtProvider, PasswordEncoder, VerificationCodeGenerator} = require("../security");

const UserService = require("../services/user/UserService");

const EmailService = require("../services/infra/email/EmailService");

// TODO : A lots of validations so maybe a chain of validations must be implemented


const SecurityManager = {

    async register({firstName, lastName, email, phoneNumber, birthDate, password, profilePicture}) {

        const passwordHash = await PasswordEncoder.encode(password);

        return await UserService.registerUser({firstName, lastName, email, phoneNumber, birthDate, passwordHash,
                                               profilePicture, emailVerified: false});
    },

    async login(email, password, rememberMe = false) {

        let user;
        try {

            user = await UserService .getUserForAuthentication(email);
        } catch (error) {

            if (error.name === "NotFoundError") {
                throw new UnauthorizedError("Invalid email or password.");
            }

            throw error;
        }

        const passwordMatches = await PasswordEncoder.matches(password, user.passwordHash);

        if (!passwordMatches) {
            throw new UnauthorizedError("Invalid email or password.");
        }

        const accessToken = JwtProvider.generateAccessToken(user);
        const refreshToken = JwtProvider.generateRefreshToken(user,rememberMe);
        const hashedRefreshToken = await PasswordEncoder.encode(refreshToken);

        const authenticatedUser = await UserService.updateAuthenticationData(user.id,
                                                                            {
                                                                                refreshToken: hashedRefreshToken,
                                                                                lastLoginDate: new Date(),
                                                                            }
            );

        return {accessToken, refreshToken, user: authenticatedUser};
    },

    verifyToken(token) {

        return JwtProvider.verifyAccessToken(token);
    },

    async refreshToken(refreshToken) {

        let decoded;
        try {
            decoded = JwtProvider.verifyRefreshToken(refreshToken);

        } catch (error) {
            throw new UnauthorizedError("Invalid or expired refresh token.");
        }

        let user;

        try {
            user = await UserService.getUserForAuthenticationById(decoded.id);
        } catch (error) {
            throw new UnauthorizedError("Invalid refresh token.");
        }

        if (!user.refreshToken) {
            throw new UnauthorizedError("Invalid refresh token.");
        }

        const matches = await PasswordEncoder.matches(refreshToken, user.refreshToken);
        if (!matches) {
            throw new UnauthorizedError("Invalid refresh token.");
        }

        const accessToken = JwtProvider.generateAccessToken(user);

        return {accessToken};
    },

    async logout(refreshToken) {

        let decoded;
        try {

            decoded = JwtProvider.verifyRefreshToken(refreshToken);
        } catch {
            throw new UnauthorizedError("Invalid or expired refresh token.");
        }

        let user;
        try {

            user = await UserService.getUserForAuthenticationById(decoded.id);
        } catch {
            throw new UnauthorizedError("Invalid refresh token.");
        }

        if (!user.refreshToken) {
            throw new UnauthorizedError("Invalid refresh token.");
        }

        const matches = await PasswordEncoder.matches(refreshToken,user.refreshToken);

        if (!matches) {
            throw new UnauthorizedError("Invalid refresh token.");
        }

        await UserService.updateAuthenticationData(user.id, {refreshToken: null});
    },

    async sendVerificationCode(user) {

        if (user.emailVerified) {
            throw new UnauthorizedError("Email is already verified.");
        }

        const code = VerificationCodeGenerator.generate();
        const codeHash = await PasswordEncoder.encode(code);
        const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

        await UserService.saveEmailVerificationCode(user.id, codeHash, expiresAt);

        await EmailService.sendVerificationCode(user.email, code);
    },

    async verifyEmail(email, code) {

        let user;
        try {

            user = await UserService.getUserForEmailVerification(email);
        } catch (error) {
            if (error.name === "NotFoundError") {
                throw new UnauthorizedError("Invalid verification code.");
            }

            throw error;
        }
        if (user.emailVerified) {
            return;
        }

        if (!user.emailVerificationCode || !user.emailVerificationExpiresAt
        ) {
            throw new UnauthorizedError("Invalid verification code.");
        }
        if (new Date() > new Date(user.emailVerificationExpiresAt)
        ) {
            throw new UnauthorizedError("Verification code has expired.");
        }

        const matches = await PasswordEncoder.matches(code, user.emailVerificationCode);
        if (!matches) {
            throw new UnauthorizedError("Invalid verification code.");
        }

        await UserService.markEmailAsVerified(user.id);
    },

    async resendVerificationCode(email) {
        let user;

        try {
            user = await UserService.getUserForEmailVerification(email);
        } catch (error) {
            if (error.name === "NotFoundError") {
                throw new UnauthorizedError(
                    "Unable to resend verification code."
                );
            }

            throw error;
        }

        return this.sendVerificationCode(user);
    }
};


module.exports = SecurityManager;