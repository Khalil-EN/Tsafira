const bcrypt = require("bcrypt");

const SALT_ROUNDS = 10;

const PasswordEncoder = {

    async encode(password) {
        return await bcrypt.hash(password, SALT_ROUNDS);
    },

    async matches(rawPassword, encodedPassword) {

        if (!encodedPassword) {
            return false;
        }

        return await bcrypt.compare(
            rawPassword,
            encodedPassword
        );

    },

};

module.exports = PasswordEncoder;