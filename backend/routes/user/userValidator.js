const { ValidationError } = require("../../exceptions");

const ALLOWED_PROFILE_FIELDS = [
    "firstName",
    "lastName",
    "email",
    "phoneNumber",
    "birthDate",
    "profilePicture",
];

function validateUpdateProfile(req, res, next) {

    const hasDisallowedField = Object.keys(req.body).some(
        key => !ALLOWED_PROFILE_FIELDS.includes(key)
    );

    console.log(hasDisallowedField);

    if (hasDisallowedField) {
        throw new ValidationError(
            "Only profile fields can be updated here."
        );
    }

    next();
}

module.exports = {
    validateUpdateProfile,
};