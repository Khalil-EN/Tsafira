const systemManager = require("../../system/SystemManager");

const AuthController = {


    async register(req, res) {
        const {
            firstName,
            lastName,
            email,
            phoneNumber,
            birthDate,
            password,
            profilePicture,
        } = req.body;

        await systemManager.registerUser({
            firstName,
            lastName,
            email,
            phoneNumber,
            birthDate,
            password,
            profilePicture,
        });

        return res.status(201).json({
            success: true,
            data: {
                message: "User registered successfully.",
            },
        });
    },

    async login(req, res) {

        const {
            email,
            password,
            rememberMe = false,
        } = req.body;

        const {
            accessToken,
            refreshToken,
            user,
        } = await systemManager.loginUser({
            email,
            password,
            rememberMe,
        });


        return res.status(200).json({
            success: true,
            data: {
                accessToken,
                refreshToken,
                user,
            },
        });
    },

    async refresh(req, res) {
        const { refreshToken } = req.body;

        const token = await systemManager.refreshToken(refreshToken);

        return res.status(200).json({
            success: true,
            data: token,
        });
    },

    async logout(req, res) {
        const { refreshToken } = req.body;

        await systemManager.logoutUser(refreshToken);

        return res.status(200).json({
            success: true,
            data: {
                message: "Logged out successfully.",
            },
        });
    },

    async sendVerificationCode(req, res) {
        const { email } = req.body;

        await systemManager.sendVerificationCode(email);

        return res.status(200).json({
            success: true,
            data: {
                message: "Verification code sent successfully.",
            },
        });
    },

    async verifyEmail(req, res) {
        const {email,code} = req.body;

        await systemManager.verifyEmail(email,code);

        return res.status(200).json({
            success: true,
            data: {
                message: "Email verified successfully.",
            },
        });
    },

    async resendVerificationCode(req, res) {
        const { email } = req.body;

        await systemManager.resendVerificationCode(email);

        return res.status(200).json({
            success: true,
            data: {
                message: "Verification code sent successfully.",
            },
        });
    },

    async getCurrentUser(req, res) {

        const user = await systemManager.getCurrentUser(req.user.id);

        return res.status(200).json({
            success: true,
            data: user,
        });
    },
};

module.exports = AuthController;