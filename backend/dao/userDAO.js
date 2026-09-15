const UserModel = require("../schemas/userSchema");
const CommunityMemberModel = require("../schemas/communityMemberSchema");
const { UserStatus } = require("../domain/users/enums/userEnums");
const { MemberStatus } = require("../domain/communities/enums/communityEnums");

const UserDAO = {

    // ======================================================
    // CREATE
    // ======================================================

    async createUser(userData) {
        const user = new UserModel(userData);
        return await user.save();
    },

    // ======================================================
    // GET
    // ======================================================

    async getUserById(id) {
        return await UserModel
            .findById(id)
            .lean();
    },

    async getUserByEmail(email) {
        return await UserModel
            .findOne({ email })
            .lean();
    },

    async getUserByUsername(username) {
        return await UserModel
            .findOne({ username })
            .lean();
    },

    async getAllUsers(filter = {}) {
        return await UserModel
            .find(filter)
            .lean();
    },

    async getPaginatedUsers({
        skip = 0,
        limit = 20,
    } = {}) {
        return await UserModel
            .find({})
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .select(
                "username firstName lastName email role status isActive profilePicture"
            )
            .lean();
    },

    async countUsers() {
        return await UserModel.countDocuments();
    },

    // ======================================================
    // REFRESH TOKEN
    // ======================================================

    async getUserByIdAndRefreshtoken(id) {
        return await UserModel
            .findById(id)
            .select("+refreshToken")
            .lean();
    },

    // ======================================================
    // COMMUNITIES
    // ======================================================

    async getUserCommunityIds(userId) {
        const memberships = await CommunityMemberModel
            .find({
                user: userId,
                status: MemberStatus.ACTIVE,
            })
            .select("community")
            .lean();

        return memberships.map(
            membership => membership.community
        );
    },

    // ======================================================
    // UPDATE
    // ======================================================

    async updateUser(id, updateData) {
        return await UserModel.findByIdAndUpdate(
            id,
            updateData,
            { new: true }
        ).lean();
    },

    // ======================================================
    // FRIENDS
    // ======================================================

    async addFriend(userId, friendId) {
        const [user, friend] = await Promise.all([
            UserModel.findByIdAndUpdate(
                userId,
                {
                    $addToSet: {
                        friends: friendId,
                    },
                },
                { new: true }
            ).lean(),

            UserModel.findByIdAndUpdate(
                friendId,
                {
                    $addToSet: {
                        friends: userId,
                    },
                },
                { new: true }
            ).lean(),
        ]);

        return {
            user,
            friend,
        };
    },

    // ======================================================
    // FCM
    // ======================================================

    async saveFcmToken(userId, token) {
        return await UserModel.findByIdAndUpdate(
            userId,
            {
                fcmToken: token,
            },
            { new: true }
        ).lean();
    },

    // ======================================================
    // ADMIN
    // ======================================================

    async banUser(userId) {
        return await UserModel.findByIdAndUpdate(
            userId,
            {
                status: UserStatus.SUSPENDED,
                isActive: false,
            },
            { new: true }
        ).lean();
    },

    async unbanUser(userId) {
        return await UserModel.findByIdAndUpdate(
            userId,
            {
                status: UserStatus.ACTIVE,
                isActive: true,
            },
            { new: true }
        ).lean();
    },

    async deleteUser(id) {
        return await UserModel.findByIdAndDelete(id);
    },

    // ======================================================
    // SEARCH
    // ======================================================

    async searchUsers(query, excludeUserId) {
        const normalizedQuery = String(query || '').trim();

        if (!normalizedQuery) {
            return [];
        }

        const searchTerms = normalizedQuery
            .split(/\s+/)
            .filter(Boolean)
            .map(term => new RegExp(term, 'i'));

        const searchConditions = searchTerms.map(regex => ({
            $or: [
                { username: regex },
                { firstName: regex },
                { lastName: regex },
            ],
        }));

        return await UserModel.find({
            _id: {
                $ne: excludeUserId,
            },

            $and: searchConditions,
        })
            .select(
                "username firstName lastName profilePicture"
            )
            .limit(10)
            .lean();
    },

    // ======================================================
    // BULK
    // ======================================================

    async getUsersByIds(ids, projection = {}) {
        return await UserModel.find({
            _id: {
                $in: ids,
            },
        })
            .select(projection)
            .lean();
    },

    async getAllUserIds() {
        return await UserModel
            .find({}, { _id: 1 })
            .lean();
    },

    async getUserByEmailForAuthentication(email) {
      return await UserModel
          .findOne({ email })
          .select("+passwordHash +refreshToken")
          .lean();
  },

  // ======================================================
  // EMAIL VERIFICATION
  // ======================================================

  async getUserForEmailVerification(email) {
      return await UserModel
          .findOne({ email })
          .select(
              "+emailVerificationCode +emailVerificationExpiresAt"
          )
          .lean();
  },

  async saveEmailVerificationCode(
      userId,
      codeHash,
      expiresAt
  ) {
      return await UserModel.findByIdAndUpdate(
          userId,
          {
              emailVerificationCode: codeHash,
              emailVerificationExpiresAt: expiresAt,
          },
          { new: true }
      ).lean();
  },

  async verifyEmail(userId) {
      return await UserModel.findByIdAndUpdate(
          userId,
          {
              emailVerified: true,
              emailVerificationCode: null,
              emailVerificationExpiresAt: null,
          },
          { new: true }
      ).lean();
  },

  async clearEmailVerificationCode(userId) {
      return await UserModel.findByIdAndUpdate(
          userId,
          {
              emailVerificationCode: null,
              emailVerificationExpiresAt: null,
          },
          { new: true }
      ).lean();
  },

    async removeFriendFromAll(userId) {
        return await UserModel.updateMany(
            { friends: userId },
            { $pull: { friends: userId } }
        );
    },
};

module.exports = UserDAO;