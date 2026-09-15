const {
    UnauthorizedError,
} = require("../exceptions");

const {
    JwtProvider,
    PasswordEncoder,
    VerificationCodeGenerator,
} = require("../security");

const UserService =
    require("../services/user/UserService");

const EmailService =
    require("../services/infra/email/EmailService");


const SecurityManager = {

    // ======================================================
    // REGISTER
    // ======================================================

    async register({
        firstName,
        lastName,
        email,
        phoneNumber,
        birthDate,
        password,
        profilePicture,
    }) {

        const passwordHash =
            await PasswordEncoder.encode(password);

        return await UserService.registerUser({
            firstName,
            lastName,
            email,
            phoneNumber,
            birthDate,
            passwordHash,
            profilePicture,
            emailVerified: false,
        });
    },


    // ======================================================
    // LOGIN
    // ======================================================

    async login(
        email,
        password,
        rememberMe = false
    ) {

        let user;

        try {

            /*
             * IMPORTANT:
             *
             * This must return the domain user including
             * passwordHash and refreshToken.
             *
             * Do NOT use getUserByEmail() here if that
             * method returns a public DTO.
             */

            user =
                await UserService
                    .getUserForAuthentication(email);

        } catch (error) {

            if (
                error.name === "NotFoundError"
            ) {
                throw new UnauthorizedError(
                    "Invalid email or password."
                );
            }

            throw error;
        }


        // --------------------------------------------------
        // Verify password
        // --------------------------------------------------

        const passwordMatches =
            await PasswordEncoder.matches(
                password,
                user.passwordHash
            );

        if (!passwordMatches) {
            throw new UnauthorizedError(
                "Invalid email or password."
            );
        }


        // --------------------------------------------------
        // Generate access token
        // --------------------------------------------------

        const accessToken =
            JwtProvider.generateAccessToken(
                user
            );


        // --------------------------------------------------
        // Generate refresh token
        // --------------------------------------------------

        const refreshToken =
            JwtProvider.generateRefreshToken(
                user,
                rememberMe
            );


        // --------------------------------------------------
        // Hash refresh token before storing it
        // --------------------------------------------------

        const hashedRefreshToken =
            await PasswordEncoder.encode(
                refreshToken
            );


        // --------------------------------------------------
        // Persist authentication information
        // --------------------------------------------------

        const authenticatedUser =
            await UserService.updateAuthenticationData(
                user.id,
                {
                    refreshToken:
                        hashedRefreshToken,

                    lastLoginDate:
                        new Date(),
                }
            );

        console.log(authenticatedUser);


        // --------------------------------------------------
        // Return authentication response
        // --------------------------------------------------

        return {
            accessToken,
            refreshToken,
            user: authenticatedUser,
        };
    },


    // ======================================================
    // VERIFY ACCESS TOKEN
    // ======================================================

    verifyToken(token) {

        return JwtProvider.verifyAccessToken(
            token
        );
    },


    // ======================================================
    // REFRESH TOKEN
    // ======================================================

    async refreshToken(refreshToken) {

        let decoded;

        try {

            decoded =
                JwtProvider.verifyRefreshToken(
                    refreshToken
                );

        } catch {

            throw new UnauthorizedError(
                "Invalid or expired refresh token."
            );
        }


        let user;

        try {

            user =
                await UserService
                    .getUserForAuthenticationById(
                        decoded.id
                    );

        } catch {

            throw new UnauthorizedError(
                "Invalid refresh token."
            );
        }


        // --------------------------------------------------
        // User must have a stored refresh token
        // --------------------------------------------------

        if (!user.refreshToken) {

            throw new UnauthorizedError(
                "Invalid refresh token."
            );
        }


        // --------------------------------------------------
        // Compare supplied refresh token with stored hash
        // --------------------------------------------------

        const matches =
            await PasswordEncoder.matches(
                refreshToken,
                user.refreshToken
            );

        if (!matches) {

            throw new UnauthorizedError(
                "Invalid refresh token."
            );
        }


        // --------------------------------------------------
        // Generate new access token
        // --------------------------------------------------

        return {
            accessToken:
                JwtProvider.generateAccessToken(
                    user
                ),
        };
    },


    // ======================================================
    // LOGOUT
    // ======================================================

    async logout(refreshToken) {

        let decoded;

        try {

            decoded =
                JwtProvider.verifyRefreshToken(
                    refreshToken
                );

        } catch {

            throw new UnauthorizedError(
                "Invalid or expired refresh token."
            );
        }


        let user;

        try {

            user =
                await UserService
                    .getUserForAuthenticationById(
                        decoded.id
                    );

        } catch {

            throw new UnauthorizedError(
                "Invalid refresh token."
            );
        }


        // --------------------------------------------------
        // User must have a stored refresh token
        // --------------------------------------------------

        if (!user.refreshToken) {

            throw new UnauthorizedError(
                "Invalid refresh token."
            );
        }


        // --------------------------------------------------
        // Verify refresh token
        // --------------------------------------------------

        const matches =
            await PasswordEncoder.matches(
                refreshToken,
                user.refreshToken
            );

        if (!matches) {

            throw new UnauthorizedError(
                "Invalid refresh token."
            );
        }


        // --------------------------------------------------
        // Remove stored refresh token
        // --------------------------------------------------

        await UserService.updateAuthenticationData(
            user.id,
            {
                refreshToken: null,
            }
        );
    },

    // ======================================================
    // SEND EMAIL VERIFICATION CODE
    // ======================================================

    async sendVerificationCode(user) {

        if (user.emailVerified) {
            throw new UnauthorizedError(
                "Email is already verified."
            );
        }


        const code =
            VerificationCodeGenerator.generate();


        const codeHash =
            await PasswordEncoder.encode(code);


        const expiresAt =
            new Date(
                Date.now() + 10 * 60 * 1000
            );


        await UserService.saveEmailVerificationCode(
            user.id,
            codeHash,
            expiresAt
        );

        await EmailService.sendVerificationCode(
            user.email,
            code
        );
    },

    // ======================================================
    // VERIFY EMAIL
    // ======================================================

    async verifyEmail(email, code) {

        let user;

        try {

            user =
                await UserService
                    .getUserForEmailVerification(email);
            

        } catch (error) {

            if (error.name === "NotFoundError") {
                throw new UnauthorizedError(
                    "Invalid verification code."
                );
            }

            throw error;
        }


        if (user.emailVerified) {
            return;
        }


        if (
            !user.emailVerificationCode ||
            !user.emailVerificationExpiresAt
        ) {
            throw new UnauthorizedError(
                "Invalid verification code."
            );
        }


        if (
            new Date() >
            new Date(user.emailVerificationExpiresAt)
        ) {
            throw new UnauthorizedError(
                "Verification code has expired."
            );
        }


        const matches =
            await PasswordEncoder.matches(
                code,
                user.emailVerificationCode
            );


        if (!matches) {
            throw new UnauthorizedError(
                "Invalid verification code."
            );
        }


        await UserService.markEmailAsVerified(
            user.id
        );
    },

    // ======================================================
    // RESEND EMAIL VERIFICATION CODE
    // ======================================================

    async resendVerificationCode(email) {
        return this.sendVerificationCode(email);
    },
};


module.exports = SecurityManager;