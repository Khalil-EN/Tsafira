const UserDAO =
    require("../../dao/userDAO");

const userFactory =
    require("../../domain/users/userFactory");

const NotFoundError =
    require("../../exceptions/NotFoundError");

const ConflictError =
    require("../../exceptions/ConflictError");

const SuggestionLimitExceededError =
    require("../../domain/users/exceptions/SuggestionLimitExceededError");

const UserAssembler =
    require("./UserAssembler");

const UserMapper =
    require("./UserMapper");


const UserService = {

    // ============================================================
    // REGISTER USER
    // ============================================================

  async registerUser(userData) {

      const user =
          userFactory(userData);

      const existingUser =
          await UserDAO.getUserByEmail(
              user.email
          );

      if (existingUser) {
          throw new ConflictError(
              "Email already in use."
          );
      }

      const doc =
          await UserDAO.createUser(
              user
          );

      return UserMapper.fromPersistence(doc);
  },


    // ============================================================
    // GET USER BY ID
    // ============================================================

    async getUserById(id) {

        const doc =
            await UserDAO.getUserById(id);

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }

        const user = UserMapper.fromPersistence(doc);

        return UserAssembler.toDTO(
            user
        );
    },


    // ============================================================
    // GET USER BY EMAIL
    // ============================================================

    async getUserByEmail(email) {

        /*
         * The domain is responsible for normalization.
         *
         * Rather than importing a separate normalizer here,
         * create a temporary domain representation or expose
         * normalization through BaseUser.
         */

        const normalizedEmail = userFactory.normalizeEmail(email);


        const doc =
            await UserDAO.getUserByEmail(
                normalizedEmail
            );

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }

        const user = UserMapper.fromPersistence(doc)

        return UserAssembler.toDTO(
            user
        );
    },


    // ============================================================
    // GET USER FOR AUTHENTICATION
    // ============================================================

    async getUserForAuthentication(email) {

        const normalizedEmail = userFactory.normalizeEmail(email);

        const doc =
          await UserDAO.getUserByEmailForAuthentication(
              normalizedEmail
          );

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }

        /*
         * IMPORTANT:
         *
         * Do NOT return UserAssembler.toDTO() here.
         *
         * SecurityManager needs:
         *
         * - passwordHash
         * - refreshToken
         * - id
         * - role
         * - status
         *
         * Therefore this method returns the domain user.
         */

        return UserMapper.fromPersistence(doc);
    },


    // ============================================================
    // GET USER FOR AUTHENTICATION BY ID
    // ============================================================

    async getUserForAuthenticationById(id) {

        const doc =
            await UserDAO.getUserById(id);

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }

        return UserMapper.fromPersistence(doc);
    },


    // ============================================================
    // UPDATE USER
    // ============================================================

    async updateUser(id, updates) {

        const doc =
            await UserDAO.updateUser(
                id,
                updates
            );

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }

        const user = UserMapper.fromPersistence(doc);

        return UserAssembler.toDTO(
            user
        );
    },


    // ============================================================
    // UPDATE AUTHENTICATION DATA
    // ============================================================

    async updateAuthenticationData(
        id,
        updates
    ) {

        const doc =
            await UserDAO.updateUser(
                id,
                updates
            );

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }

        const user = UserMapper.fromPersistence(doc);

        return UserAssembler.toDTO(
            user
        );
    },


    // ============================================================
    // DEACTIVATE USER
    // ============================================================

    async deactivateUser(id) {

        const doc =
            await UserDAO.getUserById(id);

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }

        const user = UserMapper.fromPersistence(doc)


        user.deactivate();


        const updated =
            await UserDAO.updateUser(
                id,
                {
                    status: user.status,
                    isActive: user.isActive,
                }
            );


        const updatedUser = UserMapper.fromPersistence(updated);


        return UserAssembler.toDTO(
            updatedUser
        );
    },


    // ============================================================
    // GET ALL USERS BY ROLE
    // ============================================================

    async getAllUsersByRole(role) {

        const docs =
            await UserDAO.getAllUsers({
                role,
            });


        return docs.map((doc) => {

            const user = UserMapper.fromPersistence(doc);

            return UserAssembler.toDTO(
                user
            );
        });
    },


    // ============================================================
    // GET USER COMMUNITY IDS
    // ============================================================

    async getUserCommunityIds(userId) {

        const userExists =
            await UserDAO.getUserById(
                userId
            );

        if (!userExists) {

            throw new NotFoundError(
                "User not found"
            );
        }


        return await UserDAO.getUserCommunityIds(
            userId
        );
    },


    // ============================================================
    // ADD FRIEND
    // ============================================================

    async addFriend(
        userId,
        friendId
    ) {

        return await UserDAO.addFriend(
            userId,
            friendId
        );
    },


    // ============================================================
    // CHECK SUGGESTION LIMIT
    // ============================================================

    async checkSuggestionLimit(userId) {

        const doc =
            await UserDAO.getUserById(
                userId
            );

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }


        const user = UserMapper.fromPersistence(doc);


        if (!user.canMakeSuggestion()) {

            throw new SuggestionLimitExceededError();
        }


        if (
            typeof user.recordSuggestion ===
            "function"
        ) {

            const updates =
                user.recordSuggestion();


            await UserDAO.updateUser(
                userId,
                updates
            );
        }
    },


    // ============================================================
    // GET ALL USERS
    // ============================================================

    async getAllUsers({
        page = 1,
        limit = 20,
    } = {}) {

        const skip =
            (page - 1) * limit;


        const docs =
            await UserDAO.getPaginatedUsers({
                skip,
                limit,
            });


        const total =
            await UserDAO.countUsers();


        const users =
            docs.map((doc) => {

                const user = UserMapper.fromPersistence(doc);

                return UserAssembler.toSummaryDTO(
                    user
                );
            });


        return {
            users,
            total,
            page,
            limit,
        };
    },


    // ============================================================
    // BAN USER
    // ============================================================

    async banUser(userId) {

        const doc =
            await UserDAO.getUserById(
                userId
            );

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }


        const user = UserMapper.fromPersistence(doc);


        user.suspend();


        const updated =
            await UserDAO.updateUser(
                userId,
                {
                    status: user.status,
                    isActive: user.isActive,
                }
            );


        const updatedUser = UserMapper.fromPersistence(updated);


        return UserAssembler.toDTO(
            updatedUser
        );
    },


    // ============================================================
    // UNBAN USER
    // ============================================================

    async unbanUser(userId) {

        const doc =
            await UserDAO.getUserById(
                userId
            );

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }


        const user = UserMapper.fromPersistence(doc);


        user.restore();


        const updated =
            await UserDAO.updateUser(
                userId,
                {
                    status: user.status,
                    isActive: user.isActive,
                }
            );


        const updatedUser = UserMapper.fromPersistence(updated);


        return UserAssembler.toDTO(
            updatedUser
        );
    },


    // ============================================================
    // SAVE FCM TOKEN
    // ============================================================

    async saveFcmToken(
        userId,
        token
    ) {

        const doc =
            await UserDAO.saveFcmToken(
                userId,
                token
            );

        if (!doc) {

            throw new NotFoundError(
                "User not found"
            );
        }


        const user = UserMapper.fromPersistence(doc);


        return UserAssembler.toDTO(
            user
        );
    },

        // ============================================================
    // UPDATE PROFILE (self-service)
    // ============================================================

    async updateProfile(userId, updates) {


        const safeUpdates = { ...updates };

        // Fields that must never be changed through a profile edit.
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
            const normalizedEmail =
                userFactory.normalizeEmail(safeUpdates.email);

            const existing =
                await UserDAO.getUserByEmail(normalizedEmail);

            if (
                existing &&
                existing._id.toString() !== userId.toString()
            ) {
                throw new ConflictError(
                    "Email already in use."
                );
            }

            safeUpdates.email = normalizedEmail;
        }

        const doc =
            await UserDAO.updateUser(userId, safeUpdates);

        console.log(doc);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        const user = UserMapper.fromPersistence(doc);

        return UserAssembler.toDTO(user);
    },


    // ============================================================
    // REMOVE FRIENDSHIPS FOR USER
    // ============================================================

    async removeFriendshipsForUser(userId) {
        return await UserDAO.removeFriendFromAll(userId);
    },


    // ============================================================
    // DELETE USER (self-service, permanent)
    // ============================================================

    async deleteUser(userId) {

        const doc =
            await UserDAO.getUserById(userId);

        if (!doc) {
            throw new NotFoundError("User not found");
        }

        await UserDAO.deleteUser(userId);
    },


    // ============================================================
    // GET ALL USER IDS
    // ============================================================

    async getAllUserIds() {

        const users =
            await UserDAO.getAllUserIds();


        return users.map(
            user => user._id
        );
    },

    // ============================================================
  // GET USER FOR EMAIL VERIFICATION
  // ============================================================

  async getUserForEmailVerification(email) {

      const normalizedEmail =
          userFactory.normalizeEmail(email);


      const doc =
          await UserDAO.getUserForEmailVerification(
              normalizedEmail
          );


      if (!doc) {
          throw new NotFoundError(
              "User not found"
          );
      }


      return UserMapper.fromPersistence(doc);
  },

  // ============================================================
  // SAVE EMAIL VERIFICATION CODE
  // ============================================================

  async saveEmailVerificationCode(
      userId,
      codeHash,
      expiresAt
  ) {

      const doc =
          await UserDAO.saveEmailVerificationCode(
              userId,
              codeHash,
              expiresAt
          );


      if (!doc) {
          throw new NotFoundError(
              "User not found"
          );
      }


      return UserMapper.fromPersistence(doc);
  },

  // ============================================================
  // MARK EMAIL AS VERIFIED
  // ============================================================

  async markEmailAsVerified(userId) {

      const doc =
          await UserDAO.verifyEmail(userId);


      if (!doc) {
          throw new NotFoundError(
              "User not found"
          );
      }


      return UserMapper.fromPersistence(doc);
  },
};


module.exports = UserService;