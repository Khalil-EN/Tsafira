const {
    authenticateToken,
    authorizeRoles,
} = require("../../middlewares/authMiddleware");

const socialAuth = [
    authenticateToken,
    authorizeRoles(
        "admin",
        "premium",
        "freemium"
    ),
];

module.exports = socialAuth;