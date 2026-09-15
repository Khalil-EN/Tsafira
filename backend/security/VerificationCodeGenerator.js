const crypto = require("crypto");

const VerificationCodeGenerator = {

    generate() {
        return crypto
            .randomInt(1000, 10000)
            .toString();
    },

};

module.exports = VerificationCodeGenerator;