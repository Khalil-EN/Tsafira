const UserDAO = require("../../dao/userDAO");

const userFactory = require("../../domain/users/userFactory");

const NotFoundError = require("../../exceptions/NotFoundError");

const ConflictError = require("../../exceptions/ConflictError");

const SuggestionLimitExceededError = require("../../domain/users/exceptions/SuggestionLimitExceededError");

const UserAssembler = require("./UserAssembler");

const UserMapper = require("./UserMapper");


// TODO : Has to be refactored

const UserService = {

  async registerUser(userData) {

      const user = userFactory(userData);

      const existingUser = await UserDAO.getUserByEmail(user.email);

      if (existingUser) {
          throw new ConflictError("Email already in use.");
      }

      const doc = await UserDAO.createUser(user);

      return UserMapper.fromPersistence(doc);
  },

    async getUserById(id) {

        const doc = await UserDAO.getUserById(id);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc);

        return UserAssembler.toDTO(user);
    },

    async getUserByEmail(email) {

        const normalizedEmail = userFactory.normalizeEmail(email);
        const doc = await UserDAO.getUserByEmail(normalizedEmail);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc)

        return UserAssembler.toDTO(user);
    },

    async getUserForAuthentication(email) {

        const normalizedEmail = userFactory.normalizeEmail(email);

        const doc = await UserDAO.getUserByEmailForAuthentication(normalizedEmail);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        return UserMapper.fromPersistence(doc);
    },

    async getUserForAuthenticationById(id) {

        const doc = await UserDAO.getUserByIdAndRefreshtoken(id);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        return UserMapper.fromPersistence(doc);
    },

    async updateUser(id, updates) {

        const doc = await UserDAO.updateUser(id, updates);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc);

        return UserAssembler.toDTO(user);
    },

    async updateAuthenticationData(id, updates) {

        const doc = await UserDAO.updateUser(id, updates);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc);

        return UserAssembler.toDTO(user);
    },

    async deactivateUser(id) {

        const doc = await UserDAO.getUserById(id);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc)
        user.deactivate();


        const updated = await UserDAO.updateUser(id,
                                                {
                                                    status: user.status,
                                                    isActive: user.isActive,
                                                }
        );

        const updatedUser = UserMapper.fromPersistence(updated);

        return UserAssembler.toDTO(updatedUser);
    },

    async getAllUsersByRole(role) {

        const docs = await UserDAO.getAllUsers({role});


        return docs.map((doc) => {
            const user = UserMapper.fromPersistence(doc);

            return UserAssembler.toDTO(user);
        });
    },

    async getUserCommunityIds(userId) {

        const userExists = await UserDAO.getUserById(userId);

        if (!userExists) {
            throw new NotFoundError("User not found");
        }

        return await UserDAO.getUserCommunityIds(userId);
    },

    async addFriend(userId, friendId) {

        return await UserDAO.addFriend(userId, friendId);
    },

    async checkSuggestionLimit(userId) {

        const doc = await UserDAO.getUserById(userId);
        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc);
        if (!user.canMakeSuggestion()) {
            throw new SuggestionLimitExceededError();
        }
        if (typeof user.recordSuggestion === "function") {

            const updates = user.recordSuggestion();
            await UserDAO.updateUser(userId,updates);
        }
    },

    async getAllUsers({page = 1, limit = 20,} = {}) {

        const skip = (page - 1) * limit;
        const docs = await UserDAO.getPaginatedUsers({skip,limit});
        const total = await UserDAO.countUsers();

        const users = docs.map((doc) => {
                        const user = UserMapper.fromPersistence(doc);
                        return UserAssembler.toSummaryDTO(user);
        });

        return {users, total, page, limit};
    },

    async banUser(userId) {

        const doc = await UserDAO.getUserById(userId);
        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc);
        user.suspend();
        const updated = await UserDAO.updateUser(userId,
                                                {
                                                    status: user.status,
                                                    isActive: user.isActive,
                                                }
        );

        const updatedUser = UserMapper.fromPersistence(updated);

        return UserAssembler.toDTO(updatedUser);
    },

    async unbanUser(userId) {

        const doc = await UserDAO.getUserById(userId);
        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc);
        user.restore();
        const updated = await UserDAO.updateUser(userId,
                                                {
                                                    status: user.status,
                                                    isActive: user.isActive,
                                                }
            );

        const updatedUser = UserMapper.fromPersistence(updated);


        return UserAssembler.toDTO(updatedUser);
    },

    async saveFcmToken(userId,token) {

        const doc = await UserDAO.saveFcmToken(userId,token);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc);

        return UserAssembler.toDTO(user);
    },

    async updateProfile(userId, updates) {

        const safeUpdates = { ...updates };

        delete safeUpdates.role;
        delete safeUpdates.status;
        delete safeUpdates.isActive;
        delete safeUpdates.passwordHash;
        delete safeUpdates.refreshToken;
        delete safeUpdates.friends;
        delete safeUpdates.emailVerified;
        delete safeUpdates.emailVerificationCode;
        delete safeUpdates.emailVerificationExpiresAt;

        if (safeUpdates.email) {
            const normalizedEmail = userFactory.normalizeEmail(safeUpdates.email);

            const existing = await UserDAO.getUserByEmail(normalizedEmail);

            if (existing && existing._id.toString() !== userId.toString()
            ) {
                throw new ConflictError("Email already in use.");
            }

            safeUpdates.email = normalizedEmail;
        }

        const doc = await UserDAO.updateUser(userId, safeUpdates);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc);

        return UserAssembler.toDTO(user);
    },

    async removeFriendshipsForUser(userId) {
        return await UserDAO.removeFriendFromAll(userId);
    },

    async deleteUser(userId) {

        const doc = await UserDAO.getUserById(userId);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        await UserDAO.deleteUser(userId);
    },

    async getAllUserIds() {

        const users = await UserDAO.getAllUserIds();


        return users.map(user => user._id);
    },

  async getUserForEmailVerification(email) {

      const normalizedEmail = userFactory.normalizeEmail(email);


      const doc = await UserDAO.getUserForEmailVerification(normalizedEmail);


      if (!doc) {
          throw new NotFoundError("User not found");
      }

      return UserMapper.fromPersistence(doc);
  },

  async saveEmailVerificationCode(userId, codeHash,expiresAt) {

      const doc = await UserDAO.saveEmailVerificationCode(userId, codeHash, expiresAt);


      if (!doc) {
          throw new NotFoundError("User not found");
      }

      return UserMapper.fromPersistence(doc);
  },

  async markEmailAsVerified(userId) {

      const doc = await UserDAO.verifyEmail(userId);


      if (!doc) {
          throw new NotFoundError("User not found");
      }

      return UserMapper.fromPersistence(doc);
  },
};


module.exports = UserService;