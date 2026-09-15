const jwt = require("jsonwebtoken");

const ACCESS_TOKEN_SECRET = process.env.ACCESS_TOKEN_SECRET;
const REFRESH_TOKEN_SECRET = process.env.REFRESH_TOKEN_SECRET;

const ACCESS_TOKEN_EXPIRATION = "2m";
const REFRESH_TOKEN_EXPIRATION = "30m";
const REMEMBER_ME_EXPIRATION = "30d";

const JwtProvider = {

    generateAccessToken(user) {

        return jwt.sign(

            {
                id: user.id,
                role: user.role,
            },

            ACCESS_TOKEN_SECRET,

            {
                expiresIn: ACCESS_TOKEN_EXPIRATION,
            }

        );

    },

    generateRefreshToken(user, rememberMe = false) {

        return jwt.sign(

            {
                id: user.id,
            },

            REFRESH_TOKEN_SECRET,

            {
                expiresIn: rememberMe
                    ? REMEMBER_ME_EXPIRATION
                    : REFRESH_TOKEN_EXPIRATION,
            }

        );

    },

    verifyAccessToken(token) {

        return jwt.verify(
            token,
            ACCESS_TOKEN_SECRET
        );

    },

    verifyRefreshToken(token) {

        return jwt.verify(
            token,
            REFRESH_TOKEN_SECRET
        );

    },

};

module.exports = JwtProvider;