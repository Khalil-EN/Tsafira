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
    console.log("========== REFRESH DEBUG ==========");
    console.log("Refresh token received:", !!refreshToken);
    console.log(
        "Refresh token length:",
        refreshToken ? refreshToken.length : null
    );

    let decoded;

    // 1. Verify refresh JWT
    try {
        decoded = JwtProvider.verifyRefreshToken(refreshToken);

        console.log("1. Refresh JWT is valid");
        console.log("Decoded ID:", decoded.id);
        console.log("Expiration:", decoded.exp);
    } catch (error) {
        console.error("1. REFRESH JWT VERIFICATION FAILED");
        console.error(error);

        throw new UnauthorizedError(
            "Invalid or expired refresh token."
        );
    }

    // 2. Find user
    let user;

    try {
        user = await UserService.getUserForAuthenticationById(
            decoded.id
        );

        console.log("2. User found:", !!user);
        console.log("User ID:", user?.id);
        console.log(
            "Stored refresh token exists:",
            !!user?.refreshToken
        );
    } catch (error) {
        console.error("2. USER LOOKUP FAILED");
        console.error(error);

        throw new UnauthorizedError(
            "Invalid refresh token."
        );
    }

    // 3. Check stored refresh token
    if (!user.refreshToken) {
        console.error("3. USER HAS NO STORED REFRESH TOKEN");

        throw new UnauthorizedError(
            "Invalid refresh token."
        );
    }

    // 4. Compare tokens
    try {
        const matches = await PasswordEncoder.matches(
            refreshToken,
            user.refreshToken
        );

        console.log("4. Refresh token matches:", matches);

        if (!matches) {
            console.error("4. REFRESH TOKEN DOES NOT MATCH HASH");

            throw new UnauthorizedError(
                "Invalid refresh token."
            );
        }
    } catch (error) {
        console.error("4. TOKEN COMPARISON FAILED");
        console.error(error);
        throw error;
    }

    // 5. Generate new access token
    const accessToken =
        JwtProvider.generateAccessToken(user);

    console.log("5. NEW ACCESS TOKEN GENERATED");
    console.log("===================================");

    return {
        accessToken,
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