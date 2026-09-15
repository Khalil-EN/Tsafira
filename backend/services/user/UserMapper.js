const userFactory =
    require("../../domain/users/userFactory");

const UserMapper = {
    fromPersistence(doc) {
        return userFactory({
            id: doc._id?.toString(),

            firstName: doc.firstName,
            lastName: doc.lastName,
            email: doc.email,
            phoneNumber: doc.phoneNumber,
            birthDate: doc.birthDate,

            passwordHash: doc.passwordHash,
            profilePicture: doc.profilePicture,
            location: doc.location,

            lastLoginDate: doc.lastLoginDate,
            status: doc.status,
            role: doc.role,
            isActive: doc.isActive,

            friends: doc.friends,
            communities: doc.communities,

            suggestionCountToday:
                doc.suggestionCountToday,

            lastSuggestionDate:
                doc.lastSuggestionDate,

            createdAt: doc.createdAt,

            emailVerified:
                doc.emailVerified,

            emailVerificationCode:
                doc.emailVerificationCode,

            emailVerificationExpiresAt:
                doc.emailVerificationExpiresAt,

            refreshToken:
                doc.refreshToken,

            fcmToken:
                doc.fcmToken,

            postsCount:
                doc.postsCount,
        });
    },

    toPersistence(user) {
        return {
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phoneNumber: user.phoneNumber,
            birthDate: user.birthDate,

            passwordHash: user.passwordHash,
            profilePicture: user.profilePicture,
            location: user.location,

            lastLoginDate: user.lastLoginDate,
            status: user.status,
            role: user.role,
            isActive: user.isActive,

            friends: user.friends,
            communities: user.communities,

            suggestionCountToday:
                user.suggestionCountToday,

            lastSuggestionDate:
                user.lastSuggestionDate,

            createdAt: user.createdAt,

            emailVerified:
                user.emailVerified,

            emailVerificationCode:
                user.emailVerificationCode,

            emailVerificationExpiresAt:
                user.emailVerificationExpiresAt,

            refreshToken:
                user.refreshToken,

            fcmToken:
                user.fcmToken,
        };
    },
};

module.exports = UserMapper;